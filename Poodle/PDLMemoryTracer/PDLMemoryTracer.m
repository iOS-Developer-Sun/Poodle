//
//  PDLMemoryTracer.m
//  Poodle
//
//  Created by Poodle on 2019/4/4.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLMemoryTracer.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "NSObject+PDLImplementationInterceptor.h"
#import "NSObject+PDLSelectorProxy.h"
#import "pdl_dictionary.h"

#if __has_feature(objc_arc)
#error This file must be compiled with flag "-fno-objc-arc"
#endif

#pragma mark - Declaration

static void logAlloc(Class aClass, __unsafe_unretained id self);
static void logRetain(__unsafe_unretained id self);
static void logRelease(__unsafe_unretained id self);
static void logAutorelease(__unsafe_unretained id self);
static void logDealloc(__unsafe_unretained id self);

void PDLMemoryTracerTraceAlloc(Class aClass, id object);
void PDLMemoryTracerTraceRetain(id self);
void PDLMemoryTracerTraceRelease(id self);
void PDLMemoryTracerTraceAutorelease(id self);
void PDLMemoryTracerTraceDealloc(id self);

#pragma mark - Storage

static pdl_dictionary_t _objectEnabledDictionary = NULL;
static pdl_dictionary_t objectEnabledDictionary(void) {
    if (!_objectEnabledDictionary) {
        _objectEnabledDictionary = pdl_dictionary_create(NULL);
    }
    return _objectEnabledDictionary;
}

static inline BOOL *MemoryTracerObjectEnabled(void *object) {
    void **key = pdl_dictionary_get(objectEnabledDictionary(), object);
    return (BOOL *)key;
}
static inline void MemoryTracerSetObjectEnabled(void *object, BOOL *enabled) {
    if (enabled) {
        void *value = (void *)(unsigned long)*enabled;
        pdl_dictionary_set(objectEnabledDictionary(), object, &value);
    } else {
        pdl_dictionary_remove(objectEnabledDictionary(), object);
    }
}

static pdl_dictionary_t _logEnabledDictionary = NULL;
static pdl_dictionary_t logEnabledDictionary(void) {
    if (!_logEnabledDictionary) {
        _logEnabledDictionary = pdl_dictionary_create(NULL);
    }
    return _logEnabledDictionary;
}

static inline BOOL MemoryTracerLogEnabled(void *object) {
    void **key = pdl_dictionary_get(logEnabledDictionary(), object);
    if (key) {
        return (BOOL)(long)*key;
    } else {
        return NO;
    }
}
static inline void MemoryTracerSetLogEnabled(void *object, BOOL enabled) {
    if (enabled) {
        void *value = (void *)(unsigned long)enabled;
        pdl_dictionary_set(logEnabledDictionary(), object, &value);
    } else {
        pdl_dictionary_remove(logEnabledDictionary(), object);
    }
}

static pdl_dictionary_t _enabledDictionary = NULL;
static pdl_dictionary_t enabledDictionary(void) {
    if (!_enabledDictionary) {
        _enabledDictionary = pdl_dictionary_create(NULL);
    }
    return _enabledDictionary;
}

static inline BOOL *MemoryTracerEnabled(void *object) {
    void **key = pdl_dictionary_get(enabledDictionary(), object);
    return (BOOL *)key;
}
static inline void MemoryTracerSetEnabled(void *object, BOOL *enabled) {
    if (enabled) {
        void *value = (void *)(unsigned long)*enabled;
        pdl_dictionary_set(enabledDictionary(), object, &value);
    } else {
        pdl_dictionary_remove(enabledDictionary(), object);
    }
}

static void MemoryTracerLog(const char *format, ...) {
    va_list args;
    va_start(args, format);
    vprintf(format, args);
    va_end(args);
}

static void MemoryTracerLogRetainReleaseAutoReleaseDealloc(__unsafe_unretained id self, SEL _cmd) {
    if (sel_isEqual(_cmd, @selector(retain))) {
        logRetain(self);
    } else if (sel_isEqual(_cmd, @selector(release))) {
        logRelease(self);
    } else if (sel_isEqual(_cmd, @selector(autorelease))) {
        logAutorelease(self);
    } else if (sel_isEqual(_cmd, @selector(dealloc))) {
        logDealloc(self);
    } else {
        assert(0);
    }
}

