//
//  NSObject+PDLThreadSafetifyProperty.m
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSObject+PDLExtension.h"
#import <objc/runtime.h>
#import <pthread.h>
#import "NSObject+PDLImplementationInterceptor.h"
#import "NSObject+PDLPrivate.h"

@implementation NSObject (PDLThreadSafetifyProperty)

static pthread_mutex_t _PDLThreadSafetifyPropertyLock = PTHREAD_MUTEX_INITIALIZER;
static id threadSafePropertyLock(__unsafe_unretained id self, Class aClass, const char *name) {
    if ([self _isDeallocating]) {
        return nil;
    }

    NSString *identifier = [NSString stringWithFormat:@"%@.%@", NSStringFromClass(aClass), @(name)];
    pthread_mutex_lock(&_PDLThreadSafetifyPropertyLock);
    NSMutableDictionary *locks = objc_getAssociatedObject(self, &_PDLThreadSafetifyPropertyLock);
    if (locks == nil) {
        locks = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &_PDLThreadSafetifyPropertyLock, locks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    id lock = locks[identifier];
    if (lock == nil) {
        lock = [[NSObject alloc] init];
        locks[identifier] = lock;
    }
    pthread_mutex_unlock(&_PDLThreadSafetifyPropertyLock);
    return lock;
}

static id threadSafePropertyGetter(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    @synchronized (threadSafePropertyLock(self, _class, _data)) {
        return ((typeof(&threadSafePropertyGetter))_imp)(self, _cmd);
    }
}

static void threadSafePropertySetter(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id property) {
    PDLImplementationInterceptorRecover(_cmd);
    @synchronized (threadSafePropertyLock(self, _class, _data)) {
        ((typeof(&threadSafePropertySetter))_imp)(self, _cmd, property);
    }
}

+ (BOOL)pdl_threadSafetifyProperty:(NSString *)propertyName {
    if (propertyName.length == 0) {
        return NO;
    }

    Class aClass = self;
    objc_property_t property = class_getProperty(aClass, propertyName.UTF8String);
    if (!property) {
        return NO;
    }

    const char *attributes = property_getAttributes(property);
    const char *name = property_getName(property);
    NSArray *attributeList = [@(attributes) componentsSeparatedByString:@","];

    NSString *getterString = propertyName;
    NSString *setterString = [NSString stringWithFormat:@"set%@%@:", [propertyName substringToIndex:1].uppercaseString, [propertyName substringFromIndex:1]];
    for (NSString *attributeString in attributeList) {
        if ([attributeString hasPrefix:@"G"]) {
            getterString = [attributeString substringFromIndex:1];
        }
        if ([attributeString hasPrefix:@"S"]) {
            setterString = [attributeString substringFromIndex:1];
        }
    }

    SEL getter = NSSelectorFromString(getterString);
    SEL setter = NSSelectorFromString(setterString);
    assert(getter && setter);

    BOOL ret = pdl_interceptSelector(aClass, getter, (IMP)&threadSafePropertyGetter, nil, NO, (void *)name);
    assert(ret);
    ret &= pdl_interceptSelector(aClass, setter, (IMP)&threadSafePropertySetter, nil, NO, (void *)name);
    assert(ret);

    return ret;
}

@end
