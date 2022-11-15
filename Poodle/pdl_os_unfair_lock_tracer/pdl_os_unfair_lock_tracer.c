//
//  pdl_os_unfair_lock_tracer.c
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "pdl_os_unfair_lock_tracer.h"
#import <os/lock.h>
#import <pthread.h>
#import <stdio.h>
#import <mach/mach.h>
#import <dispatch/dispatch.h>
#import <assert.h>
#import <stdatomic.h>
#import "pdl_dynamic.h"
#import "pdl_spinlock.h"
#import "pdl_dictionary.h"
#import "pdl_array.h"

#if !TARGET_IPHONE_SIMULATOR && PDL_OS_UNFAIR_LOCK_TRACER_ENABLED

#define PDL_LOG_LOCK(lock, action) if (pdl_os_unfair_lock_log_enabled) { printf("PDL LOG LOCK %s: %p %u\n", #action, (lock), mach_thread_self()); }

#define PDL_LOG_LOCK_BEGIN(lock) PDL_LOG_LOCK((lock), BEGIN)
#define PDL_LOG_LOCK_END(lock) PDL_LOG_LOCK((lock), END)

static pdl_spinlock _pdl_os_map_lock = PDL_SPINLOCK_INIT;
static pdl_spinlock_t pdl_os_map_lock = &_pdl_os_map_lock;
#define PDL_MAP_LOCK pdl_spinlock_lock(pdl_os_map_lock)
#define PDL_MAP_UNLOCK pdl_spinlock_unlock(pdl_os_map_lock)

static pdl_dictionary_t pdl_os_lock_map(void) {
    static pdl_spinlock lock = PDL_SPINLOCK_INIT;
    pdl_spinlock_lock(&lock);
    static pdl_dictionary_t os_lock_map = NULL;
    if (os_lock_map == NULL) {
        os_lock_map = pdl_dictionary_create(NULL);
    }
    pdl_spinlock_unlock(&lock);
    return os_lock_map;
}

API_AVAILABLE(ios(10.0))
static void pdl_trace_os_lock(os_unfair_lock_t lock, mach_port_t thread) {
    PDL_MAP_LOCK;
    pdl_dictionary_t map = pdl_os_lock_map();
    void *value = (void *)(unsigned long)thread;
    pdl_dictionary_set(map, lock, &value);
    PDL_MAP_UNLOCK;
}

API_AVAILABLE(ios(10.0))
static void pdl_trace_os_unlock(os_unfair_lock_t lock, mach_port_t thread) {
    PDL_MAP_LOCK;
    pdl_dictionary_t map = pdl_os_lock_map();
    pdl_dictionary_remove(map, lock);
    PDL_MAP_UNLOCK;
}

typedef long os_unfair_lock_options_t;

API_AVAILABLE(ios(10.0))
extern void os_unfair_lock_lock_with_options(os_unfair_lock_t lock, os_unfair_lock_options_t options);

API_AVAILABLE(ios(10.0))
static void pdl_os_unfair_lock_lock(os_unfair_lock_t lock) {
    PDL_LOG_LOCK_BEGIN(lock);
    os_unfair_lock_lock(lock);
    pdl_trace_os_lock(lock, mach_thread_self());
    PDL_LOG_LOCK_END(lock);
}

API_AVAILABLE(ios(10.0))
static void pdl_os_unfair_lock_lock_with_options(os_unfair_lock_t lock, os_unfair_lock_options_t options) {
    PDL_LOG_LOCK_BEGIN(lock);
    os_unfair_lock_lock_with_options(lock, options);
    pdl_trace_os_lock(lock, mach_thread_self());
    PDL_LOG_LOCK_END(lock);
}

API_AVAILABLE(ios(10.0))
static void pdl_os_unfair_lock_unlock(os_unfair_lock_t lock) {
    PDL_LOG_LOCK_BEGIN(lock);
    os_unfair_lock_unlock(lock);
    pdl_trace_os_unlock(lock, mach_thread_self());
    PDL_LOG_LOCK_END(lock);
}

API_AVAILABLE(ios(10.0))
PDL_DYLD_INTERPOSE(pdl_os_unfair_lock_lock, os_unfair_lock_lock);
API_AVAILABLE(ios(10.0))
PDL_DYLD_INTERPOSE(pdl_os_unfair_lock_lock_with_options, os_unfair_lock_lock_with_options);
API_AVAILABLE(ios(10.0))
PDL_DYLD_INTERPOSE(pdl_os_unfair_lock_unlock, os_unfair_lock_unlock);

bool pdl_os_unfair_lock_log_enabled = false;

void pdl_print_os_unfair_lock_map(void) {
    pdl_dictionary_t map = pdl_os_lock_map();
    pdl_array_t allKeys = pdl_dictionary_all_keys(map);
    unsigned int count = pdl_array_count(allKeys);
    printf("[%u]\n", count);
    for (unsigned int i = 0; i < count; i++) {
        void *key = pdl_array_object_at_index(allKeys, i);
        void **value = pdl_dictionary_get(map, key);
        printf("%p : %p\n", key, *value);
    }
    pdl_array_destroy(allKeys);
}

#endif
