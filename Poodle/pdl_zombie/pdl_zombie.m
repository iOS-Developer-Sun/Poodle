//
//  pdl_zombie.m
//  Poodle
//
//  Created by Poodle on 2021/7/9.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "pdl_zombie.h"
#import "NSObject+PDLImplementationInterceptor.h"

#if __has_feature(objc_arc)
#error This file must be compiled with flag "-fno-objc-arc"
#endif

typedef struct {
    dispatch_source_t timer;
    __unsafe_unretained id object;
    int count;
} pdl_zombie_timer_context;

static const char *pdl_zombie_class_name = "_NSZombie_";
static BOOL(*_pdl_zombie_filter)(__unsafe_unretained id object) = NULL;
static NSNumber *_pdl_zombie_enabled = nil;
static NSNumber *_pdl_zombie_disabled = nil;
static void *_pdl_zombie_enabled_key = &_pdl_zombie_enabled_key;
static void *_pdl_zombie_duration_key = &_pdl_zombie_duration_key;

static dispatch_queue_t pdl_zombie_queue(void) {
    static dispatch_queue_t _pdl_zombie_queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pdl_zombie_queue = dispatch_queue_create("pdl_zombie_queue", DISPATCH_QUEUE_SERIAL);
        if (!_pdl_zombie_queue) {
            _pdl_zombie_queue = dispatch_get_global_queue(0, 0);
        }
    });
    return _pdl_zombie_queue;
}

static void pdl_zombie_make_zombie(void *object) {
    Class cls = object_getClass(object);
    const char *class_name = class_getName(cls);
    const char *root_zombie_class_name = pdl_zombie_class_name;
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

static IMP pdl_NSObjectDealloc = NULL;
static __unsafe_unretained Class pdl_NSObjectClass = NULL;
static SEL pdl_NSObjectCmd = NULL;

static void pdl_zombie_dealloc(__unsafe_unretained id self) {
    IMP _imp = pdl_NSObjectDealloc;
    Class _class = pdl_NSObjectClass;
    SEL _cmd = pdl_NSObjectCmd;
    if (_imp) {
        ((void (*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        ((void (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
}

static void pdl_zombie_timer_handler(pdl_zombie_timer_context *context) {
    int count = context->count;
    if (count == 0) {
        context->count++;
        return;
    }

    __unsafe_unretained id object = context->object;
    dispatch_source_t timer = context->timer;
    pdl_zombie_dealloc(object);
    dispatch_source_cancel(timer);
    dispatch_release(timer);
    free(context);
}

static void pdl_dealloc(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    __unsafe_unretained id object = self;

    if (!pdl_NSObjectClass) {
        pdl_NSObjectClass = _class;
        pdl_NSObjectDealloc = _imp;
    }

    NSNumber *enabledNumber = objc_getAssociatedObject(object, _pdl_zombie_enabled_key);
    BOOL zombie = NO;
    if (!enabledNumber) {
        if (_pdl_zombie_filter) {
            zombie = _pdl_zombie_filter(object);
        }
    } else {
        zombie = [enabledNumber boolValue];
    }

    if (!zombie) {
        pdl_zombie_dealloc(object);
        return;
    }

    NSTimeInterval zombie_duration = pdl_zombie_object_duration(object);

    pdl_zombie_make_zombie(object);

    if (zombie_duration > 0) {
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, pdl_zombie_queue());
        pdl_zombie_set_object_enabled(timer, NO);
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, zombie_duration * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
        pdl_zombie_timer_context *context = malloc(sizeof(pdl_zombie_timer_context));
        context->object = object;
        context->timer = timer;
        context->count = 0;
        dispatch_set_context(timer, context);
        dispatch_source_set_event_handler_f(timer, (dispatch_function_t)&pdl_zombie_timer_handler);
        dispatch_resume(timer);
    }
}

#pragma mark -

BOOL pdl_zombie_enable(BOOL(*filter)(__unsafe_unretained id object)) {
    if (objc_lookUpClass(pdl_zombie_class_name) == nil) {
        return NO;
    }

    SEL sel = sel_registerName("dealloc");
    pdl_NSObjectCmd = sel;
    _pdl_zombie_enabled = [@(YES) retain];
    _pdl_zombie_disabled = [@(NO) retain];
    BOOL ret = [NSObject pdl_interceptSelector:sel withInterceptorImplementation:(IMP)&pdl_dealloc isStructRet:nil addIfNotExistent:YES data:NULL];
    _pdl_zombie_filter = filter;
    return ret;
}

BOOL pdl_zombie_object_enabled(__unsafe_unretained id object) {
    NSNumber *enabled = objc_getAssociatedObject(object, _pdl_zombie_enabled_key);
    return [enabled boolValue];
}

void pdl_zombie_set_object_enabled(__unsafe_unretained id object, BOOL enabled) {
    objc_setAssociatedObject(object, _pdl_zombie_enabled_key, enabled ? _pdl_zombie_enabled : _pdl_zombie_disabled, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

NSTimeInterval pdl_zombie_object_duration(__unsafe_unretained id object) {
    NSNumber *number = objc_getAssociatedObject(object, _pdl_zombie_duration_key);
    return [number doubleValue];
}

void pdl_zombie_set_object_duration(__unsafe_unretained id object, NSTimeInterval duration) {
    NSNumber *number = @(duration);
    objc_setAssociatedObject(object, _pdl_zombie_duration_key, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

BOOL pdl_zombie_object_is_zombie(__unsafe_unretained id object) {
    if (!object) {
        return NO;
    }

    Class cls = object_getClass(object);
    const char *name = class_getName(cls);
    return strncmp(name, pdl_zombie_class_name, strlen(pdl_zombie_class_name)) == 0;
}

void pdl_zombie_free_object(__unsafe_unretained id object) {
    if (!pdl_zombie_object_is_zombie(object)) {
        return;
    }

    pdl_zombie_dealloc(object);
}
