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

static BOOL(*_Nullable PDLBlockCopyRecordFilter)(void *block) = NULL;
static void *PDLBlockThreadStorageKey = &PDLBlockThreadStorageKey;

static void PDLBlockDestroy(pdl_array_t array) {
    assert(array);
    assert(pdl_array_count(array) == 0);
    pdl_array_destroy(array);
}

static void PDLBlockPush(void *block) {
    pdl_array_t blocks = NULL;
    pdl_array_t *value = (pdl_array_t *)pdl_thread_storage_get(PDLBlockThreadStorageKey);
    if (value) {
        blocks = *value;
    } else {
        blocks = pdl_array_create(0);
        value = &blocks;
        pdl_thread_storage_set(PDLBlockThreadStorageKey, (void **)value);
    }
    assert(pdl_array_count(blocks) >= 0);
    pdl_array_add(blocks, block);
}

static void *PDLBlockPop(void) {
    pdl_array_t *value = (pdl_array_t *)pdl_thread_storage_get(PDLBlockThreadStorageKey);
    assert(value);
    pdl_array_t blocks = *value;
    unsigned int count = pdl_array_count(blocks);
    assert(count > 0);
    void *block = pdl_array_get(blocks, count - 1);
    pdl_array_remove(blocks, count - 1);
    return block;
}

static void *PDLBlockCopy(__unsafe_unretained id self, SEL _cmd, struct _NSZone *zone) {
    PDLImplementationInterceptorRecover(_cmd);
    void *block = (__bridge void *)self;
    BOOL valid = YES;
    if (PDLBlockCopyRecordFilter) {
        valid = PDLBlockCopyRecordFilter(block);
    }
    if (valid) {
        PDLBlockPush(block);
    }
    void *object = NULL;
    if (_imp) {
        object = ((void *(*)(id, SEL, struct _NSZone *))_imp)(self, _cmd, zone);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((void *(*)(struct objc_super *, SEL, struct _NSZone *))objc_msgSendSuper)(&su, _cmd, zone);
    }
    if (valid) {
        void *popped = PDLBlockPop();
        assert(block == popped);
    }
    return object;
}

BOOL PDLBlockCopying(void) {
    unsigned int count = 0;
    pdl_array_t blocks = PDLBlockCopyingBlocks();
    if (blocks) {
        count = pdl_array_count(blocks);
    }
    return count > 0;
}

pdl_array_t PDLBlockCopyingBlocks(void) {
    pdl_array_t array = NULL;
    pdl_array_t *value = (pdl_array_t *)pdl_thread_storage_get(PDLBlockThreadStorageKey);
    if (value) {
        array = *value;
    }
    return array;
}

static void(^_PDLBlockChecker)(void) = NULL;

void(^PDLBlockChecker(void))(void) {
    return _PDLBlockChecker;
}

void PDLBlockSetChecker(void(^checker)(void)) {
    _PDLBlockChecker = checker;
}

BOOL PDLBlockCopyRecordEnable(BOOL(*_Nullable filter)(void *block)) {
    pdl_thread_storage_register(PDLBlockThreadStorageKey, &PDLBlockDestroy);
    if (!pdl_thread_storage_enabled()) {
        return NO;
    }

    PDLBlockCopyRecordFilter = filter;
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
    unsigned int count = 0;
    pdl_array_t blocks = PDLBlockCopyingBlocks();
    if (blocks) {
        count = pdl_array_count(blocks);
    }
    if (count > 0) {
        void *block = pdl_array_get(blocks, count - 1);
        void(^callback)(void *, void *) = (__bridge void (^)(void *, void *))(_data);
        if (callback) {
            callback((__bridge void *)self, block);
        }
    }
    return object;
}

+ (BOOL)pdl_enableBlockCheck:(void (^)(void *object, void *block))callback {
    BOOL ret = [self pdl_interceptSelector:sel_registerName("retain") withInterceptorImplementation:(IMP)&PDLBlockRetainObject isStructRet:@(NO) addIfNotExistent:YES data:(__bridge_retained void *)callback];
    return ret;
}

@end
