//
//  pdl_allocation.m
//  Poodle
//
//  Created by Poodle on 2020/6/18.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "pdl_allocation.h"
#import <os/lock.h>
#import "NSObject+PDLImplementationInterceptor.h"
#import "pdl_dictionary.h"
#import "pdl_backtrace.h"

#if __has_feature(objc_arc)
#error This file must be compiled with flag "-fno-objc-arc"
#endif

static unsigned int _pdl_allocation_record_alloc_hidden_count = 2;
unsigned int pdl_allocation_record_alloc_hidden_count(void) {
    return _pdl_allocation_record_alloc_hidden_count;
}
void pdl_allocation_set_record_alloc_hidden_count(unsigned int hidden_count) {
    _pdl_allocation_record_alloc_hidden_count = hidden_count;
}
static unsigned int _pdl_allocation_record_dealloc_hidden_count = 2;
unsigned int pdl_allocation_record_dealloc_hidden_count(void) {
    return _pdl_allocation_record_dealloc_hidden_count;
}
void pdl_allocation_set_record_dealloc_hidden_count(unsigned int hidden_count) {
    _pdl_allocation_record_dealloc_hidden_count = hidden_count;
}

static unsigned int _pdl_allocation_record_max_object_count = 0;
unsigned int pdl_allocation_record_max_object_count(void) {
    return _pdl_allocation_record_max_object_count;
}
void pdl_allocation_set_record_max_object_count(unsigned int max_count) {
    _pdl_allocation_record_max_object_count = max_count;
}

static bool _enabled = false;
static pdl_allocation_policy _policy = -1;
static Class _pdl_allocation_class = NULL;

#pragma mark - lock

static pthread_mutex_t _mutex = PTHREAD_RECURSIVE_MUTEX_INITIALIZER;

static void pdl_allocation_lock() {
    pthread_mutex_lock(&_mutex);
}

static void pdl_allocation_unlock() {
    pthread_mutex_unlock(&_mutex);
}

#pragma mark - trace info

typedef struct {
    Class isa;
    
#define PDL_ALLOCATION_INFO \
    __unsafe_unretained id object; \
    __unsafe_unretained Class cls; \
    pdl_backtrace_t backtrace_alloc; \
    pdl_backtrace_t backtrace_dealloc; \
    bool live;

    PDL_ALLOCATION_INFO;
} pdl_allocation_info;

static pdl_allocation_info *pdl_allocation_info_create(__unsafe_unretained id object) {
    pdl_allocation_info *info = malloc(sizeof(pdl_allocation_info));
    if (!info) {
        return NULL;
    }

    info->isa = _pdl_allocation_class;
    info->object = object;
    info->cls = object_getClass(object);
    info->backtrace_alloc = NULL;
    info->backtrace_dealloc = NULL;
    info->live = true;

    return info;
}

static void pdl_allocation_info_destroy(pdl_allocation_info *info) {
    pdl_backtrace_destroy(info->backtrace_alloc);
    pdl_backtrace_destroy(info->backtrace_dealloc);
    free(info);
}

__attribute__((noinline))
static void pdl_allocation_record_alloc(pdl_allocation_info *info) {
    pdl_backtrace_destroy(info->backtrace_alloc);
    info->backtrace_alloc = nil;

    pdl_backtrace_t bt = pdl_backtrace_create();
    char name[64];
    snprintf(name, sizeof(name), "alloc_%s_%p(%s)", class_getName(info->cls), info->object, class_getName(object_getClass(info->object)));
    pdl_backtrace_set_name(bt, name);
    pdl_backtrace_record_attr attr = PDL_BACKTRACE_RECORD_ATTR_INIT;
    attr.hidden_count = _pdl_allocation_record_alloc_hidden_count;
    pdl_backtrace_record(bt, &attr);
    info->backtrace_alloc = bt;
}

//static void pdl_allocation_clear_alloc(pdl_allocation_info *info) {
//    if (info->backtrace_alloc) {
//        pdl_backtrace_destroy(info->backtrace_alloc);
//        info->backtrace_alloc = nil;
//    }
//}

__attribute__((noinline))
static void pdl_allocation_record_dealloc(pdl_allocation_info *info) {
    pdl_backtrace_destroy(info->backtrace_dealloc);
    info->backtrace_dealloc = nil;

    pdl_backtrace_t bt = pdl_backtrace_create();
    char name[64];
    snprintf(name, sizeof(name), "dealloc_%s_%p(%s)", class_getName(info->cls), info->object, class_getName(object_getClass(info->object)));
    pdl_backtrace_set_name(bt, name);
    pdl_backtrace_record_attr attr = PDL_BACKTRACE_RECORD_ATTR_INIT;
    attr.hidden_count = _pdl_allocation_record_dealloc_hidden_count;
    pdl_backtrace_record(bt, &attr);
    info->backtrace_dealloc = bt;
}

//static void pdl_allocation_clear_dealloc(pdl_allocation_info *info) {
//    if (info->backtrace_dealloc) {
//        pdl_backtrace_destroy(info->backtrace_dealloc);
//        info->backtrace_dealloc = nil;
//    }
//}

