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

static bool(*_pdl_zombie_filter)(__unsafe_unretained id object) = NULL;
static unsigned int _pdl_zombie_duration = 0;

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

static void pdl_zombie_make_zombie(void *object) {
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

static void pdl_dealloc(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    __unsafe_unretained id object = self;

    bool zombie = true;
    if (_pdl_zombie_filter) {
        zombie = _pdl_zombie_filter(object);
    }

    if (!zombie) {
        if (_imp) {
            ((void (*)(id, SEL))_imp)(self, _cmd);
        } else {
            struct objc_super su = {self, class_getSuperclass(_class)};
            ((void (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
        }
        return;
    }

    pdl_zombie_make_zombie(object);

    unsigned int zombie_duration = _pdl_zombie_duration;
    if (zombie_duration > 0) {
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
    }
}

#pragma mark -

unsigned int pdl_zombie_duration(void) {
    return _pdl_zombie_duration;
}

void pdl_zombie_set_zombie_duration(unsigned int zombie_duration) {
    _pdl_zombie_duration = zombie_duration;
}

bool pdl_zombie_is_zombie(__unsafe_unretained id object) {
    Class cls = object_getClass(object);
    const char *name = class_getName(cls);
    return strncmp(name, "_NSZombie_", strlen("_NSZombie_")) == 0;
}

bool pdl_zombie_enable(bool(*filter)(__unsafe_unretained id object)) {
    if (objc_lookUpClass("_NSZombie_") == nil) {
        return false;
    }

    bool ret = [NSObject pdl_interceptSelector:sel_registerName("dealloc") withInterceptorImplementation:(IMP)&pdl_dealloc isStructRet:nil addIfNotExistent:YES data:NULL];
    _pdl_zombie_filter = filter;
    return ret;
}
