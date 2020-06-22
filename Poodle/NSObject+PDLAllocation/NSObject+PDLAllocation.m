//
//  NSObject+PDLAllocation.m
//  Poodle
//
//  Created by Poodle on 2020/6/18.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "NSObject+PDLAllocation.h"
#import <os/lock.h>
#import "NSObject+PDLImplementationInterceptor.h"
#import "pdl_dictionary.h"
#import "pdl_backtrace.h"

#if __has_feature(objc_arc)
#error This file must be compiled with flag "-fno-objc-arc"
#endif

unsigned int pdl_allocation_record_hidden_count = 0;
unsigned int pdl_record_max_count = 0;

static PDLAllocationPolicy _policy;

#pragma mark - lock

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"

static pthread_mutex_t _mutex = PTHREAD_RECURSIVE_MUTEX_INITIALIZER;
//static os_unfair_lock _unfair_lock = OS_UNFAIR_LOCK_INIT;

static void pdl_allocation_lock() {
//    if (&os_unfair_lock_lock) {
//        os_unfair_lock_lock(&_unfair_lock);
//    } else {
        pthread_mutex_lock(&_mutex);
//    }
}

static void pdl_allocation_unlock() {
//    if (&os_unfair_lock_unlock) {
//        os_unfair_lock_unlock(&_unfair_lock);
//    } else {
        pthread_mutex_unlock(&_mutex);
//    }
}

#pragma mark - trace info

@interface PDLAllocationInfo : NSObject

@property (nonatomic, unsafe_unretained) id object;
@property (nonatomic, unsafe_unretained) Class cls;
@property (nonatomic, assign, readonly) pdl_backtrace_t backtraceAlloc;
@property (nonatomic, assign, readonly) pdl_backtrace_t backtraceDealloc;
@property (nonatomic, assign) BOOL live;
@property (nonatomic, assign) unsigned int hiddenCount;

@end

@implementation PDLAllocationInfo

- (instancetype)initWithObject:(__unsafe_unretained id)object {
    self = [super init];
    if (self) {
        _object = object;
        _cls = object_getClass(object);
        _live = YES;
        _hiddenCount = pdl_allocation_record_hidden_count;
    }
    return self;
}

- (void)dealloc {
    pdl_backtrace_destroy(_backtraceAlloc);
    pdl_backtrace_destroy(_backtraceDealloc);
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)recordAlloc {
    pdl_backtrace_destroy(_backtraceAlloc);
    _backtraceAlloc = nil;

    pdl_backtrace_t bt = pdl_backtrace_create();
    char name[64];
    snprintf(name, sizeof(name), "alloc_%s_%p(%s)", class_getName(_cls), _object, class_getName(object_getClass(_object)));
    pdl_backtrace_set_name(bt, name);
    pdl_backtrace_record(bt, _hiddenCount);
    _backtraceAlloc = bt;
}

- (void)clearAlloc {
    if (_backtraceAlloc) {
        pdl_backtrace_destroy(_backtraceAlloc);
        _backtraceAlloc = nil;
    }
}

- (void)recordDealloc {
    pdl_backtrace_destroy(_backtraceDealloc);
    _backtraceDealloc = nil;

    pdl_backtrace_t bt = pdl_backtrace_create();
    char name[64];
    snprintf(name, sizeof(name), "dealloc_%s_%p(%s)", class_getName(_cls), _object, class_getName(object_getClass(_object)));
    pdl_backtrace_set_name(bt, name);
    pdl_backtrace_record(bt, self.hiddenCount);
    _backtraceDealloc = bt;
}

- (void)clearDealloc {
    if (_backtraceDealloc) {
        pdl_backtrace_destroy(_backtraceDealloc);
        _backtraceDealloc = nil;
    }
}

#pragma mark - debug

+ (NSMutableSet *)uncaughtAllocClassesMap {
    static NSMutableSet *uncaughtAllocClassesMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uncaughtAllocClassesMap = [NSMutableSet set];
#if !__has_feature(objc_arc)
        [uncaughtAllocClassesMap retain];
#endif
    });
    return uncaughtAllocClassesMap;
}

+ (NSMutableSet *)doubleAllocClassesMap {
    static NSMutableSet *doubleAllocClassesMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        doubleAllocClassesMap = [NSMutableSet set];
#if !__has_feature(objc_arc)
        [doubleAllocClassesMap retain];
#endif
    });
    return doubleAllocClassesMap;
}

#pragma mark - storage

static void pdl_allocation_retain(void *info) {
    [(PDLAllocationInfo *)info retain];
}

static void pdl_allocation_release(void *info) {
    [(PDLAllocationInfo *)info release];
}

static pdl_dictionary_t pdl_allocation_map(void) {
    static pdl_dictionary_t _dictionary = NULL;
    if (!_dictionary) {
        pdl_dictionary_attr attr = PDL_DICTIONARY_ATTR_INIT;
        attr.count_limit = pdl_record_max_count;
        attr.value_callbacks.retain = &pdl_allocation_retain;
        attr.value_callbacks.release = &pdl_allocation_release;
        _dictionary = pdl_dictionary_create(&attr);
    }
    return _dictionary;
}

#pragma clang diagnostic pop

unsigned int pdl_allocation_map_count(void) {
    pdl_dictionary_t map = pdl_allocation_map();
    unsigned int count = pdl_dictionary_count(map);
    return count;
}

