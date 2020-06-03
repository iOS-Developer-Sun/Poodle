//
//  pdl_pthread_backtrace.c
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "pdl_pthread_backtrace.h"
#import "pdl_backtrace.h"

typedef struct pdl_thread_info {
    void *(*start)(void *);
    void *arg;
    pdl_backtrace_t backtrace;
//    int (*pthread_create_original)(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void *), void *arg);
} pdl_thread_info;

static void *pdl_thread_start(void *arg) {
    pdl_thread_info *info = (typeof(info))arg;
//    pdl_backtrace_thread_show_with_start(info->backtrace, true, info->pthread_create_original);
    void *ret = pdl_backtrace_thread_execute(info->backtrace, info->start, info->arg);
    pdl_backtrace_destroy(info->backtrace);
    free(info);
    return ret;
}

int pdl_pthread_backtrace_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void *), void *arg, int (*pthread_create_original)(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void *), void *arg)) {
    pdl_thread_info *info = malloc(sizeof(pdl_thread_info));
    int ret = 0;
    if (!info) {
        ret = pthread_create_original(thread, attr, start_routine, arg);
    } else {
        pdl_backtrace_t backtrace = pdl_backtrace_create();
        info->backtrace = backtrace;
        if (backtrace) {
            pdl_backtrace_record(backtrace);
        }
        info->start = start_routine;
        info->arg = arg;
//        info->pthread_create_original = pthread_create_original;
        ret = pthread_create_original(thread, attr, &pdl_thread_start, info);
        if (ret != 0) {
            free(info);
        }
    }
    return ret;
}
