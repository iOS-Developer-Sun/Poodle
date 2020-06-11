//
//  pdl_malloc_zone.h
//  Poodle
//
//  Created by Poodle on 2020/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include <malloc/malloc.h>
#include <stdbool.h>

typedef enum pdl_malloc_trace_policy {
    pdl_malloc_trace_policy_live_allocations,
    pdl_malloc_trace_policy_allocation_and_free,
    pdl_malloc_trace_policy_custom_zone,
}pdl_malloc_trace_policy;

extern malloc_zone_t *pdl_malloc_zone(void);

extern void *pdl_malloc_zone_malloc(size_t size);
extern void *pdl_malloc_zone_calloc(size_t count, size_t size);
extern void *pdl_malloc_zone_valloc(size_t size);
extern void pdl_malloc_zone_free(void *ptr);
extern void *pdl_malloc_zone_realloc(void *ptr, size_t size);

extern void pdl_malloc_check_pointer(void *pointer);
extern void pdl_malloc_zone_enumerate(malloc_zone_t *zone, void *data, void(*function)(void *data, vm_range_t range, unsigned int type, unsigned int count, unsigned int index, bool *stops));

extern bool pdl_malloc_assert_enabled(void);
extern void pdl_malloc_assert_set_enabled(bool enabled);

extern unsigned int pdl_malloc_record_hidden_count(void);
extern void pdl_malloc_record_set_hidden_count(unsigned int hidden_count);

extern int (*pdl_malloc_pthread_create(void))(pthread_t *, const pthread_attr_t *, void *(*)(void *), void *);
extern void pdl_malloc_set_pthread_create(int(*pthread_create)(pthread_t *, const pthread_attr_t *, void *(*)(void *), void *));

extern void pdl_malloc_zone_show_backtrace(void *pointer);
extern void pdl_malloc_zone_hide_backtrace(void *pointer);

extern bool pdl_malloc_enable_trace(pdl_malloc_trace_policy policy);
