//
//  PDLNonThreadSafeObserverObject.m
//  Poodle
//
//  Created by Poodle on 2021/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeObserverObject.h"
#import <mach/mach.h>
#import <objc/runtime.h>
#import <pthread.h>
#import "NSObject+PDLDebug.h"
#import "NSObject+PDLPrivate.h"
#import "pdl_thread_storage.h"
#import "pdl_array.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafeObserverInitializing : NSObject

@property (nonatomic, assign) mach_port_t thread;

@end

@implementation PDLNonThreadSafeObserverInitializing

@end

@interface PDLNonThreadSafeObserverObject ()

@property (unsafe_unretained, readonly) id object;
@property (weak, readonly) PDLNonThreadSafeObserverInitializing *initializing;

@end

@implementation PDLNonThreadSafeObserverObject

- (instancetype)initWithObject:(id)object {
    self = [super init];
    if (self) {
        _object = object;
        PDLNonThreadSafeObserverInitializing *initializing = [[[PDLNonThreadSafeObserverInitializing alloc] init] pdl_autoreleaseRetained];
        initializing.thread = mach_thread_self();
        _initializing = initializing;
    }
    return self;
}

- (NSString *)description {
    NSString *description = [super description];
    return [NSString stringWithFormat:@"%@, object: %p, isInitializing: %@", description, self.object, @(self.isInitializing)];
}

- (BOOL)isInitializing {
    BOOL isInitializing = self.initializing && self.initializing.thread == mach_thread_self();
    return isInitializing;
}

static void *PDLNonThreadSafePropertyObserverObjectObjectKey = &PDLNonThreadSafePropertyObserverObjectObjectKey;

static void *registerKey(void) {
    static pthread_mutex_t registerLock = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_lock(&registerLock);
    static bool init = false;
    if (!init) {
        pdl_thread_storage_register(&registerLock, NULL);
        init = true;
    }
    pthread_mutex_unlock(&registerLock);
    return &registerLock;
}

static void recordListDestroy(void *arg) {
    pdl_array_t array = (typeof(array))arg;
    assert(pdl_array_count(array) == 0);
    pdl_array_destroy(array);
}

static void *recordKey(void) {
    static pthread_mutex_t recordLock = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_lock(&recordLock);
    static bool init = false;
    if (!init) {
        pdl_thread_storage_register(&recordLock, recordListDestroy);
        init = true;
    }
    pthread_mutex_unlock(&recordLock);
    return &recordLock;
}

+ (BOOL)isRegistering {
    void *key = registerKey();
    void **value = pdl_thread_storage_get(key);
    BOOL isRegistering = value && *value;
    return isRegistering;
}

+ (void)setIsRegistering:(BOOL)isRegistering {
    void *key = registerKey();
    if (isRegistering) {
        pdl_thread_storage_set(key, (void **)&isRegistering);
    } else {
        pdl_thread_storage_set(key, NULL);
    }
}

+ (void)registerObject:(id _Nullable)object {
    if (!object) {
        return;
    }

    PDLNonThreadSafeObserverObject *observer = objc_getAssociatedObject(object, PDLNonThreadSafePropertyObserverObjectObjectKey);
    if (observer) {
        return;
    }

    BOOL isRegistering = [self isRegistering];
    if (isRegistering) {
        return;
    }

    isRegistering = YES;
    [self setIsRegistering:YES];
    observer = [[self alloc] initWithObject:object];
    objc_setAssociatedObject(object, PDLNonThreadSafePropertyObserverObjectObjectKey, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setIsRegistering:NO];
}

+ (instancetype)observerObjectForObject:(id)object {
    BOOL isDeallocating = [object _isDeallocating];
    if (isDeallocating) {
        return nil;
    }

    PDLNonThreadSafeObserverObject *observer = objc_getAssociatedObject(object, &PDLNonThreadSafePropertyObserverObjectObjectKey);
    return observer;
}

- (BOOL)startRecording {
    void *key = recordKey();
    void **value = pdl_thread_storage_get(key);
    pdl_array_t array = NULL;
    if (!value) {
        array = pdl_array_create(0);
        pdl_thread_storage_set(key, (void **)&array);
    } else {
        array = *value;
    }
    void *last = NULL;
    void *item = (__bridge void *)self;
    unsigned int count = pdl_array_count(array);
    if (count != 0) {
        last = pdl_array_get(array, count - 1);
    }
    pdl_array_add(array, item);
    return last != item;
}

- (void)finishRecording {
    void *key = recordKey();
    void **value = pdl_thread_storage_get(key);
    assert(value);
    pdl_array_t array = *value;
    void *last = NULL;
    void *item = (__bridge void *)self;
    unsigned int count = pdl_array_count(array);
    if (count != 0) {
        last = pdl_array_get(array, count - 1);
    }
    assert(last == item);
    pdl_array_remove(array, count - 1);
}

@end

NS_ASSUME_NONNULL_END
