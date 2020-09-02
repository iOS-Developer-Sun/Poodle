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

static id pdl_threadSafeMethodLock(__unsafe_unretained id self) {
    static pthread_mutex_t _lock = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_lock(&_lock);
    id lock = objc_getAssociatedObject(self, &pdl_threadSafeMethodLock);
    if (lock == nil) {
        lock = class_createInstance(objc_getClass("NSObject"), 0);
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

    ret = [self pdl_addInstanceMethodsBeforeAction:(IMP)&PDLThreadSafetifyMethodBefore afterAction:(IMP)&PDLThreadSafetifyMethodAfter methodFilter:^BOOL(SEL  _Nonnull selector) {
        if (sel_isEqual(selector, sel_registerName("retain"))) {return NO;}
        if (sel_isEqual(selector, sel_registerName("release"))) {return NO;}
        if (sel_isEqual(selector, sel_registerName("autorelease"))) {return NO;}
        if (sel_isEqual(selector, sel_registerName("dealloc"))) {return NO;}
        if (sel_isEqual(selector, sel_registerName(".cxx_destruct"))) {return NO;}
        if (sel_isEqual(selector, sel_registerName("_isDeallocating"))) {return NO;}
        if (sel_isEqual(selector, sel_registerName("_tryRetain"))) {return NO;}
        if (sel_isEqual(selector, sel_registerName("allowsWeakReference"))) {return NO;}
        if (sel_isEqual(selector, sel_registerName("retainWeakReference"))) {return NO;}

        if (filter) {
            return filter(selector);
        }
        return YES;
    }];

    return ret;
}

@end
