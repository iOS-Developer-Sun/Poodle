//
//  pdl_backtrace.m
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "pdl_backtrace.h"
#import <Foundation/Foundation.h>
#import <malloc/malloc.h>
#import <assert.h>
#import <string.h>
#import <stdio.h>
#import <limits.h>
#import <objc/runtime.h>
#import "pdl_thread.h"

#define PDL_BACKTRACE_FRAMES_MAX_COUNT 128

#define MAXTHREADNAMESIZE 64

typedef struct pdl_backtrace {
    void *isa;
    void *(*malloc_ptr)(size_t);
    void(*free_ptr)(void *);
    void **frames;
    int frames_count;
    pthread_t thread;
    pthread_mutex_t lock;
    pthread_mutex_t wait_lock;
    char thread_name[MAXTHREADNAMESIZE];
} pdl_backtrace;

@interface pdl_backtrace_info : NSObject

@end

@implementation pdl_backtrace_info

- (NSString *)description {
    pdl_backtrace *bt = (__bridge typeof(bt))self;
    return [NSString stringWithFormat:@"<pdl_backtrace: %p; frames_count = %d; frames = %p; thread = %p; thread_name = %s>", bt, bt->frames_count, bt->frames, bt->thread, bt->thread_name];
}

@end

static void *pdl_backtrace_wait(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    pthread_mutex_t *wait_lock = &(bt->wait_lock);
    pthread_mutex_t *lock = &(bt->lock);
    pthread_mutex_lock(lock);
    pthread_mutex_unlock(wait_lock);
    pthread_mutex_lock(lock);
    pthread_mutex_unlock(lock);

    return backtrace;
}

static void *pdl_backtrace_execute(pdl_backtrace *bt, void *(*start)(void *), void *arg, int hidden_count) {
    void *ret = pdl_thread_execute(bt->frames, bt->frames_count, start, arg, hidden_count);
    return ret;
}

static void *pdl_backtrace_thread_main(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    pthread_setname_np(bt->thread_name);
    void *ret = pdl_backtrace_execute(bt, &pdl_backtrace_wait, bt, 0);
    return ret;
}

static bool pdl_backtrace_filter_init(pdl_thread_frame_filter *filter) {
    filter->data = (void *)(unsigned long)0;
    return true;
}

static bool pdl_backtrace_filter_destroy(pdl_thread_frame_filter *filter) {
    return ((unsigned long)filter->data == 0);
}

static bool pdl_backtrace_filter_is_valid(pdl_thread_frame_filter *filter, void *link_register) {
    unsigned long max_count = (unsigned long)filter->init_data;
    unsigned long count = (unsigned long)filter->data;
    bool available = true;

    if (count == ULONG_MAX) {
        return false;
    }

    available = pdl_thread_fake_begin_filter(link_register);
    if (!available) {
        count++;
        filter->data = (void *)count;
        bool ret = (count < max_count);
        return ret;
    }

    available = pdl_thread_fake_end_filter(link_register);
    if (!available) {
        bool ret = (count < max_count);
        count--;
        filter->data = (void *)count;
        if (count == ULONG_MAX) {
            return false;
        }
        return ret;
    }

    bool ret = (count < max_count);
    return ret;
}

#pragma mark - public

pdl_backtrace_t pdl_backtrace_create(void) {
    return pdl_backtrace_create_with_malloc_pointers(NULL, NULL);
}

pdl_backtrace_t pdl_backtrace_create_with_malloc_pointers(void *(*malloc_ptr)(size_t), void(*free_ptr)(void *)) {
    void *(*m_ptr)(size_t) = malloc_ptr ?: &malloc;
    void(*f_ptr)(void *) = free_ptr ?: &free;

    size_t size = sizeof(pdl_backtrace);
    pdl_backtrace *bt = m_ptr(size);
    if (!bt) {
        return NULL;
    }

    memset(bt, 0, size);
    bt->isa = (__bridge void *)(objc_getClass("pdl_backtrace_info"));
    bt->malloc_ptr = m_ptr;
    bt->free_ptr = f_ptr;
    pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
    bt->lock = lock;
    pthread_mutex_t wait_lock = PTHREAD_MUTEX_INITIALIZER;
    bt->wait_lock = wait_lock;
    strlcpy(bt->thread_name, "pdl_backtrace", sizeof(bt->thread_name));

    return bt;
}

pdl_backtrace_t pdl_backtrace_copy(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    if (!bt) {
        return NULL;
    }

    void *(*m_ptr)(size_t) = bt->malloc_ptr;
    void(*f_ptr)(void *) = bt->free_ptr;

    pdl_backtrace *copy = pdl_backtrace_create_with_malloc_pointers(m_ptr, f_ptr);
    if (!copy) {
        return NULL;
    }

    strlcpy(copy->thread_name, bt->thread_name, sizeof(copy->thread_name));

    int frames_count = bt->frames_count;
    void **frames = bt->malloc_ptr(sizeof(void *) * frames_count);
    memcpy(frames, bt->frames, sizeof(void *) * frames_count);
    copy->frames = frames;
    copy->frames_count = frames_count;

    return copy;
}

