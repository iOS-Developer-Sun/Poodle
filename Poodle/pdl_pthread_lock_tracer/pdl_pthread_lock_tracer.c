//
//  pdl_pthread_lock_tracer.c
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "pdl_pthread_lock_tracer.h"
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

#define PDL_LOG_LOCK(lock, action) if (pdl_rw_lock_log_enabled) { printf("PDL LOG LOCK %s: %s %p %u\n", #action, __FUNCTION__, (lock), mach_thread_self()); }

#define PDL_LOG_LOCK_BEGIN(lock) PDL_LOG_LOCK((lock), BEGIN)
#define PDL_LOG_LOCK_END(lock) PDL_LOG_LOCK((lock), END)

static pdl_spinlock _pdl_rw_map_lock = PDL_SPINLOCK_INIT;
static pdl_spinlock_t pdl_rw_map_lock = &_pdl_rw_map_lock;
#define PDL_MAP_LOCK pdl_spinlock_lock(pdl_rw_map_lock)
#define PDL_MAP_UNLOCK pdl_spinlock_unlock(pdl_rw_map_lock)

static pdl_dictionary_t pdl_rw_lock_map(void) {
    static pdl_dictionary_t rw_lock_map = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rw_lock_map = pdl_dictionary_create(NULL);
    });
    return rw_lock_map;
}

static void pdl_trace_rw_lock(pthread_rwlock_t *lock, mach_port_t thread) {
    PDL_MAP_LOCK;
    pdl_dictionary_t map = pdl_rw_lock_map();
    pdl_array_t array = NULL;
    void **object = pdl_dictionary_get(map, lock);
    if (object == NULL) {
        array = pdl_array_create(0);
        object = &array;
        pdl_dictionary_set(map, lock, object);
    } else {
        array = *object;
    }
    pdl_array_add(array, (void *)(unsigned long)thread);
    PDL_MAP_UNLOCK;
}

static void pdl_trace_rw_unlock(pthread_rwlock_t *lock, mach_port_t thread) {
    PDL_MAP_LOCK;
    pdl_dictionary_t map = pdl_rw_lock_map();
    pdl_array_t array = NULL;
    void **object = pdl_dictionary_get(map, lock);
    assert(object);
    array = *object;
    unsigned int index = pdl_array_index(array, (void *)(unsigned long)thread);
    pdl_array_remove(array, index);
    if (pdl_array_count(array) == 0) {
        pdl_dictionary_remove(map, lock);
        pdl_array_destroy(array);
    }
    PDL_MAP_UNLOCK;
}

static int pdl_pthread_rwlock_tryrdlock(pthread_rwlock_t *lock) {
    PDL_LOG_LOCK_BEGIN(lock);
    int ret = pthread_rwlock_tryrdlock(lock);
    if (ret == 0) {
        pdl_trace_rw_lock(lock, mach_thread_self());
    }
    PDL_LOG_LOCK_END(lock);
    return ret;
}

static int pdl_pthread_rwlock_trywrlock(pthread_rwlock_t *lock) {
    PDL_LOG_LOCK_BEGIN(lock);
    int ret = pthread_rwlock_trywrlock(lock);
    if (ret == 0) {
        pdl_trace_rw_lock(lock, mach_thread_self());
    }
    PDL_LOG_LOCK_END(lock);
    return ret;
}

static int pdl_pthread_rwlock_rdlock(pthread_rwlock_t *lock) {
    PDL_LOG_LOCK_BEGIN(lock);
    mach_port_t thread = mach_thread_self();
    int ret = pthread_rwlock_rdlock(lock);
    pdl_trace_rw_lock(lock, thread);
    PDL_LOG_LOCK_END(lock);
    return ret;
}

static int pdl_pthread_rwlock_wrlock(pthread_rwlock_t *lock) {
    PDL_LOG_LOCK_BEGIN(lock);
    mach_port_t thread = mach_thread_self();
    int ret = pthread_rwlock_wrlock(lock);
    pdl_trace_rw_lock(lock, thread);
    PDL_LOG_LOCK_END(lock);
    return ret;
}

static int pdl_pthread_rwlock_unlock(pthread_rwlock_t *lock) {
    PDL_LOG_LOCK_BEGIN(lock);
    mach_port_t thread = mach_thread_self();
    int ret = pthread_rwlock_unlock(lock);
    pdl_trace_rw_unlock(lock, thread);
    PDL_LOG_LOCK_END(lock);
    return ret;
}

PDL_DYLD_INTERPOSE(pdl_pthread_rwlock_tryrdlock, pthread_rwlock_tryrdlock);
PDL_DYLD_INTERPOSE(pdl_pthread_rwlock_trywrlock, pthread_rwlock_trywrlock);
PDL_DYLD_INTERPOSE(pdl_pthread_rwlock_rdlock, pthread_rwlock_rdlock);
PDL_DYLD_INTERPOSE(pdl_pthread_rwlock_wrlock, pthread_rwlock_wrlock);
PDL_DYLD_INTERPOSE(pdl_pthread_rwlock_unlock, pthread_rwlock_unlock);

bool pdl_rw_lock_log_enabled = false;

void pdl_print_rw_lock_map(void) {
//    PDL_MAP_LOCK;
    pdl_dictionary_t map = pdl_rw_lock_map();
    void **keys = NULL;
    unsigned int count = 0;
    pdl_dictionary_get_all_keys(map, &keys, &count);
    printf("[%u]\n", count);
    for (unsigned int i = 0; i < count; i++) {
        void *key = keys[i];
        void **value = pdl_dictionary_get(map, key);
        printf("%p : [", key);
        pdl_array_t items = *value;
        unsigned int items_count = pdl_array_count(items);
        for (unsigned int j = 0; j < items_count; j++) {
            void *item = pdl_array_get(items, j);
            if (j == 0) {
                printf("%p", item);
            } else {
                printf(", %p", item);
            }
        }
        printf("]\n");
    }
    pdl_dictionary_destroy_keys(map, keys);
//    PDL_MAP_UNLOCK;
}
