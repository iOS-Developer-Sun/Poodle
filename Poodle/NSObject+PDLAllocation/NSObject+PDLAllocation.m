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

@implementation NSObject (PDLAllocation)

static PDLAllocationPolicy _policy;

#pragma mark - lock

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"

static pthread_mutex_t _mutex = PTHREAD_MUTEX_INITIALIZER;
static os_unfair_lock _unfair_lock = OS_UNFAIR_LOCK_INIT;

static void pdl_allocation_lock() {
    if (&os_unfair_lock_lock) {
        os_unfair_lock_lock(&_unfair_lock);
    } else {
        pthread_mutex_lock(&_mutex);
    }
}

static void pdl_allocation_unlock() {
    if (&os_unfair_lock_unlock) {
        os_unfair_lock_unlock(&_unfair_lock);
    } else {
        pthread_mutex_unlock(&_mutex);
    }
}

#pragma mark - storage

static pdl_dictionary_t pdl_allocation_map(void) {
    static pdl_dictionary_t _dictionary = NULL;
    if (!_dictionary) {
        _dictionary = pdl_dictionary_create();
    }
    return _dictionary;
}

#pragma clang diagnostic pop

void pdl_allocation_map_print(void) {
    pdl_dictionary_t map = pdl_allocation_map();
    void **keys = NULL;
    unsigned int count = 0;
    pdl_dictionary_getAllKeys(map, &keys, &count);
    for (unsigned int i = 0; i < count; i++) {
        void *key = keys[i];
        void *value = NULL;
        void **object = pdl_dictionary_objectForKey(map, key);
        if (object) {
            value = *object;
        }
        printf("%d: %p->%p\n", i, key, value);
    }
    free(keys);
}

unsigned int pdl_allocation_map_count(void) {
    pdl_dictionary_t map = pdl_allocation_map();
    unsigned int count = pdl_dictionary_count(map);
    return count;
}

static void *pdl_allocation_map_get(void *key, bool lock) {
    if (lock) {
        pdl_allocation_lock();
    }

    pdl_dictionary_t map = pdl_allocation_map();
    void *value = NULL;
    void **object = pdl_dictionary_objectForKey(map, key);
    if (object) {
        value = *object;
    }
    if (lock) {
        pdl_allocation_unlock();
    }
    return value;
}

static void pdl_allocation_map_set(void *key, void *value) {
    pdl_allocation_lock();
    pdl_dictionary_t map = pdl_allocation_map();
    pdl_dictionary_setObjectForKey(map, value, key);
    pdl_allocation_unlock();
}

#pragma mark - record hidden count

static bool _pdl_allocationRecordHiddenCount = 0;
+ (unsigned int)pdl_allocationRecordHiddenCount {
    return _pdl_allocationRecordHiddenCount;
}

+ (void)setPdl_allocationRecordHiddenCount:(unsigned int)pdl_allocationRecordHiddenCount {
    _pdl_allocationRecordHiddenCount = pdl_allocationRecordHiddenCount;
}

#pragma mark - trace info

#define PDL_ALLOCATION_INFO_MAGIC 0x4c4450

typedef struct pdl_allocation_info {
    unsigned long magic;
    void *object;
    struct pdl_backtrace *bt;
    struct pdl_backtrace *fbt;
    bool live;
} pdl_allocation_info, *pdl_allocation_info_t;

static void pdl_allocation_init(void *object) {
    if (!object) {
        return;
    }

    pdl_allocation_info_t info = pdl_allocation_map_get(object, true);
    if (info) {
        assert(info->magic == PDL_ALLOCATION_INFO_MAGIC);
        assert(info->object == object);
        assert(info->bt);

//        if (info->live) {
//            pdl_backtrace_thread_show(info->bt, true);
//            pdl_backtrace_thread_show(info->fbt, true);
//            printf("pdl_allocation_error init %p is live\n", object);
//            assert(info->live == false);
//        }
        pdl_backtrace_destroy(info->bt);
        info->bt = NULL;
        pdl_backtrace_destroy(info->fbt);
        info->fbt = NULL;
    } else {
        info = malloc(sizeof(pdl_allocation_info));
        info->magic = PDL_ALLOCATION_INFO_MAGIC;
        info->object = object;
        info->fbt = NULL;
        pdl_allocation_map_set(object, info);
    }

    info->bt = pdl_backtrace_create();
    assert(info->bt);
    char name[32];
    snprintf(name, sizeof(name), "allocation_%p", object);
    pdl_backtrace_set_name(info->bt, name);
    pdl_backtrace_record(info->bt, _pdl_allocationRecordHiddenCount);
    info->live = true;
    printf("%s %p %s\n", "pdl_allocation_init", object, class_getName(object_getClass(object)));
}

