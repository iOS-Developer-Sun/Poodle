//
//  NSObject+PDLThreadSafetifyProperty.m
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSObject+PDLExtension.h"
#import <objc/runtime.h>
#import "NSObject+PDLImplementationInterceptor.h"
#import "NSObject+PDLPrivate.h"

@implementation NSObject (PDLThreadSafetifyProperty)

static id threadSafePropertyLock(__unsafe_unretained id self) {
    return self;
}

static id threadSafePropertyGetter(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    @synchronized (threadSafePropertyLock(self)) {
        return ((typeof(&threadSafePropertyGetter))_imp)(self, _cmd);
    }
}

static void threadSafePropertySetter(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id property) {
    PDLImplementationInterceptorRecover(_cmd);
    @synchronized (threadSafePropertyLock(self)) {
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

    BOOL ret = [aClass pdl_interceptSelector:getter withInterceptorImplementation:(IMP)&threadSafePropertyGetter];
    assert(ret);
    ret &= [aClass pdl_interceptSelector:setter withInterceptorImplementation:(IMP)&threadSafePropertySetter];
    assert(ret);

    return ret;
}

@end
