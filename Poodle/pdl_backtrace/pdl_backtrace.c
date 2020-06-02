//
//  pdl_backtrace.m
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "pdl_backtrace.h"
#import <malloc/malloc.h>
#import <assert.h>
#import <string.h>
#import <stdio.h>
#import "pdl_thread.h"

#define PDL_BACKTRACE_FRAMES_MAX_COUNT 128

#define MAXTHREADNAMESIZE 64

typedef struct pdl_backtrace {
    void *(*malloc_ptr)(size_t);
    void(*free_ptr)(void *);
    void **frames;
    int frames_count;
    pthread_t thread;
    pthread_mutex_t lock;
    pthread_mutex_t wait_lock;
    char thread_name[MAXTHREADNAMESIZE];
} pdl_backtrace;

static void *pdl_backtrace_wait(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    pthread_mutex_t *wait_lock = &(bt->wait_lock);
    pthread_mutex_unlock(wait_lock);

    pthread_mutex_t *lock = &(bt->lock);
    pthread_mutex_lock(lock);
    pthread_mutex_lock(lock);
    pthread_mutex_unlock(lock);

    return backtrace;
}

static void *pdl_backtrace_execute(pdl_backtrace *bt, void *(*start)(void *), void *arg) {
    void *ret = pdl_thread_execute(bt->frames, bt->frames_count, start, arg);
    return ret;
}

static void *pdl_backtrace_thread_main(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    pthread_setname_np(bt->thread_name);
    void *ret = pdl_backtrace_execute(bt, &pdl_backtrace_wait, bt);
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
    bt->malloc_ptr = m_ptr;
    bt->free_ptr = f_ptr;
    pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
    bt->lock = lock;
    pthread_mutex_t wait_lock = PTHREAD_MUTEX_INITIALIZER;
    bt->wait_lock = wait_lock;
    strlcpy(bt->thread_name, "pdl_backtrace", sizeof(bt->thread_name));

    return bt;
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

void pdl_backtrace_record(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    if (!bt) {
        return;
    }

    void *lr = __builtin_return_address(0);
    void *fp = __builtin_frame_address(0);
    void **frames = NULL;
    int count_recorded = 0;
    int count = pdl_thread_frames(lr, fp, NULL, PDL_BACKTRACE_FRAMES_MAX_COUNT);
    if (count > 0) {
        frames = bt->malloc_ptr(sizeof(void *) * count);
        count_recorded = pdl_thread_frames(lr, fp, frames, PDL_BACKTRACE_FRAMES_MAX_COUNT);
        assert(count == count_recorded);
    }
    bt->free_ptr(bt->frames);
    bt->frames = frames;
    bt->frames_count = count_recorded;
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

    pthread_mutex_unlock(&(bt->lock));
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

void *pdl_backtrace_thread_execute(pdl_backtrace_t backtrace, void *(*start)(void *), void *arg) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    if (!bt) {
        return NULL;
    }

    void *ret = pdl_backtrace_execute(bt, start, arg);
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
