//
//  pdl_os_unfair_lock_tracer.c
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//
//

#import <pdl_os_unfair_lock_tracer.h>
#import <os/lock.h>
#import <pthread.h>
#import <stdio.h>
#import <mach/mach.h>
#import <dispatch/dispatch.h>
#import <assert.h>
#import <stdatomic.h>
#import <pdl_dynamic.h>
#import "pdl_dictionary.h"
#import "pdl_array.h"

#define PDL_LOG_LOCK(lock, action) if (pdl_os_unfair_lock_log_enabled) { printf("PDL LOG LOCK %s: %p %u\n", #action, (lock), mach_thread_self()); }

#define PDL_LOG_LOCK_BEGIN(lock) PDL_LOG_LOCK((lock), BEGIN)
#define PDL_LOG_LOCK_END(lock) PDL_LOG_LOCK((lock), END)

static pthread_mutex_t _pdl_rw_map_lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t *pdl_rw_map_lock = &_pdl_rw_map_lock;
#define PDL_MAP_LOCK pthread_mutex_lock(pdl_rw_map_lock)
#define PDL_MAP_UNLOCK pthread_mutex_unlock(pdl_rw_map_lock)

static pdl_dictionary_t pdl_os_lock_map(void) {
    static pdl_dictionary_t os_lock_map = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        os_lock_map = pdl_createDictionary();
    });
    return os_lock_map;
}

static void pdl_trace_os_lock(os_unfair_lock_t lock, mach_port_t thread) {
    PDL_MAP_LOCK;
    pdl_dictionary_t map = pdl_os_lock_map();
    pdl_setObjectForKey(map, (void *)(unsigned long)thread, lock);
    PDL_MAP_UNLOCK;
}

static void pdl_trace_os_unlock(os_unfair_lock_t lock, mach_port_t thread) {
    PDL_MAP_LOCK;
    pdl_dictionary_t map = pdl_os_lock_map();
    pdl_removeObjectForKey(map, lock);
    PDL_MAP_UNLOCK;
}

typedef long os_unfair_lock_options_t;
extern void os_unfair_lock_lock_with_options(os_unfair_lock_t lock, os_unfair_lock_options_t options);

static void pdl_os_unfair_lock_lock(os_unfair_lock_t lock) {
    PDL_LOG_LOCK_BEGIN(lock);
    os_unfair_lock_lock(lock);
    pdl_trace_os_lock(lock, mach_thread_self());
    PDL_LOG_LOCK_END(lock);
}

static void pdl_os_unfair_lock_lock_with_options(os_unfair_lock_t lock, os_unfair_lock_options_t options) {
    PDL_LOG_LOCK_BEGIN(lock);
    os_unfair_lock_lock_with_options(lock, options);
    pdl_trace_os_lock(lock, mach_thread_self());
    PDL_LOG_LOCK_END(lock);
}

static void pdl_os_unfair_lock_unlock(os_unfair_lock_t lock) {
    PDL_LOG_LOCK_BEGIN(lock);
    os_unfair_lock_unlock(lock);
    pdl_trace_os_unlock(lock, mach_thread_self());
    PDL_LOG_LOCK_END(lock);
}

//PDL_DYLD_INTERPOSE(pdl_os_unfair_lock_lock, os_unfair_lock_lock);
//PDL_DYLD_INTERPOSE(pdl_os_unfair_lock_lock_with_options, os_unfair_lock_lock_with_options);
//PDL_DYLD_INTERPOSE(pdl_os_unfair_lock_unlock, os_unfair_lock_unlock);

bool pdl_os_unfair_lock_log_enabled = false;

void pdl_print_os_unfair_lock_map(void) {
    pdl_dictionary_t map = pdl_os_lock_map();
    pdl_array_t allKeys = pdl_allKeys(map);
    unsigned int count = pdl_countOfArray(allKeys);
    printf("[%u]\n", count);
    for (unsigned int i = 0; i < count; i++) {
        void *key = pdl_objectAtIndex(allKeys, i);
        void **value = pdl_objectForKey(map, key);
        printf("%p : %p\n", key, *value);
    }
    pdl_destroyArray(allKeys);
}
