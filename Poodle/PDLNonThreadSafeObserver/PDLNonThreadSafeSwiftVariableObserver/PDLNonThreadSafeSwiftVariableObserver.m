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
#import "PDLNonThreadSafeObserver.h"
#import "pdl_hook.h"
#import "pdl_swift.h"
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
}

static void *pdl_validate_object(void *address) {
//    void *header = NULL;
//    pdl_malloc_find(address, NULL, &header);
//    return header;

    BOOL isNotPointer = address < (void *)0x100000000UL;
    if (isNotPointer) {
        return NULL;
    }

    pthread_t thread = pthread_self();
    void *threadAddress = pthread_get_stackaddr_np(thread);
    size_t threadSize = pthread_get_stacksize_np(thread);
    BOOL isInStack = address < threadAddress && address > (threadAddress - threadSize);
    if (isInStack) {
        return NULL;
    }

    if (((unsigned long)address & 0xFFFFFFFF) == 0) {
        return NULL;
    }

    return address;
}

static bool pdl_is_class_available(void *cls) {
    unsigned long address = (unsigned long)cls;
    return ((address & 0xFFFFFFFF) > 0x10000) && (!(address & 0x8000000000000000LL));
}

static void *pdl_get_swift_superclass(void *cls) {
    return ((void **)cls)[1];
}

static NSMutableDictionary *pdl_variable_name_dictionary(void) {
    static NSMutableDictionary *dictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = [NSMutableDictionary dictionary];
        [PDLNonThreadSafeObserver setIgnored:YES forObject:dictionary];
    });
    return dictionary;
}

static NSString *pdl_get_variable_name(Class aClass, intptr_t offset) {
    size_t size = class_getInstanceSize(aClass);
    if (offset >= size) {
        return nil;
    }

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
static NSSet *pdl_classes = nil;

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

static void pdl_swift_beginAccessAction(void *address, void **result, int8_t flags, int64_t reserved, void *ret) {
    void *possibleObjectAddress = pdl_get_object(address);
    void *objectAddress = pdl_validate_object(possibleObjectAddress);
    intptr_t offset = address - objectAddress;
    if (!(offset > 0 && offset < 0x10000 && objectAddress)) {
        return;
    }

    Class aClass = object_getClass((__bridge __unsafe_unretained id)(objectAddress));
    void *cls = (__bridge void *)aClass;
    if (![pdl_classes containsObject:@((unsigned long)cls)]) {
        return;
    }

    NSString *className = NSStringFromClass(aClass);
    className = [PDLCrash demangle:className] ?: className;
    if (pdl_classFilter) {
        if (!pdl_classFilter(className)) {
            return;
        }
    }

    NSString *variableName = pdl_get_variable_name(aClass, offset);
    if (!variableName) {
        return;
    }

    if (pdl_classVariableFilter) {
        PDLNonThreadSafeSwiftVariableObserver_VariableFilter variableFilter = pdl_classVariableFilter(className);
        if (variableFilter) {
            if (!variableFilter(variableName)) {
                return;
            }
        }
    }

    id object = (__bridge id)objectAddress;
    BOOL isSetter = flags & 1;
    PDLNonThreadSafeSwiftVariableObserverObject *observer = [PDLNonThreadSafeSwiftVariableObserverObject observerObjectForObject:object];
    if (!observer) {
        return;
    }

    [observer recordClass:aClass variableName:variableName isSetter:isSetter];
}

//static void pdl_swift_endAccessAction(void **result, void *ret) {
//    ;
//}

static void pdl_swift_allocObjectAction(void *cls, size_t requiredSize, size_t requiredAlignmentMask, void *object) {
    void *superClass = pdl_get_swift_superclass(cls);
    if (pdl_is_class_available(superClass)) {
        [PDLNonThreadSafeSwiftVariableObserverObject registerObject:(__bridge id)(object)];
    }
}

+ (void)observeWithClassFilter:(PDLNonThreadSafeSwiftVariableObserver_ClassFilter)classFilter classVariableFilter:(PDLNonThreadSafeSwiftVariableObserver_ClassVariableFilter)classVariableFilter {
    pdl_swift_registerAllocAction(&pdl_swift_allocObjectAction);
    pdl_swift_registerAccessBeginAction(&pdl_swift_beginAccessAction);
//    pdl_swift_registerAccessEndAction(&pdl_swift_endAccessAction);

    NSMutableSet *classes = [NSMutableSet set];
    {
        unsigned long size = 0;
        uint8_t *section = getsectiondata((void *)pdl_execute_header(), "__DATA", "__objc_classlist", &size);
        if (!section) {
            section = getsectiondata((void *)pdl_execute_header(), "__DATA_CONST", "__objc_classlist", &size);
            if (!section) {
                return;
            }
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

            [classes addObject:@((unsigned long)cls)];

            pdl_interceptSelector(object_getClass(aClass), @selector(allocWithZone:), (IMP)&pdl_nonThreadSafeSwiftVariableAllocWithZone, nil, YES, NULL);
        }
    }

    pdl_classFilter = classFilter;
    pdl_classVariableFilter = classVariableFilter;
    pdl_classes = [classes copy];
}

@end