#pragma mark - debug

@interface pdl_allocation : NSObject {
    PDL_ALLOCATION_INFO;
}

@end

@implementation pdl_allocation

- (NSString *)description {
    pdl_allocation_info *info = (typeof(info))self;
    return [NSString stringWithFormat:@"<pdl_allocation: %p; object class = %s; object = <%s: %p>; live = %d; alloc = %@; dealloc = %@>", info, class_getName(info->cls), class_getName(object_getClass(info->object)), info->object, info->live, info->backtrace_alloc, info->backtrace_dealloc];
}

@end

static NSMutableSet * pdl_allocation_uncaught_alloc_classes(void) {
    static NSMutableSet *uncaught_alloc_classes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uncaught_alloc_classes = [NSMutableSet set];
#if !__has_feature(objc_arc)
        [uncaught_alloc_classes retain];
#endif
    });
    return uncaught_alloc_classes;
}

static NSMutableSet *pdl_allocation_double_alloc_classes(void) {
    static NSMutableSet *double_alloc_classes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        double_alloc_classes = [NSMutableSet set];
#if !__has_feature(objc_arc)
        [double_alloc_classes retain];
#endif
    });
    return double_alloc_classes;
}

#pragma mark - storage

static pdl_dictionary_t pdl_allocation_map(void) {
    static pdl_dictionary_t _dictionary = NULL;
    if (!_dictionary) {
        pdl_dictionary_attr attr = PDL_DICTIONARY_ATTR_INIT;
        attr.count_limit = _pdl_allocation_record_max_object_count;
        _dictionary = pdl_dictionary_create(&attr);
    }
    return _dictionary;
}

unsigned int pdl_allocation_map_count(void) {
    pdl_dictionary_t map = pdl_allocation_map();
    unsigned int count = pdl_dictionary_count(map);
    return count;
}

static void *pdl_allocation_map_get(__unsafe_unretained id key) {
    pdl_dictionary_t map = pdl_allocation_map();
    void *value = NULL;
    void **object = pdl_dictionary_get(map, (__bridge void *)key);
    if (object) {
        value = *object;
    }
    return value;
}

static void pdl_allocation_map_set(__unsafe_unretained id key, void *value) {
    pdl_dictionary_t map = pdl_allocation_map();
    pdl_allocation_info *info = pdl_dictionary_set(map, (__bridge void *)key, value ? &value : NULL);
    if (info) {
        pdl_allocation_info_destroy(info);
    }
}

#pragma mark -

__attribute__((noinline))
static void pdl_allocation_create(__unsafe_unretained id object) {
    if (!object) {
        return;
    }

    if (malloc_size(object) == 0) {
        return;
    }

    if (_policy == pdl_allocation_policy_zombie_only) {
        return;
    }

    pdl_allocation_lock();

    pdl_allocation_info *info = pdl_allocation_map_get(object);
    if (info) {
        if (info->live) {
            [pdl_allocation_double_alloc_classes() addObject:object_getClass(object)];
        } else {
            info->live = true;
        }
    } else {
        info = pdl_allocation_info_create(object);
        if (!info) {
            pdl_allocation_unlock();
            return;
        }

        pdl_allocation_map_set(object, info);
    }

//    pdl_allocation_clear_dealloc(info);
    pdl_allocation_record_alloc(info);

    pdl_allocation_unlock();
}

__attribute__((noinline))
static void pdl_allocation_destroy(__unsafe_unretained id object) {
    if (!object) {
        return;
    }

    if (malloc_size(object) == 0) {
        assert(0);
    }

    if (_policy == pdl_allocation_policy_zombie_only) {
        return;
    }

    pdl_allocation_lock();

    pdl_allocation_info *info = pdl_allocation_map_get(object);
    if (info) {
        if (info->live == false) {
//            pdl_allocation_clear_alloc(info);
            [pdl_allocation_uncaught_alloc_classes() addObject:object_getClass(object)];
        }
        info->live = false;
        switch (_policy) {
            case pdl_allocation_policy_live_allocations:
                pdl_allocation_map_set(object, NULL);
                pdl_allocation_info_destroy(info);
                break;
            case pdl_allocation_policy_allocation_and_free:
                pdl_allocation_record_dealloc(info);
                break;

            default:
                break;
        }
    } else {
        [pdl_allocation_uncaught_alloc_classes() addObject:object_getClass(object)];
    }

    pdl_allocation_unlock();
}

pdl_backtrace_t pdl_allocation_backtrace(__unsafe_unretained id object) {
    pdl_allocation_lock();

    if (!_enabled) {
        pdl_allocation_unlock();
        return NULL;
    }

    pdl_allocation_info *info = pdl_allocation_map_get(object);
    pdl_backtrace_t backtrace = NULL;
    if (info) {
        backtrace = pdl_backtrace_copy(info->backtrace_alloc);
    }

    pdl_allocation_unlock();

    return backtrace;
}

