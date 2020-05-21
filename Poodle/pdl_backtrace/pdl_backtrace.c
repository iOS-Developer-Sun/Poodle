//
//  pdl_backtrace.m
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "pdl_backtrace.h"
#import <pthread/pthread.h>
#import <assert.h>
#import <string.h>
#import <stdio.h>

#define PDL_BACKTRACE_FRAMES_MAX_COUNT 128

int pdl_backtrace_stack(void *link_register, void *frame_pointer, void **frames, int count) {
    int ret = 0;
    void *lr = (void *)link_register;
    void **fp = (void **)frame_pointer;
    while (true) {
        if (ret > count) {
            break;
        }
        if (frames) {
            frames[ret] = lr;
        }
        ret++;
        if (!fp) {
            break;
        }
        if (!lr) {
            break;
        }
        fp = *fp;

        if (fp) {
            lr = *(fp + 1);
        } else {
            lr = NULL;
        }
    }
    return ret;
}

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

void pdl_backtrace_wait(pdl_backtrace *bt) {
    pthread_mutex_t *wait_lock = &(bt->wait_lock);
    pthread_mutex_unlock(wait_lock);

    pthread_mutex_t *lock = &(bt->lock);
    pthread_mutex_lock(lock);
    pthread_mutex_lock(lock);
    pthread_mutex_unlock(lock);
}

static void *pdl_backtrace_thread_main(void *backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    pthread_setname_np(bt->thread_name);
#ifdef __i386__
    int alignment = 4;
    __attribute__((aligned(4)))
    void *aligned_frames[bt->frames_count * alignment + 2];
    void **frames = aligned_frames + 2;
#else
    int alignment = 2;
    void *aligned_frames[bt->frames_count * alignment];
    void **frames = aligned_frames;
#endif
    for (int i = 0; i < bt->frames_count; i++) {
        int fp_index = i * alignment;
        int lr_index = i * alignment + 1;
        if (i != bt->frames_count - 1) {
            frames[fp_index] = &frames[fp_index + alignment];
        } else {
            frames[fp_index] = NULL;
        }
        frames[lr_index] = bt->frames[i];
    }

    extern void pdl_backtrace_fake(pdl_backtrace *bt, void **frames);
    pdl_backtrace_fake(bt, frames);

    return NULL;
}

pdl_backtrace_t pdl_backtrace_create(void) {
    return pdl_backtrace_create_with_malloc_pointers(NULL, NULL);
}

pdl_backtrace_t pdl_backtrace_create_with_malloc_pointers(void *(*malloc_ptr)(size_t), void(*free_ptr)(void *)) {
    size_t size = sizeof(pdl_backtrace);
    void *(*m_ptr)(size_t) = malloc_ptr ?: &malloc;
    void(*f_ptr)(void *) = free_ptr ?: &free;

    pdl_backtrace *bt = m_ptr(size);
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
    return bt->thread_name;
}

void pdl_backtrace_set_name(pdl_backtrace_t backtrace, const char *name) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    strlcpy(bt->thread_name, name ?: "", sizeof(bt->thread_name));
}

void pdl_backtrace_record(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    void *lr = __builtin_return_address(0);
    void *fp = __builtin_frame_address(0);
    void **frames = NULL;
    int count_recorded = 0;
    int count = pdl_backtrace_stack(lr, fp, NULL, PDL_BACKTRACE_FRAMES_MAX_COUNT);
    if (count > 0) {
        frames = bt->malloc_ptr(sizeof(void *) * count);
        count_recorded = pdl_backtrace_stack(lr, fp, frames, PDL_BACKTRACE_FRAMES_MAX_COUNT);
        assert(count == count_recorded);
    }
    bt->free_ptr(bt->frames);
    bt->frames = frames;
    bt->frames_count = count_recorded;
}

void pdl_backtrace_thread_show(pdl_backtrace_t backtrace, bool wait) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    if (bt->thread) {
        return;
    }

    pthread_mutex_t *wait_lock = &(bt->wait_lock);
    pthread_mutex_lock(wait_lock);
    pthread_t thread = 0;
    int ret = pthread_create(&thread, NULL, &pdl_backtrace_thread_main, bt);
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
    return (bt->thread != NULL);
}

void pdl_backtrace_thread_hide(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    if (bt->thread == NULL) {
        return;
    }

    pthread_mutex_unlock(&(bt->lock));
    pthread_join(bt->thread, NULL);
    bt->thread = NULL;
}

void pdl_backtrace_destroy(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    pdl_backtrace_thread_hide(bt);
    bt->free_ptr(bt->frames);
    bt->frames = NULL;
    bt->free_ptr(bt);
}

void pdl_backtrace_print(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace *)backtrace;
    for (int i = 0; i < bt->frames_count; i++) {
        printf("%p\n", bt->frames[i]);
    }
}
