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

static void *pdl_pthread_start(void *arg) {
    pdl_pthread_info *info = (typeof(info))arg;
    void *ret = pdl_backtrace_thread_execute(info->backtrace, info->start, info->arg, PDL_PTHREAD_BACKTRACE_FRAME_HIDDEN_COUNT);
    pdl_backtrace_destroy(info->backtrace);
    free(info);
    return ret;
}

int pdl_pthread_backtrace_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void *), void *arg, int (*pthread_create_original)(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void *), void *arg), unsigned int hidden_count) {
    pdl_pthread_info *info = malloc(sizeof(pdl_pthread_info));
    int ret = 0;
    if (!info) {
        ret = pthread_create_original(thread, attr, start_routine, arg);
    } else {
        pdl_backtrace_t backtrace = pdl_backtrace_create();
        info->backtrace = backtrace;
        if (backtrace) {
            pdl_backtrace_record_with_hidden_frames(backtrace, hidden_count);
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