pdl_backtrace_t pdl_deallocation_backtrace(__unsafe_unretained id object) {
    pdl_allocation_lock();

    if (!_enabled) {
        pdl_allocation_unlock();
        return NULL;
    }

    pdl_allocation_info *info = pdl_allocation_map_get(object);
    pdl_backtrace_t backtrace = NULL;
    if (info) {
        backtrace = pdl_backtrace_copy(info->backtrace_dealloc);
    }

    pdl_allocation_unlock();

    return backtrace;
}

#pragma mark - zombie

static bool _pdl_zombie_available = false;
static unsigned int _pdl_allocation_zombie_duration = 0;
unsigned int pdl_allocation_zombie_duration(void) {
    return _pdl_allocation_zombie_duration;
}

void pdl_allocation_set_zombie_duration(unsigned int zombie_duration) {
    _pdl_allocation_zombie_duration = zombie_duration;
}

static dispatch_queue_t _pdl_allocation_zombie_queue = NULL;
static dispatch_queue_t pdl_allocation_zombie_queue(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pdl_allocation_zombie_queue = dispatch_queue_create("pdl_allocation_zombie_queue", DISPATCH_QUEUE_SERIAL);
        if (!_pdl_allocation_zombie_queue) {
            _pdl_allocation_zombie_queue = dispatch_get_global_queue(0, 0);
        }
    });
    return _pdl_allocation_zombie_queue;
}

static void pdl_allocation_make_zombie(void *object) {
    Class cls = object_getClass(object);
    const char *class_name = class_getName(cls);
    char *root_zombie_class_name = "_NSZombie_";
    Class root_zombie_class = objc_lookUpClass(root_zombie_class_name);
    unsigned long len = strlen(root_zombie_class_name) + strlen(class_name) + 1;
    char zombie_class_name[len];
    zombie_class_name[0] = '\0';
    strcat(zombie_class_name, root_zombie_class_name);
    strcat(zombie_class_name, class_name);
    Class zombie_class = objc_lookUpClass(zombie_class_name);
    if (!zombie_class) {
        zombie_class = objc_duplicateClass(root_zombie_class, zombie_class_name, 0);
    }
    objc_destructInstance(object);
    object_setClass(object, zombie_class);
}

bool pdl_allocation_is_zombie(__unsafe_unretained id object) {
    Class cls = object_getClass(object);
    const char *name = class_getName(cls);
    return strncmp(name, "_NSZombie_", strlen("_NSZombie_")) == 0;
}

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
    pdl_allocation_create(object);
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
    pdl_allocation_create(object);
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
    pdl_allocation_create(object);
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
    pdl_allocation_create(object);
    return object;
}

__unused static void pdl_dealloc(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    __unsafe_unretained id object = self;
    pdl_allocation_destroy(object);

    unsigned int zombie_duration = _pdl_allocation_zombie_duration;
    if (_pdl_zombie_available && zombie_duration > 0) {
        pdl_allocation_make_zombie(object);
        dispatch_block_t block = ^{
            if (_imp) {
                ((void (*)(id, SEL))_imp)(self, _cmd);
            } else {
                struct objc_super su = {self, class_getSuperclass(_class)};
                ((void (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
            }
        };
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, pdl_allocation_zombie_queue());
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, zombie_duration * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
        __block bool start = NO;
        dispatch_source_set_event_handler(timer, ^{
            if (!start) {
                start = YES;
                return;
            }

            block();
            dispatch_source_cancel(timer);
            dispatch_release(timer);
        });
        dispatch_resume(timer);

        return;
    }

    if (_imp) {
        ((void (*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        ((void (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
}

#pragma mark -

bool pdl_allocation_enable(pdl_allocation_policy policy) {
    static BOOL ret = YES;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _policy = policy;
        pdl_allocation_lock();
        _pdl_allocation_class = [pdl_allocation class];
        _pdl_zombie_available = objc_lookUpClass("_NSZombie_") != nil;

        Class cls = [NSObject class];
        id meta = object_getClass(cls);
//        ret = ret && [meta pdl_interceptSelector:@selector(alloc) withInterceptorImplementation:(IMP)&pdl_alloc isStructRet:nil addIfNotExistent:YES data:NULL];
        ret = ret && [meta pdl_interceptSelector:@selector(allocWithZone:) withInterceptorImplementation:(IMP)&pdl_allocWithZone isStructRet:nil addIfNotExistent:YES data:NULL];
        ret = ret && [meta pdl_interceptSelector:@selector(new) withInterceptorImplementation:(IMP)&pdl_new isStructRet:nil addIfNotExistent:YES data:NULL];
//        ret = [cls pdl_interceptSelector:@selector(init) withInterceptorImplementation:(IMP)&pdl_init isStructRet:nil addIfNotExistent:YES data:NULL];
        ret = ret && [cls pdl_interceptSelector:@selector(dealloc) withInterceptorImplementation:(IMP)&pdl_dealloc isStructRet:nil addIfNotExistent:YES data:NULL];

        _enabled = ret;

        pdl_allocation_unlock();
    });
    return ret;
}
