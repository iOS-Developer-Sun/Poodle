//
//  PDLNonThreadSafeSwiftVariableObserver.m
//  Poodle
//
//  Created by Poodle on 2023/6/5.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeSwiftVariableObserver.h"
#import "PDLNonThreadSafeSwiftVariableObserverObject.h"
#import "NSObject+PDLImplementationInterceptor.h"
#import "PDLNonThreadSafePropertyObserverProperty.h"
#import "PDLNonThreadSafeObserver.h"
#import "pdl_hook.h"
#import "PDLCrash.h"
#import "pdl_mach_object.h"
#import <mach-o/getsect.h>
//#import "pdl_malloc.h"

@implementation PDLNonThreadSafeSwiftVariableObserver

__attribute__((naked))
static void *pdl_get_object(void *address) {
#if defined(__arm64__)
    __asm__ volatile ("mov x0, x20 \n ret");
#elif defined(__x86_64__)
    __asm__ volatile ("mov %r13, %rax \n ret");
#endif
//    void *header = NULL;
//    pdl_malloc_find(address, NULL, &header);
//    return header;
}

static void *pdl_get_swift_superclass(void *cls) {
    return ((void **)cls)[1];
}

static bool pdl_is_class_available(void *cls) {
    unsigned long address = (unsigned long)cls;
    return ((address & 0xFFFFFFFF) > 0x10) && (!(address & 0x8000000000000000LL));
}

static NSMutableDictionary *pdl_variable_name_dictionary(void) {
    static NSMutableDictionary *dictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = [NSMutableDictionary dictionary];
    });
    return dictionary;
}

static NSString *pdl_get_variable_name(Class aClass, intptr_t offset) {
    NSString *key = [NSString stringWithFormat:@"%@:%@", aClass, @(offset)];
    NSMutableDictionary *dictionary = pdl_variable_name_dictionary();
    NSString *ret = nil;
    @synchronized (dictionary) {
        ret = dictionary[key];
        if (!ret) {
            unsigned int count = 0;
            Ivar *ivarList = class_copyIvarList(aClass, &count);
            for (unsigned int i = 0; i < count; i++) {
                Ivar ivar = ivarList[i];
                if (ivar_getOffset(ivar) == offset) {
                    ret = @(ivar_getName(ivar));
                    break;
                }
            }
            free(ivarList);
            if (!ret) {
                Class superclass = class_getSuperclass(aClass);
                if (superclass) {
                    ret = pdl_get_variable_name(superclass, offset);
                }
            }
            if (ret) {
                dictionary[key] = ret;
            }
        }
    }
    return ret;
}

static PDLNonThreadSafeSwiftVariableObserver_ClassFilter pdl_classFilter = nil;
static PDLNonThreadSafeSwiftVariableObserver_ClassVariableFilter pdl_classVariableFilter = nil;

static id pdl_nonThreadSafeSwiftVariableAllocWithZone(__unsafe_unretained id self, SEL _cmd, struct _NSZone *zone) {
    PDLImplementationInterceptorRecover(_cmd);
    id object = nil;
    if (_imp) {
        object = ((id (*)(__unsafe_unretained id, SEL, struct _NSZone *))_imp)(self, _cmd, zone);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }

    [PDLNonThreadSafeSwiftVariableObserverObject registerObject:object];

    return object;
}

#pragma mark - public methods

