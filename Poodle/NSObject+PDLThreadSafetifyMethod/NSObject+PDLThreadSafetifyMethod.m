//
//  NSObject+PDLThreadSafetifyMethod.m
//  Poodle
//
//  Created by Poodle on 2020/7/15.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "NSObject+PDLThreadSafetifyMethod.h"
#import <objc/runtime.h>
#import <objc/objc-sync.h>
#import <pthread.h>
#import "NSObject+PDLMethod.h"

__unused __attribute__((visibility("hidden"))) void the_table_of_contents_is_empty(void) {}

@implementation NSObject (PDLThreadSafetifyMethod)

static pthread_mutex_t _lock = PTHREAD_MUTEX_INITIALIZER;
static id pdl_threadSafeMethodLock(__unsafe_unretained id self) {
    pthread_mutex_lock(&_lock);
    id lock = objc_getAssociatedObject(self, &pdl_threadSafeMethodLock);
    if (lock == nil) {
        lock = [[NSObject alloc] init];
        objc_setAssociatedObject(self, &pdl_threadSafeMethodLock, lock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    pthread_mutex_unlock(&_lock);
    return lock;
}

__unused static void PDLThreadSafetifyMethodBefore(__unsafe_unretained id self, SEL _cmd) {
    objc_sync_enter(pdl_threadSafeMethodLock(self));
}

__unused static void PDLThreadSafetifyMethodAfter(__unsafe_unretained id self, SEL _cmd) {
    objc_sync_exit(pdl_threadSafeMethodLock(self));
}

#pragma mark - public methods

+ (NSInteger)pdl_threadSafetifyMethods:(BOOL(^)(SEL selector))filter {
    NSInteger ret = 0;
#ifdef __arm64__
    SEL retain = sel_registerName("retain");
    SEL release = sel_registerName("release");
    SEL autorelease = sel_registerName("autorelease");
    SEL dealloc = sel_registerName("dealloc");

    ret = [self pdl_addInstanceMethodsBeforeAction:(IMP)&PDLThreadSafetifyMethodBefore afterAction:(IMP)&PDLThreadSafetifyMethodAfter methodFilter:^BOOL(SEL  _Nonnull selector) {
        if (sel_isEqual(selector, retain)) {
            return NO;
        }
        if (sel_isEqual(selector, release)) {
            return NO;
        }
        if (sel_isEqual(selector, autorelease)) {
            return NO;
        }
        if (sel_isEqual(selector, dealloc)) {
            return NO;
        }

        if (filter) {
            return filter(selector);
        }
        return YES;
    }];
#endif
    return ret;
}

@end
