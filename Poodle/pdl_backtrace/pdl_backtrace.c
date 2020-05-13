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

#define PDL_BACKTRACE_FRAMES_MAX_COUNT 128

#pragma mark -
int pdl_backtrace_stack(void *link_register, void *frame_pointer, void **frames, int count) {
#ifdef __arm64__
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
        lr = *(fp + 1);
    }
    return ret;
#else
    return 0;
#endif
}

#define MAXTHREADNAMESIZE 64

typedef struct pdl_backtrace {
    void *(*malloc_ptr)(size_t);
    void(*free_ptr)(void *);
    void **frames;
    int frames_count;
    pthread_t thread;
    pthread_mutex_t lock;
    char thread_name[MAXTHREADNAMESIZE];
} pdl_backtrace;

#ifdef __arm64__
__attribute__((naked))
static void pdl_fake(__unused void **frames, __unused pthread_mutex_t *lock) {
    __asm__ volatile ("sub sp, sp, #0x40\n" // new space
                      "stp x19, x20, [sp, #0x10]\n"
                      "stp x21, x22, [sp, #0x20]\n"
                      "stp x29, x30, [sp, #0x30]\n"

                      "mov x19, x0\n" // store frames
                      "mov x20, x1\n" // store lock
                      "mov x21, fp\n" // store fp
                      "mov fp, x0\n" // fake
                      "mov x0, x20\n" // load lock
                      "bl _pthread_mutex_lock\n" // pthread_mutex_lock(lock);
                      "mov fp, x21\n" // recover

                      "ldp x19, x20, [sp, #0x10]\n" // delete space
                      "ldp x21, x22, [sp, #0x20]\n"
                      "ldp x29, x30, [sp, #0x30]\n"
                      "add sp, sp, #0x40\n"
                      "ret");
}
#else
static void pdl_fake(void **frames, pthread_mutex_t *lock) {
    pthread_mutex_lock(lock);
}
#endif

static void *thread_main(void *backtrace) {
    pdl_backtrace *bt = (pdl_backtrace_t)backtrace;
    pthread_setname_np(bt->thread_name);
    pthread_mutex_t *lock = &(bt->lock);
    void **frames = bt->malloc_ptr(sizeof(void *) * PDL_BACKTRACE_FRAMES_MAX_COUNT * 2);
    for (int i = 0; i < bt->frames_count; i++) {
        int fp_index = i * 2;
        int lr_index = i * 2 + 1;
        if (i != bt->frames_count - 1) {
            frames[fp_index] = &frames[fp_index + 2];
        } else {
            frames[fp_index] = NULL;
        }
        frames[lr_index] = bt->frames[i];
    }

    pthread_mutex_lock(lock);
    pdl_fake(frames, lock);
    pthread_mutex_unlock(lock);
    bt->free_ptr(frames);

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

    return bt;
}

void pdl_backtrace_set_name(pdl_backtrace_t backtrace, char *name) {
    pdl_backtrace *bt = (pdl_backtrace_t)backtrace;
    strlcpy(bt->thread_name, name ?: "pdl_backtrace", sizeof(bt->thread_name));
}

void pdl_backtrace_record(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace_t)backtrace;
    void *lr = __builtin_return_address(0);
    void *fp = __builtin_frame_address(0);
    void **frame = NULL;
    int count_recorded = 0;
    int count = pdl_backtrace_stack(lr, fp, NULL, PDL_BACKTRACE_FRAMES_MAX_COUNT);
    if (count > 0) {
        frame = bt->malloc_ptr(sizeof(void *) * count);
        count_recorded = pdl_backtrace_stack(lr, fp, frame, PDL_BACKTRACE_FRAMES_MAX_COUNT);
        assert(count == count_recorded);
    }
    bt->free_ptr(bt->frames);
    bt->frames = frame;
    bt->frames_count = count_recorded;
}

void pdl_backtrace_thread_show(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace_t)backtrace;
    if (bt->thread) {
        return;
    }

    pthread_t thread = 0;
    int ret = pthread_create(&thread, NULL, &thread_main, bt);
    if (ret == 0) {
        bt->thread = thread;
    }
}

void pdl_backtrace_thread_hide(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace_t)backtrace;
    if (bt->thread == NULL) {
        return;
    }

    pthread_mutex_unlock(&(bt->lock));
    pthread_join(bt->thread, NULL);
    bt->thread = NULL;
}

void pdl_backtrace_destroy(pdl_backtrace_t backtrace) {
    pdl_backtrace *bt = (pdl_backtrace_t)backtrace;
    pdl_backtrace_thread_hide(bt);
    bt->free_ptr(bt->frames);
    bt->frames = NULL;
    bt->free_ptr(bt);
}
