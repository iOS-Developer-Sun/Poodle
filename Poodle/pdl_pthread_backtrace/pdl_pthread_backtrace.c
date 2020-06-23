//
//  pdl_pthread_backtrace.c
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "pdl_pthread_backtrace.h"
#import "pdl_backtrace.h"

#ifdef DEBUG
#define PDL_PTHREAD_BACKTRACE_FRAME_HIDDEN_COUNT 4
#else
#define PDL_PTHREAD_BACKTRACE_FRAME_HIDDEN_COUNT 1
#endif

typedef struct pdl_pthread_info {
    void *(*start)(void *);
    void *arg;
    pdl_backtrace_t backtrace;
} pdl_pthread_info;

#define PDL_PTHREAD_KEY_INVALID -1

static pthread_key_t pdl_pthread_key = PDL_PTHREAD_KEY_INVALID;

static void pdl_pthread_info_destroy(void *arg) {
    pdl_pthread_info *info = (typeof(info))arg;
    pdl_backtrace_destroy(info->backtrace);
    free(info);
}

static void pdl_pthread_init(void) {
    static bool init = false;
    if (init) {
        return;
    }

    static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_lock(&mutex);
    if (!init) {
        init = true;

        pthread_key_create(&pdl_pthread_key, &pdl_pthread_info_destroy);
    }
    pthread_mutex_unlock(&mutex);
}

static void *pdl_pthread_start(void *arg) {
    pdl_pthread_info *info = (typeof(info))arg;
    if (pdl_pthread_key != PDL_PTHREAD_KEY_INVALID) {
        pthread_setspecific(pdl_pthread_key, info);
    }
    void *ret = pdl_backtrace_thread_execute(info->backtrace, info->start, info->arg, PDL_PTHREAD_BACKTRACE_FRAME_HIDDEN_COUNT);
    pdl_pthread_info_destroy(info);
    if (pdl_pthread_key != PDL_PTHREAD_KEY_INVALID) {
        pthread_setspecific(pdl_pthread_key, NULL);
    }
    return ret;
}

int pdl_pthread_backtrace_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void *), void *arg, int (*pthread_create_original)(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void *), void *arg), unsigned int hidden_count, unsigned int recursion_count) {
    pdl_pthread_init();

    pdl_pthread_info *info = malloc(sizeof(pdl_pthread_info));
    int ret = 0;
    if (!info) {
        ret = pthread_create_original(thread, attr, start_routine, arg);
    } else {
        pdl_backtrace_t backtrace = pdl_backtrace_create();
        info->backtrace = backtrace;
        if (backtrace) {
            pdl_thread_frame_filter filter;
            pdl_backtrace_filter_with_count(&filter, recursion_count);
            pdl_backtrace_record_with_filter(backtrace, hidden_count, &filter);
        }
        info->start = start_routine;
        info->arg = arg;
        ret = pthread_create_original(thread, attr, &pdl_pthread_start, info);
        if (ret != 0) {
            free(info);
        }
    }
    return ret;
}