const char *pdl_backtrace_get_name(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    if (!bt) {
        return NULL;
    }
    return bt->thread_name;
}

void pdl_backtrace_set_name(pdl_backtrace_t backtrace, const char *name) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    if (!bt) {
        return;
    }
    strlcpy(bt->thread_name, name ?: "", sizeof(bt->thread_name));
}

void pdl_backtrace_record(pdl_backtrace_t backtrace, unsigned int hidden_count) {
    unsigned int valid_hidden_count = hidden_count;
#ifdef DEBUG
    if (valid_hidden_count != UINT_MAX) {
        valid_hidden_count++;
    }
#endif
    pdl_backtrace_record_with_filter(backtrace, valid_hidden_count, NULL);
}

void pdl_backtrace_record_with_filter(pdl_backtrace_t backtrace, unsigned int hidden_count, pdl_thread_frame_filter *filter) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    if (!bt) {
        return;
    }

    void *lr = NULL;
    void *fp = NULL;
    if (hidden_count != __UINT32_MAX__) {
        lr = pdl_builtin_return_address(hidden_count + 1);
        fp = pdl_builtin_frame_address(hidden_count);
    }

    void **frames = NULL;
    int count_recorded = 0;
    int count = pdl_thread_frames_with_filter(lr, fp, NULL, PDL_BACKTRACE_FRAMES_MAX_COUNT, filter);
    if (count > 0) {
        frames = bt->malloc_ptr(sizeof(void *) * count);
        count_recorded = pdl_thread_frames_with_filter(lr, fp, frames, PDL_BACKTRACE_FRAMES_MAX_COUNT, filter);
        assert(count == count_recorded);
    }
    bt->free_ptr(bt->frames);
    bt->frames = frames;
    bt->frames_count = count_recorded;
}

void pdl_backtrace_filter_with_count(pdl_thread_frame_filter *filter, unsigned int count) {
    if (!filter) {
        return;
    }
    filter->init_data = (void *)(unsigned long)count;
    filter->init = &pdl_backtrace_filter_init;
    filter->destroy = &pdl_backtrace_filter_destroy;
    filter->is_valid = &pdl_backtrace_filter_is_valid;
}

void **pdl_backtrace_get_frames(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    if (!bt) {
        return NULL;
    }

    return bt->frames;
}

int pdl_backtrace_get_frames_count(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    if (!bt) {
        return 0;
    }

    return bt->frames_count;
}

void pdl_backtrace_thread_show(pdl_backtrace_t backtrace, bool wait) {
    pdl_backtrace_thread_show_with_start(backtrace, wait, &pthread_create);
}

void pdl_backtrace_thread_show_with_start(pdl_backtrace_t backtrace, bool wait, int (*thread_create)(pthread_t *, const pthread_attr_t *, void *(* )(void *), void *)) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    if (!bt) {
        return;
    }

    if (bt->thread) {
        return;
    }

    pthread_mutex_t *wait_lock = &(bt->wait_lock);
    pthread_mutex_lock(wait_lock);
    pthread_t thread = 0;
    int ret = thread_create(&thread, NULL, &pdl_backtrace_thread_main, bt);
    if (ret == 0) {
        bt->thread = thread;
    }

    if (wait) {
        pthread_mutex_lock(wait_lock);
        pthread_mutex_unlock(wait_lock);
    }
}

bool pdl_backtrace_thread_is_shown(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    if (!bt) {
        return false;
    }

    return (bt->thread != NULL);
}

void pdl_backtrace_thread_hide(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    if (!bt) {
        return;
    }

    if (bt->thread == NULL) {
        return;
    }

    pthread_mutex_t *wait_lock = &(bt->wait_lock);
    pthread_mutex_t *lock = &(bt->lock);
    pthread_mutex_lock(wait_lock);
    pthread_mutex_unlock(wait_lock);
    pthread_mutex_unlock(lock);
    pthread_join(bt->thread, NULL);
    bt->thread = NULL;
}

void pdl_backtrace_destroy(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    if (!bt) {
        return;
    }

    pdl_backtrace_thread_hide(bt);
    bt->free_ptr(bt->frames);
    bt->frames = NULL;
    bt->free_ptr(bt);
}

void *pdl_backtrace_thread_execute(pdl_backtrace_t backtrace, void *(*start)(void *), void *arg, int hidden_count) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    if (!bt) {
        return NULL;
    }

    void *ret = pdl_backtrace_execute(bt, start, arg, hidden_count);
    return ret;
}

void pdl_backtrace_print(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    if (!bt) {
        return;
    }

    for (int i = 0; i < bt->frames_count; i++) {
        malloc_printf("%p\n", bt->frames[i]);
    }
}
