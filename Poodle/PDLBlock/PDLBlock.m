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
    void *object = NULL;
    if (_imp) {
        object = ((void *(*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((void *(*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
    PDLBlockPop();
    return object;
}

static void *PDLBlockCopy(__unsafe_unretained id self, SEL _cmd, struct _NSZone *zone) {
    PDLImplementationInterceptorRecover(_cmd);
    PDLBlockPush();
    void *object = NULL;
    if (_imp) {
        object = ((void *(*)(id, SEL, struct _NSZone *))_imp)(self, _cmd, zone);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((void *(*)(struct objc_super *, SEL, struct _NSZone *))objc_msgSendSuper)(&su, _cmd, zone);
    }
    PDLBlockPop();
    return object;
}

BOOL PDLBlockCopying(void) {
    NSInteger count = 0;
    NSInteger *value = (NSInteger *)pdl_thread_storage_get(PDLBlockThreadStorageKey);
    if (value) {
        count = *value;
    }
    return count > 0;
}

static void(^_PDLBlockChecker)(void) = NULL;
void(^PDLBlockChecker(void))(void) {
    return _PDLBlockChecker;
}

void PDLBlockSetChecker(void(^checker)(void)) {
    _PDLBlockChecker = checker;
}

BOOL PDLBlockCopyRecordEnable(void) {
    pdl_thread_storage_register(PDLBlockThreadStorageKey, NULL);
    if (!pdl_thread_storage_enabled()) {
        return NO;
    }

    Class mallocBlockClass = objc_getClass("__NSMallocBlock__");
    Class stackBlockClass = objc_getClass("__NSStackBlock__");
    SEL copySelector = sel_registerName("copyWithZone:");
    BOOL ret = [mallocBlockClass pdl_interceptSelector:copySelector withInterceptorImplementation:(IMP)&PDLBlockCopy isStructRet:@(NO) addIfNotExistent:YES data:NULL];
    ret &= [stackBlockClass pdl_interceptSelector:copySelector withInterceptorImplementation:(IMP)&PDLBlockCopy isStructRet:@(NO) addIfNotExistent:YES data:NULL];
    return ret;
}

@implementation NSObject (PDLBlock)

static void *PDLBlockRetainObject(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    void *object = nil;
    if (_imp) {
        object = ((void *(*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((void *(*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
    BOOL copying = PDLBlockCopying();
    if (copying) {
        void(^callback)(void *) = (__bridge void (^)(void *))(_data);
        if (callback) {
            callback((__bridge void *)(self));
        }
    }
    return object;
}

+ (BOOL)pdl_enableBlockCheck:(void (^)(void *))callback {
    BOOL ret = [self pdl_interceptSelector:sel_registerName("retain") withInterceptorImplementation:(IMP)&PDLBlockRetainObject isStructRet:@(NO) addIfNotExistent:YES data:(__bridge_retained void *)callback];
    return ret;
}

@end
