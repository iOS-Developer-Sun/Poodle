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

#ifdef __cplusplus
extern "C" {
#endif

typedef void *pdl_backtrace_t;

extern pdl_backtrace_t pdl_backtrace_create(void);
extern pdl_backtrace_t pdl_backtrace_create_with_malloc_pointers(void *(*malloc_ptr)(size_t), void(*free_ptr)(void *));
extern const char *pdl_backtrace_get_name(pdl_backtrace_t backtrace);
extern void pdl_backtrace_set_name(pdl_backtrace_t backtrace, const char *name);
extern void pdl_backtrace_record(pdl_backtrace_t backtrace, unsigned int hidden_count);
extern void pdl_backtrace_record_with_filters(pdl_backtrace_t backtrace, unsigned int hidden_count, bool(*begin_filter)(void *link_register), bool(*end_filter)(void *link_register));
extern bool pdl_backtrace_fake_begin_filter(void *link_register);
extern bool pdl_backtrace_fake_end_filter(void *link_register);
extern void **pdl_backtrace_get_frames(pdl_backtrace_t backtrace);
extern int pdl_backtrace_get_frames_count(pdl_backtrace_t backtrace);
extern void pdl_backtrace_thread_show(pdl_backtrace_t backtrace, bool wait);
extern void pdl_backtrace_thread_show_with_start(pdl_backtrace_t backtrace, bool wait, int (*thread_create)(pthread_t *, const pthread_attr_t *, void *(* )(void *), void *));
extern bool pdl_backtrace_thread_is_shown(pdl_backtrace_t backtrace);
extern void pdl_backtrace_thread_hide(pdl_backtrace_t backtrace);
extern void pdl_backtrace_destroy(pdl_backtrace_t backtrace);

extern void *pdl_backtrace_thread_execute(pdl_backtrace_t backtrace, void *(*start)(void *), void *arg, int hidden_count);

extern void pdl_backtrace_print(pdl_backtrace_t backtrace);

#ifdef __cplusplus
}
#endif


