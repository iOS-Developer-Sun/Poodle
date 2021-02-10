//
//  PDLBlock.m
//  Poodle
//
//  Created by Poodle on 2021/2/3.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLBlock.h"
#import "NSObject+PDLImplementationInterceptor.h"
#import "pdl_thread_storage.h"

@implementation PDLBlock

static void *PDLBlockThreadStorageKey = &PDLBlockThreadStorageKey;

static void PDLBlockPush(void) {
    NSInteger count = 0;
    NSInteger *value = (NSInteger *)pdl_thread_storage_get(PDLBlockThreadStorageKey);
    if (value) {
        count = *value;
    }
    assert(count >= 0);
    count++;
    value = &count;
    pdl_thread_storage_set(PDLBlockThreadStorageKey, (void **)value);
}

static void PDLBlockPop(void) {
    NSInteger *value = (NSInteger *)pdl_thread_storage_get(PDLBlockThreadStorageKey);
    assert(value);
    NSInteger count = *value;
    count--;
    value = &count;
    assert(count >= 0);
    pdl_thread_storage_set(PDLBlockThreadStorageKey, (void **)value);
}

static void *PDLBlockRetain(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    PDLBlockPush();
    void *object = nil;
    if (_imp) {
        object = ((void *(*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((void *(*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
    PDLBlockPop();
    return object;
}

static BOOL PDLBlockCopying(void) {
    NSInteger count = 0;
    NSInteger *value = (NSInteger *)pdl_thread_storage_get(PDLBlockThreadStorageKey);
    if (value) {
        count = *value;
    }
    return count > 0;
}

static void *PDLBlockRetainObject(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    void *object = nil;
    if (_imp) {
        object = ((void *(*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((void *(*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
    assert(!PDLBlockCopying());
    return object;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pdl_thread_storage_register(PDLBlockThreadStorageKey, NULL);
        if (pdl_thread_storage_enabled()) {
            BOOL ret = [objc_getClass("__NSMallocBlock__") pdl_interceptSelector:sel_registerName("retain") withInterceptorImplementation:(IMP)&PDLBlockRetain isStructRet:@(NO) addIfNotExistent:YES data:NULL];
            ret &= [UIViewController pdl_interceptSelector:sel_registerName("retain") withInterceptorImplementation:(IMP)&PDLBlockRetainObject isStructRet:@(NO) addIfNotExistent:YES data:NULL];
            assert(ret);
        }
    });
}

@end