extern bool swift_isClassType(void *);
extern void *swift_beginAccess(void *, void **, int8_t, int64_t);
static void *(*pdl_swift_beginAccess_original)(void *, void **, int8_t, int64_t) = NULL;
static void *pdl_swift_beginAccess(void *address, void **result, int8_t flags, int64_t reserved) {
    void *ret = pdl_swift_beginAccess_original(address, result, flags, reserved);

    void *objectAddress = pdl_get_object(address);
    intptr_t offset = address - objectAddress;
    if (offset > 0 && offset <= 4096 && objectAddress && swift_isClassType(address)) {
        Class aClass = object_getClass((__bridge __unsafe_unretained id)(objectAddress));
        void *cls = (__bridge void *)aClass;
        void *superClass = pdl_get_swift_superclass(cls);
        if (pdl_is_class_available(superClass)) {
            NSString *className = NSStringFromClass(aClass);
            className = [PDLCrash demangle:className] ?: className;
            if (pdl_classFilter) {
                if (!pdl_classFilter(className)) {
                    return ret;
                }
            }
            NSString *variableName = pdl_get_variable_name(aClass, offset);
            assert(variableName);
            if (pdl_classVariableFilter) {
                PDLNonThreadSafeSwiftVariableObserver_VariableFilter variableFilter = pdl_classVariableFilter(className);
                if (variableFilter) {
                    if (!variableFilter(variableName)) {
                        return ret;
                    }
                }
            }
            id object = (__bridge id)objectAddress;
            BOOL isSetter = flags & 1;
            PDLNonThreadSafeSwiftVariableObserverObject *observer = [PDLNonThreadSafeSwiftVariableObserverObject observerObjectForObject:object];
            [observer recordClass:aClass variableName:variableName isSetter:isSetter];
        }
    }
    return ret;
}

extern void *swift_endAccess(void **);
static void **(*pdl_swift_endAccess_original)(void *) = NULL;
static void **pdl_swift_endAccess(void **result) {
    void *ret = pdl_swift_endAccess_original(result);
    return ret;
}

extern void *swift_allocObject(void *, size_t, size_t);
static void *(*pdl_swift_allocObject_original)(void *, size_t, size_t) = NULL;
static void *pdl_swift_allocObject(void *cls, size_t requiredSize, size_t requiredAlignmentMask) {
    void *ret = pdl_swift_allocObject_original(cls, requiredSize, requiredAlignmentMask);
    void *superClass = pdl_get_swift_superclass(cls);
    if (pdl_is_class_available(superClass)) {
        [PDLNonThreadSafeSwiftVariableObserverObject registerObject:(__bridge id)(ret)];
    }
    return ret;
}

+ (void)observeWithClassFilter:(PDLNonThreadSafeSwiftVariableObserver_ClassFilter)classFilter classVariableFilter:(PDLNonThreadSafeSwiftVariableObserver_ClassVariableFilter)classVariableFilter {
#if defined(__arm64__) || defined(__x86_64__)
    int count = 3;
    pdl_hook_item items[count];
    items[0] = (pdl_hook_item){
        "swift_beginAccess",
        &swift_beginAccess,
        &pdl_swift_beginAccess,
        (void **)&pdl_swift_beginAccess_original,
    };
    items[1] = (pdl_hook_item){
        "swift_endAccess",
        &swift_endAccess,
        &pdl_swift_endAccess,
        (void **)&pdl_swift_endAccess_original,
    };
    items[2] = (pdl_hook_item){
        "swift_allocObject",
        &swift_allocObject,
        &pdl_swift_allocObject,
        (void **)&pdl_swift_allocObject_original,
    };
    int ret = pdl_hook(items, count);
    assert(ret == count);

    {
        unsigned long size = 0;
        uint8_t *section = getsectiondata((void *)pdl_execute_header(), "__DATA", "__objc_classlist", &size);
        if (!section) {
            return;
        }

        void **classList = (void **)section;
        unsigned long count = size / sizeof(Class);
        for (unsigned long i = 0; i < count; i++) {
            void *cls = classList[i];
            Class aClass = (__bridge Class)cls;
            NSString *className = NSStringFromClass(aClass);
            className = [PDLCrash demangle:className] ?: className;

            if (![className containsString:@"."]) {
                continue;
            }

            pdl_interceptSelector(object_getClass(aClass), @selector(allocWithZone:), (IMP)&pdl_nonThreadSafeSwiftVariableAllocWithZone, nil, YES, NULL);
        }
    }

    pdl_classFilter = classFilter;
    pdl_classVariableFilter = classVariableFilter;
#endif
}

@end