static void MemoryTracerTraceRetainReleaseAutoReleaseDealloc(__unsafe_unretained id self, SEL _cmd) {
    if (sel_isEqual(_cmd, @selector(retain))) {
        PDLMemoryTracerTraceRetain(self);
    } else if (sel_isEqual(_cmd, @selector(release))) {
        PDLMemoryTracerTraceRelease(self);
    } else if (sel_isEqual(_cmd, @selector(autorelease))) {
        PDLMemoryTracerTraceAutorelease(self);
    } else if (sel_isEqual(_cmd, @selector(dealloc))) {
        PDLMemoryTracerTraceDealloc(self);
    } else {
        assert(0);
    }
}

#pragma mark - Class Implementations

static id MemoryTracerClassAllocWithZone(__unsafe_unretained id self, SEL _cmd, struct _NSZone *zone) {
    PDLImplementationInterceptorRecover(_cmd);
    id object = nil;
    if (_imp) {
        object = ((id (*)(id, SEL, struct _NSZone *))_imp)(self, _cmd, zone);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
    if (MemoryTracerLogEnabled(_class)) {
        logAlloc(self, object);
    }
    BOOL *enabled = MemoryTracerEnabled(_class);
    if (enabled && *enabled) {
        PDLMemoryTracerTraceAlloc(self, object);
    }
    return object;
}

static id MemoryTracerClassRetainReleaseAutoReleaseDealloc(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    BOOL hasLogged = NO;
    if (MemoryTracerLogEnabled(object_getClass(_class))) {
        MemoryTracerLogRetainReleaseAutoReleaseDealloc(self, _cmd);
        hasLogged = YES;
    }
    BOOL *enabled = MemoryTracerObjectEnabled(object_getClass(_class));
    if (enabled && *enabled) {
        if (!hasLogged) {
            if (MemoryTracerLogEnabled(self)) {
                MemoryTracerLogRetainReleaseAutoReleaseDealloc(self, _cmd);
            }
        }
        MemoryTracerTraceRetainReleaseAutoReleaseDealloc(self, _cmd);
    } else {
        enabled = MemoryTracerEnabled(object_getClass(_class));
        if (enabled && *enabled) {
            MemoryTracerTraceRetainReleaseAutoReleaseDealloc(self, _cmd);
        }
    }

    id object = nil;
    if (_imp) {
        object = ((id (*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
    if (sel_isEqual(_cmd, @selector(dealloc))) {
        MemoryTracerSetEnabled(self, NULL);
        MemoryTracerSetObjectEnabled(self, NULL);
        MemoryTracerSetLogEnabled(self, NO);
    }
    return object;
}

static id MemoryTracerClassDescription(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    NSString *description = nil;
    if (_imp) {
        description = ((NSString *(*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        description = ((NSString *(*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
    description = [description stringByAppendingFormat:@"(%@)", @([self retainCount])];
    return description;
}

#pragma mark - Object Implementations

static id MemoryTracerObjectRetainReleaseAutoReleaseDealloc(__unsafe_unretained id self, SEL _cmd) {
    if (MemoryTracerLogEnabled(self)) {
        MemoryTracerLogRetainReleaseAutoReleaseDealloc(self, _cmd);
    }
    BOOL *enabled = MemoryTracerEnabled(self);
    if (enabled && *enabled) {
        MemoryTracerTraceRetainReleaseAutoReleaseDealloc(self, _cmd);
    }
    IMP imp = [self pdl_selectorProxyImplementationForSelector:_cmd];
    id ret = ((id (*)(id, SEL))imp)(self, _cmd);
    if (sel_isEqual(_cmd, @selector(dealloc))) {
        MemoryTracerSetEnabled(self, NULL);
        MemoryTracerSetObjectEnabled(self, NULL);
        MemoryTracerSetLogEnabled(self, NO);
    }
    return ret;
}

static id MemoryTracerObjectDescription(__unsafe_unretained id self, SEL _cmd) {
    IMP imp = [self pdl_selectorProxyImplementationForSelector:_cmd];
    NSString *description = ((NSString *(*)(id, SEL))imp)(self, _cmd);
    description = [description stringByAppendingFormat:@"(%@)", @([self retainCount])];
    return description;
}

#pragma mark - Public Methods

void PDLMemoryTracerPrepareTracingClass(Class aClass) {
    BOOL *enabled = MemoryTracerEnabled(object_getClass(aClass));
    if (enabled) {
        return;
    } else {
        if (![object_getClass(aClass) pdl_interceptSelector:@selector(allocWithZone:) withInterceptorImplementation:(IMP)&MemoryTracerClassAllocWithZone isStructRet:nil addIfNotExistent:YES data:NULL]) {
            return;
        }
        if (![aClass pdl_interceptSelector:@selector(retain) withInterceptorImplementation:(IMP)&MemoryTracerClassRetainReleaseAutoReleaseDealloc isStructRet:nil addIfNotExistent:YES data:NULL]) {
            return;
        }
        if (![aClass pdl_interceptSelector:@selector(release) withInterceptorImplementation:(IMP)&MemoryTracerClassRetainReleaseAutoReleaseDealloc isStructRet:nil addIfNotExistent:YES data:NULL]) {
            return;
        }
        if (![aClass pdl_interceptSelector:@selector(autorelease) withInterceptorImplementation:(IMP)&MemoryTracerClassRetainReleaseAutoReleaseDealloc isStructRet:nil addIfNotExistent:YES data:NULL]) {
            return;
        }
        if (![aClass pdl_interceptSelector:@selector(dealloc) withInterceptorImplementation:(IMP)&MemoryTracerClassRetainReleaseAutoReleaseDealloc isStructRet:nil addIfNotExistent:YES data:NULL]) {
            return;
        }
        if (![aClass pdl_interceptSelector:@selector(description) withInterceptorImplementation:(IMP)&MemoryTracerClassDescription isStructRet:nil addIfNotExistent:YES data:NULL]) {
            return;
        }
        BOOL enabled = NO;
        MemoryTracerSetEnabled(object_getClass(aClass), &enabled);
    }
}

void PDLMemoryTracerStartTracingClass(Class aClass) {
    BOOL *enabled = MemoryTracerEnabled(object_getClass(aClass));
    if (enabled) {
        if (*enabled) {
            return;
        }
        BOOL enabled = YES;
        MemoryTracerSetEnabled(object_getClass(aClass), &enabled);
    } else {
        if (![object_getClass(aClass) pdl_interceptSelector:@selector(allocWithZone:) withInterceptorImplementation:(IMP)&MemoryTracerClassAllocWithZone isStructRet:nil addIfNotExistent:YES data:NULL]) {
            return;
        }
        if (![aClass pdl_interceptSelector:@selector(retain) withInterceptorImplementation:(IMP)&MemoryTracerClassRetainReleaseAutoReleaseDealloc isStructRet:nil addIfNotExistent:YES data:NULL]) {
            return;
        }
        if (![aClass pdl_interceptSelector:@selector(release) withInterceptorImplementation:(IMP)&MemoryTracerClassRetainReleaseAutoReleaseDealloc isStructRet:nil addIfNotExistent:YES data:NULL]) {
            return;
        }
        if (![aClass pdl_interceptSelector:@selector(autorelease) withInterceptorImplementation:(IMP)&MemoryTracerClassRetainReleaseAutoReleaseDealloc isStructRet:nil addIfNotExistent:YES data:NULL]) {
            return;
        }
        if (![aClass pdl_interceptSelector:@selector(dealloc) withInterceptorImplementation:(IMP)&MemoryTracerClassRetainReleaseAutoReleaseDealloc isStructRet:nil addIfNotExistent:YES data:NULL]) {
            return;
        }
        if (![aClass pdl_interceptSelector:@selector(description) withInterceptorImplementation:(IMP)&MemoryTracerClassDescription isStructRet:nil addIfNotExistent:YES data:NULL]) {
            return;
        }
        BOOL enabled = YES;
        MemoryTracerSetEnabled(object_getClass(aClass), &enabled);
    }
}

void PDLMemoryTracerStopTracingClass(Class aClass) {
    BOOL *enabled = MemoryTracerEnabled(object_getClass(aClass));
    if (enabled && *enabled) {
        BOOL enabled = NO;
        MemoryTracerSetEnabled(object_getClass(aClass), &enabled);
    }
}

void PDLMemoryTracerStartTracingClassObject(id object) {
    BOOL *enabled = MemoryTracerObjectEnabled(object);
    if (enabled) {
        if (*enabled) {
            return;
        }
        BOOL enabled = YES;
        MemoryTracerSetEnabled(object, &enabled);
    } else {
        BOOL enabled = YES;
        MemoryTracerSetEnabled(object, &enabled);
    }
}

void PDLMemoryTracerStopTracingClassObject(id object) {
    BOOL *enabled = MemoryTracerObjectEnabled(object);
    if (enabled && *enabled) {
        BOOL enabled = NO;
        MemoryTracerSetObjectEnabled(object, &enabled);
    }
}

void PDLMemoryTracerStartTracingObject(id object) {
    BOOL *enabled = MemoryTracerEnabled(object);
    if (enabled) {
        if (*enabled) {
            return;
        }
        BOOL enabled = YES;
        MemoryTracerSetEnabled(object, &enabled);
    } else {
        if (![object pdl_setSelectorProxyForSelector:@selector(retain) withImplementation:(IMP)&MemoryTracerObjectRetainReleaseAutoReleaseDealloc]) {
            return;
        }
        if (![object pdl_setSelectorProxyForSelector:@selector(release) withImplementation:(IMP)&MemoryTracerObjectRetainReleaseAutoReleaseDealloc]) {
            return;
        }
        if (![object pdl_setSelectorProxyForSelector:@selector(autorelease) withImplementation:(IMP)&MemoryTracerObjectRetainReleaseAutoReleaseDealloc]) {
            return;
        }
        if (![object pdl_setSelectorProxyForSelector:@selector(dealloc) withImplementation:(IMP)&MemoryTracerObjectRetainReleaseAutoReleaseDealloc]) {
            return;
        }
        if (![object pdl_setSelectorProxyForSelector:@selector(description) withImplementation:(IMP)&MemoryTracerObjectDescription]) {
            return;
        }
        BOOL enabled = YES;
        MemoryTracerSetEnabled(object, &enabled);
    }
}

void PDLMemoryTracerStopTracingObject(id object) {
    BOOL *enabled = MemoryTracerEnabled(object);
    if (enabled && *enabled) {
        BOOL enabled = NO;
        MemoryTracerSetEnabled(object, &enabled);
    }
}

BOOL PDLMemoryTracerLogEnabledForClass(Class aClass) {
    return MemoryTracerLogEnabled(object_getClass(aClass));
}

void PDLMemoryTracerSetLogEnabledForClass(Class aClass, BOOL logEnabled) {
    MemoryTracerSetLogEnabled(object_getClass(aClass), logEnabled);
}

BOOL PDLMemoryTracerLogEnabledForObject(id object) {
    return MemoryTracerLogEnabled(object);
}

void PDLMemoryTracerSetLogEnabledForObject(id object, BOOL logEnabled) {
    MemoryTracerSetLogEnabled(object, logEnabled);
}

#pragma mark - Loggers

static void logAlloc(Class aClass, __unsafe_unretained id self) {
    MemoryTracerLog("PDLMemoryTracer [%s](%p) alloc: %zd->%zd", class_getName(aClass), self, 0, [self retainCount]);
}

static void logRetain(__unsafe_unretained id self) {
    NSInteger originalRetainCount = [self retainCount];
    NSInteger currentRetainCount = originalRetainCount + 1;
    MemoryTracerLog("PDLMemoryTracer [%s](%p) retain: %zd->%zd", class_getName(object_getClass(self)), self, originalRetainCount, currentRetainCount);
}

static void logRelease(__unsafe_unretained id self) {
    NSInteger originalRetainCount = [self retainCount];
    NSInteger currentRetainCount = originalRetainCount - 1;
    MemoryTracerLog("PDLMemoryTracer [%s](%p) release: %zd->%zd", class_getName(object_getClass(self)), self, originalRetainCount, currentRetainCount);
}

static void logAutorelease(__unsafe_unretained id self) {
    NSInteger originalRetainCount = [self retainCount];
    NSInteger currentRetainCount = originalRetainCount;
    MemoryTracerLog("PDLMemoryTracer [%s](%p) autorelease: %zd->%zd", class_getName(object_getClass(self)), self, originalRetainCount, currentRetainCount);
}

static void logDealloc(__unsafe_unretained id self) {
    MemoryTracerLog("PDLMemoryTracer [%s](%p) dealloc", class_getName(object_getClass(self)), self);
}

#pragma mark - Breakpoints

void PDLMemoryTracerTraceAlloc(Class aClass, id object) {
    // set break point here
}

void PDLMemoryTracerTraceRetain(id self) {
    // set break point here
}

void PDLMemoryTracerTraceRelease(id self) {
    // set break point here
}

void PDLMemoryTracerTraceAutorelease(id self) {
    // set break point here
}

void PDLMemoryTracerTraceDealloc(id self) {
    // set break point here
}
