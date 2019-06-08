//
//  pdl_pthread_lock_tracer.c
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//
//

#import <pdl_pthread_lock_tracer.h>
#import <os/lock.h>
#import <pthread.h>
#import <stdio.h>
#import <mach/mach.h>
#import <dispatch/dispatch.h>
#import <assert.h>
#import <pdl_dynamic.h>
#import "pdl_dictionary.h"
#import "pdl_array.h"

#define PDL_LOG_LOCK(lock, action) if (pdl_rw_lock_log_enabled) { printf("PDL LOG LOCK %s: %p %u\n", #action, (lock), mach_thread_self()); }

#define PDL_LOG_LOCK_BEGIN(lock) PDL_LOG_LOCK((lock), BEGIN)
#define PDL_LOG_LOCK_END(lock) PDL_LOG_LOCK((lock), END)

static os_unfair_lock _pdl_rw_map_lock = OS_UNFAIR_LOCK_INIT;
static os_unfair_lock_t pdl_rw_map_lock = &_pdl_rw_map_lock;

static pdl_dictionary_t pdl_rw_lock_map(void) {
    static pdl_dictionary_t rw_lock_map = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rw_lock_map = pdl_createDictionary();
    });
    return rw_lock_map;
}

static void pdl_trace_rw_lock(pthread_rwlock_t *lock, mach_port_t thread) {
    os_unfair_lock_lock(pdl_rw_map_lock);
    pdl_dictionary_t map = pdl_rw_lock_map();
    pdl_array_t array = NULL;
    void **object = pdl_objectForKey(map, lock);
    if (object == NULL) {
        array = pdl_createArrayWithCapacity(0);
        pdl_setObjectForKey(map, array, lock);
    } else {
        array = *object;
    }
    pdl_addObject(array, (void *)(unsigned long)thread);
    os_unfair_lock_unlock(pdl_rw_map_lock);
}

static void pdl_trace_rw_unlock(pthread_rwlock_t *lock, mach_port_t thread) {
    os_unfair_lock_lock(pdl_rw_map_lock);
    pdl_dictionary_t map = pdl_rw_lock_map();
    pdl_array_t array = NULL;
    void **object = pdl_objectForKey(map, lock);
    assert(object);
    array = *object;
    pdl_removeObject(array, (void *)(unsigned long)thread);
    if (pdl_countOfArray(array) == 0) {
        pdl_removeObjectForKey(map, lock);
        pdl_destroyArray(array);
    }
    os_unfair_lock_unlock(pdl_rw_map_lock);
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
    int ret = pthread_rwlock_rdlock(lock);
    pdl_trace_rw_lock(lock, mach_thread_self());
    PDL_LOG_LOCK_END(lock);
    return ret;
}

static int pdl_pthread_rwlock_wrlock(pthread_rwlock_t *lock) {
    PDL_LOG_LOCK_BEGIN(lock);
    int ret = pthread_rwlock_wrlock(lock);
    pdl_trace_rw_lock(lock, mach_thread_self());
    PDL_LOG_LOCK_END(lock);
    return ret;
}

static int pdl_pthread_rwlock_unlock(pthread_rwlock_t *lock) {
    PDL_LOG_LOCK_BEGIN(lock);
    int ret = pthread_rwlock_unlock(lock);
    pdl_trace_rw_unlock(lock, mach_thread_self());
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
    pdl_dictionary_t map = pdl_rw_lock_map();
    pdl_array_t allKeys = pdl_allKeys(map);
    unsigned int count = pdl_countOfArray(allKeys);
    printf("[%u]\n", count);
    for (unsigned int i = 0; i < count; i++) {
        void *key = pdl_objectAtIndex(allKeys, i);
        void **value = pdl_objectForKey(map, key);
        printf("%p : [", key);
        pdl_array_t items = *value;
        unsigned int items_count = pdl_countOfArray(items);
        for (unsigned int j = 0; j < items_count; j++) {
            void *item = pdl_objectAtIndex(allKeys, j);
            if (j == 0) {
                printf("%p", item);
            } else {
                printf(", %p", item);
            }
        }
        printf("]\n", key);
    }
    pdl_destroyArray(allKeys);
}
