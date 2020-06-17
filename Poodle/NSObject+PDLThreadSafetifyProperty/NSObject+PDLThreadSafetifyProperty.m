//
//  NSObject+PDLThreadSafetifyProperty.m
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSObject+PDLThreadSafetifyProperty.h"
#import "NSObject+PDLImplementationInterceptor.h"
#import <pthread.h>

__unused __attribute__((visibility("hidden"))) void the_table_of_contents_is_empty(void) {}

@implementation NSObject (PDLThreadSafetifyProperty)

static pthread_mutex_t _lock = PTHREAD_MUTEX_INITIALIZER;
static id pdl_threadSafePropertyLock(__unsafe_unretained id self, Class aClass, const char *name) {
    NSString *identifier = [NSString stringWithFormat:@"%@.%@", NSStringFromClass(aClass), @(name)];
    pthread_mutex_lock(&_lock);
    NSMutableDictionary *locks = objc_getAssociatedObject(self, &pdl_threadSafePropertyLock);
    if (locks == nil) {
        locks = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &pdl_threadSafePropertyLock, locks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    id lock = locks[identifier];
    if (lock == nil) {
        lock = [[NSObject alloc] init];
        locks[identifier] = lock;
    }
    pthread_mutex_unlock(&_lock);
    return lock;
}

static id pdl_threadSafePropertyGetter(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    @synchronized (pdl_threadSafePropertyLock(self, _class, _data)) {
        return ((typeof(&pdl_threadSafePropertyGetter))_imp)(self, _cmd);
    }
}

static void pdl_threadSafePropertySetter(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id property) {
    PDLImplementationInterceptorRecover(_cmd);
    @synchronized (pdl_threadSafePropertyLock(self, _class, _data)) {
        ((typeof(&pdl_threadSafePropertySetter))_imp)(self, _cmd, property);
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
    if (!getter || !setter) {
        return NO;
    }

    BOOL ret = pdl_interceptSelector(aClass, getter, (IMP)&pdl_threadSafePropertyGetter, nil, NO, (void *)name);
    ret &= pdl_interceptSelector(aClass, setter, (IMP)&pdl_threadSafePropertySetter, nil, NO, (void *)name);

    return ret;
}

@end