NSMutableSet *s = nil;

static void pdl_allocation_destroy(void *object) {
    if (!object) {
        return;
    }

    pdl_allocation_info_t info = (pdl_allocation_info_t)pdl_allocation_map_get(object, true);
    if (info) {
        assert(info->magic == PDL_ALLOCATION_INFO_MAGIC);
        assert(info->object == object);
        assert(info->bt);
        if (info->live == false) {
            pdl_backtrace_thread_show(info->bt, true);
            pdl_backtrace_thread_show(info->fbt, true);
            printf("pdl_allocation_error destroy %p is not live\n", object);
            assert(0);
        }
        info->live = false;
        printf("%s %p %s %d\n", "pdl_allocation_destroy", object, class_getName(object_getClass(object)), true);
        switch (_policy) {
            case PDLAllocationPolicyLiveAllocations:
                pdl_backtrace_destroy(info->bt);
                free(info);
                pdl_allocation_map_set(object, NULL);
                assert(pdl_allocation_map_get(object, true) == NULL);
                break;
            case PDLAllocationPolicyAllocationAndFree:
                pdl_backtrace_destroy(info->fbt);
                info->fbt = pdl_backtrace_create();
                char name[32];
                snprintf(name, sizeof(name), "free_%p", object);
                pdl_backtrace_set_name(info->fbt, name);
                pdl_backtrace_record(info->fbt, _pdl_allocationRecordHiddenCount);
                break;

            default:
                break;
        }
    } else {
        printf("pdl_allocation_error destroy %p %s no info\n", object, class_getName(object_getClass(object)));
        if (!s) {
            s = [[NSMutableSet set] retain];
        }
        [s addObject:object_getClass(object)];
//        assert(0);
    }
}

static id pdl_alloc(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    id object = nil;
    if (_imp) {
        object = ((id (*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
    pdl_allocation_init(object);
    return object;
}


static id pdl_allocWithZone(__unsafe_unretained id self, SEL _cmd, struct _NSZone *zone) {
    PDLImplementationInterceptorRecover(_cmd);
    id object = nil;
    if (_imp) {
        object = ((id (*)(id, SEL, struct _NSZone *))_imp)(self, _cmd, zone);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((id (*)(struct objc_super *, SEL, struct _NSZone *))objc_msgSendSuper)(&su, _cmd, zone);
    }
    pdl_allocation_init(object);
    return object;
}

static id pdl_new(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    id object = nil;
    if (_imp) {
        object = ((id (*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
    pdl_allocation_init(object);
    return object;
}

static id pdl_init(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    id object = nil;
    if (_imp) {
        object = ((id (*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
    pdl_allocation_init(object);
    return object;
}

static void pdl_dealloc(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    id object = self;
    pdl_allocation_destroy(object);
    if (_imp) {
        ((void (*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        ((void (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
}

+ (BOOL)pdl_enableAllocation:(PDLAllocationPolicy)policy {
    policy = _policy;

    static BOOL ret = YES;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [NSObject class];
        id meta = object_getClass(cls);
//        ret &= [meta pdl_interceptSelector:@selector(alloc) withInterceptorImplementation:(IMP)&pdl_alloc isStructRet:NO addIfNotExistent:YES data:NULL];
        ret &= [meta pdl_interceptSelector:@selector(allocWithZone:) withInterceptorImplementation:(IMP)&pdl_allocWithZone isStructRet:NO addIfNotExistent:YES data:NULL];
        ret &= [meta pdl_interceptSelector:@selector(new) withInterceptorImplementation:(IMP)&pdl_new isStructRet:NO addIfNotExistent:YES data:NULL];
//        ret = [cls pdl_interceptSelector:@selector(init) withInterceptorImplementation:(IMP)&pdl_init isStructRet:NO addIfNotExistent:YES data:NULL];
        ret &= [cls pdl_interceptSelector:@selector(dealloc) withInterceptorImplementation:(IMP)&pdl_dealloc isStructRet:NO addIfNotExistent:YES data:NULL];
    });
    return ret;
}

@end