static void *pdl_allocation_map_get(void *key, bool lock) {
    if (lock) {
//        pdl_allocation_lock();
    }

    pdl_dictionary_t map = pdl_allocation_map();
    void *value = NULL;
    void **object = pdl_dictionary_get(map, key);
    if (object) {
        value = *object;
    }
    if (lock) {
//        pdl_allocation_unlock();
    }
    return value;
}

static void pdl_allocation_map_set(void *key, void *value) {
//    pdl_allocation_lock();
    pdl_dictionary_t map = pdl_allocation_map();
    pdl_dictionary_set(map, key, value);
//    pdl_allocation_unlock();
}

#pragma mark -

+ (BOOL)isObjectValid:(__unsafe_unretained id)object {
    if (!object) {
        return NO;
    }

    Class cls = object_getClass(object);
    if (cls == [PDLAllocationInfo class]) {
        return NO;
    }

    return YES;
}

+ (void)create:(__unsafe_unretained id)object {
    if (![self isObjectValid:object]) {
        return;
    }

    pdl_allocation_lock();

    PDLAllocationInfo *info = pdl_allocation_map_get(object, false);
    if (info) {
        [[PDLAllocationInfo doubleAllocClassesMap] addObject:object_getClass(object)];
    } else {
        info = [[PDLAllocationInfo alloc] initWithObject:object];
        pdl_allocation_map_set(object, info);
        [info release];
    }

    [info clearDealloc];
    [info recordAlloc];

    pdl_allocation_unlock();
}

+ (void)destroy:(__unsafe_unretained id)object {
    if (![self isObjectValid:object]) {
        return;
    }

    pdl_allocation_lock();

    PDLAllocationInfo *info = pdl_allocation_map_get(object, false);
    if (info) {
        if (info.live == false) {
            [info clearAlloc];
            [[PDLAllocationInfo uncaughtAllocClassesMap] addObject:object_getClass(object)];
        }
        info.live = false;
        switch (_policy) {
            case PDLAllocationPolicyLiveAllocations:
                pdl_allocation_map_set(object, NULL);
                break;
            case PDLAllocationPolicyAllocationAndFree:
                [info recordDealloc];
                break;

            default:
                break;
        }
    } else {
        [[PDLAllocationInfo uncaughtAllocClassesMap] addObject:object_getClass(object)];
    }

    pdl_allocation_unlock();
}

pdl_backtrace_t pdl_allocation_backtrace(__unsafe_unretained id object) {
    pdl_allocation_lock();

    PDLAllocationInfo *info = pdl_allocation_map_get(object, false);
    pdl_backtrace_t backtrace = NULL;
    if (info) {
        backtrace = pdl_backtrace_copy(info->_backtraceAlloc);
    }

    pdl_allocation_unlock();

    return backtrace;
}

pdl_backtrace_t pdl_deallocation_backtrace(__unsafe_unretained id object) {
    pdl_allocation_lock();

    PDLAllocationInfo *info = pdl_allocation_map_get(object, false);
    pdl_backtrace_t backtrace = NULL;
    if (info) {
        backtrace = pdl_backtrace_copy(info->_backtraceDealloc);
    }

    pdl_allocation_unlock();

    return backtrace;
}

@end

@implementation NSObject (PDLAllocation)

#pragma mark - hook

__unused static id pdl_alloc(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    id object = nil;
    if (_imp) {
        object = ((id (*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
    [PDLAllocationInfo create:object];
    return object;
}


__unused static id pdl_allocWithZone(__unsafe_unretained id self, SEL _cmd, struct _NSZone *zone) {
    PDLImplementationInterceptorRecover(_cmd);
    id object = nil;
    if (_imp) {
        object = ((id (*)(id, SEL, struct _NSZone *))_imp)(self, _cmd, zone);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((id (*)(struct objc_super *, SEL, struct _NSZone *))objc_msgSendSuper)(&su, _cmd, zone);
    }
    [PDLAllocationInfo create:object];
    return object;
}

__unused static id pdl_new(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    id object = nil;
    if (_imp) {
        object = ((id (*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
    [PDLAllocationInfo create:object];
    return object;
}

__unused static id pdl_init(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    id object = nil;
    if (_imp) {
        object = ((id (*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
    [PDLAllocationInfo create:object];
    return object;
}

__unused static void pdl_dealloc(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    __unsafe_unretained id object = self;
    [PDLAllocationInfo destroy:object];
    if (_imp) {
        ((void (*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        ((void (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
}

#pragma mark -

+ (BOOL)pdl_enableAllocation:(PDLAllocationPolicy)policy {
    _policy = policy;

    static BOOL ret = YES;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [NSObject class];
        id meta = object_getClass(cls);
//        ret &= [meta pdl_interceptSelector:@selector(alloc) withInterceptorImplementation:(IMP)&pdl_alloc isStructRet:NO addIfNotExistent:YES data:NULL];
        ret &= [meta pdl_interceptSelector:@selector(allocWithZone:) withInterceptorImplementation:(IMP)&pdl_allocWithZone isStructRet:NO addIfNotExistent:YES data:NULL];
        ret &= [meta pdl_interceptSelector:@selector(new) withInterceptorImplementation:(IMP)&pdl_new isStructRet:NO addIfNotExistent:YES data:NULL];
//        ret = [cls pdl_interceptSelector:@selector(init) withInterceptorImplementation:(IMP)&pdl_init isStructRet:NO addIfNotExistent:YES data:NULL];
        ret &= [cls pdl_interceptSelector:sel_registerName("dealloc") withInterceptorImplementation:(IMP)&pdl_dealloc isStructRet:NO addIfNotExistent:YES data:NULL];
    });
    return ret;
}

@end
