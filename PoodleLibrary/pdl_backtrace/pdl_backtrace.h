//
//  pdl_backtrace.h
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#include <stdlib.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void *pdl_backtrace_t;

extern pdl_backtrace_t pdl_backtrace_create(void);
extern pdl_backtrace_t pdl_backtrace_create_with_malloc_pointers(void *(*malloc_ptr)(size_t), void(*free_ptr)(void *));
extern void pdl_backtrace_set_name(pdl_backtrace_t backtrace, char *name);
extern void pdl_backtrace_record(pdl_backtrace_t backtrace);
extern void pdl_backtrace_thread_show(pdl_backtrace_t backtrace);
extern void pdl_backtrace_thread_hide(pdl_backtrace_t backtrace);
extern void pdl_backtrace_destroy(pdl_backtrace_t backtrace);

#ifdef __cplusplus
}
#endif


