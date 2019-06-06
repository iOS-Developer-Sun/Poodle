//
//  pdl_lock_tracer.m
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//
//

#import <pdl_lock_tracer.h>
#import <os/lock.h>
#import <pthread.h>
#import <stdio.h>
#import <mach/mach.h>
#import <dispatch/dispatch.h>
#import <assert.h>

#define DYLD_INTERPOSE(_replacement,_replacee) \
__attribute__((used)) static struct{ const void* replacement; const void* replacee; } _interpose_##_replacee \
__attribute__ ((section ("__DATA,__interpose"))) = { (const void*)(unsigned long)&_replacement, (const void*)(unsigned long)&_replacee };

#pragma mark - os_unfair_lock

static pthread_mutex_t pdl_os_map_mutex_opaque = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t *pdl_os_map_mutex = &pdl_os_map_mutex_opaque;

static pdl_dictionary_t pdl_os_lock_map(void) {
    static pdl_dictionary_t os_lock_map = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        os_lock_map = pdl_createDictionary();
    });
    return os_lock_map;
}

static void pdl_log_os_lock(os_unfair_lock_t lock, mach_port_t thread) {
    pthread_mutex_lock(pdl_os_map_mutex);
    pdl_dictionary_t map = pdl_os_lock_map();
    pdl_setObjectForKey(map, (void *)(unsigned long)thread, lock);
    pthread_mutex_unlock(pdl_os_map_mutex);
}

static void pdl_log_os_unlock(os_unfair_lock_t lock, mach_port_t thread) {
    pthread_mutex_lock(pdl_os_map_mutex);
    pdl_dictionary_t map = pdl_os_lock_map();
    pdl_removeObjectForKey(map, lock);
    pthread_mutex_unlock(pdl_os_map_mutex);
}

typedef long os_unfair_lock_options_t;
extern void os_unfair_lock_lock_with_options(os_unfair_lock_t lock, os_unfair_lock_options_t options);

static void pdl_os_unfair_lock_lock(os_unfair_lock_t lock) {
    os_unfair_lock_lock(lock);
    pdl_log_os_lock(lock, mach_thread_self());
}

static void pdl_os_unfair_lock_lock_with_options(os_unfair_lock_t lock, os_unfair_lock_options_t options) {
    os_unfair_lock_lock_with_options(lock, options);
    pdl_log_os_lock(lock, mach_thread_self());
}

static void pdl_os_unfair_lock_unlock(os_unfair_lock_t lock) {
    os_unfair_lock_unlock(lock);
    pdl_log_os_unlock(lock, mach_thread_self());
}

DYLD_INTERPOSE(pdl_os_unfair_lock_lock, os_unfair_lock_lock);
DYLD_INTERPOSE(pdl_os_unfair_lock_lock_with_options, os_unfair_lock_lock_with_options);
DYLD_INTERPOSE(pdl_os_unfair_lock_unlock, os_unfair_lock_unlock);

#pragma mark - pthread_rwlock

static pthread_mutex_t pdl_rw_map_mutex_opaque = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t *pdl_rw_map_mutex = &pdl_rw_map_mutex_opaque;

static pdl_dictionary_t pdl_rw_lock_map(void) {
    static pdl_dictionary_t rw_lock_map = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rw_lock_map = pdl_createDictionary();
    });
    return rw_lock_map;
}

static void pdl_log_rw_lock(pthread_rwlock_t *lock, mach_port_t thread) {
    pthread_mutex_lock(pdl_rw_map_mutex);
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
    pthread_mutex_unlock(pdl_rw_map_mutex);
}

static void pdl_log_rw_unlock(pthread_rwlock_t *lock, mach_port_t thread) {
    pthread_mutex_lock(pdl_rw_map_mutex);
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
    pthread_mutex_unlock(pdl_rw_map_mutex);
}

static int pdl_pthread_rwlock_rdlock(pthread_rwlock_t *lock) {
    int ret = pthread_rwlock_rdlock(lock);
    pdl_log_rw_lock(lock, mach_thread_self());
    return ret;
}

static int pdl_pthread_rwlock_wrlock(pthread_rwlock_t *lock) {
    int ret = pthread_rwlock_wrlock(lock);
    pdl_log_rw_lock(lock, mach_thread_self());
    return ret;
}

static int pdl_pthread_rwlock_unlock(pthread_rwlock_t *lock) {
    int ret = pthread_rwlock_unlock(lock);
    pdl_log_rw_unlock(lock, mach_thread_self());
    return ret;
}

DYLD_INTERPOSE(pdl_pthread_rwlock_rdlock, pthread_rwlock_rdlock);
DYLD_INTERPOSE(pdl_pthread_rwlock_wrlock, pthread_rwlock_wrlock);
DYLD_INTERPOSE(pdl_pthread_rwlock_unlock, pthread_rwlock_unlock);

__attribute__ ((constructor))
//static
void pdl_lock_tracer(void) {
    printf("pdl_lock_tracer\n");
}

void pdl_print_os_lock_map(void) {
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
