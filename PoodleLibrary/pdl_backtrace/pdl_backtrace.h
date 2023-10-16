//
//  pdl_backtrace.h
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#include <stdlib.h>
#include <stdbool.h>
#include <pthread.h>
#include "pdl_thread.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct pdl_backtrace_record_attr {
    unsigned int hidden_count;
    pdl_thread_frame_filter *filter;
    void *frame_pointer;
    void *link_register;
} pdl_backtrace_record_attr;

#define PDL_BACKTRACE_RECORD_ATTR_INIT {0}

typedef void *pdl_backtrace_t;

extern pdl_backtrace_t pdl_backtrace_create(void);
extern pdl_backtrace_t pdl_backtrace_create_with_malloc_pointers(void *(*malloc_ptr)(size_t), void(*free_ptr)(void *));
extern pdl_backtrace_t pdl_backtrace_copy(pdl_backtrace_t backtrace);
extern const char *pdl_backtrace_get_name(pdl_backtrace_t backtrace);
extern void pdl_backtrace_set_name(pdl_backtrace_t backtrace, const char *name);
extern void pdl_backtrace_record(pdl_backtrace_t backtrace, pdl_backtrace_record_attr *attr);
extern void pdl_backtrace_set_frames(pdl_backtrace_t backtrace, void *frames, unsigned int frames_count);
extern void pdl_backtrace_filter_with_count(pdl_thread_frame_filter *filter, unsigned int count);
extern void **pdl_backtrace_get_frames(pdl_backtrace_t backtrace);
extern unsigned int pdl_backtrace_get_frames_count(pdl_backtrace_t backtrace);
extern void pdl_backtrace_thread_show(pdl_backtrace_t backtrace, bool wait);
extern void pdl_backtrace_thread_show_with_start(pdl_backtrace_t backtrace, bool wait, int (*thread_create)(pthread_t *, const pthread_attr_t *, void *(*)(void *), void *));
extern void pdl_backtrace_thread_show_with_block(pdl_backtrace_t backtrace, bool wait, void(^block)(void(^start)(void)));
extern bool pdl_backtrace_thread_is_shown(pdl_backtrace_t backtrace);
extern void pdl_backtrace_thread_hide(pdl_backtrace_t backtrace);
extern void pdl_backtrace_destroy(pdl_backtrace_t backtrace);

extern void *pdl_backtrace_thread_execute(pdl_backtrace_t backtrace, void *(*start)(void *), void *arg, int hidden_count);

extern void pdl_backtrace_print(pdl_backtrace_t backtrace);

#ifdef __cplusplus
}
#endif


