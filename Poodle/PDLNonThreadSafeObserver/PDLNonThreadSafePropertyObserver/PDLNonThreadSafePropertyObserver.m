//
//  PDLNonThreadSafePropertyObserver.m
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafePropertyObserver.h"
#import "PDLNonThreadSafePropertyObserverObject.h"
#import "NSObject+PDLImplementationInterceptor.h"
#import "PDLNonThreadSafePropertyObserverProperty.h"
#import "PDLNonThreadSafeObserver.h"

@implementation PDLNonThreadSafePropertyObserver

static void propertyLog(__unsafe_unretained id self, Class aClass, NSString *propertyName, BOOL isSetter) {
    if ([PDLNonThreadSafeObserver ignoredForObject:self]) {
        return;
    }

    PDLNonThreadSafePropertyObserverObject *observer = [PDLNonThreadSafePropertyObserverObject observerObjectForObject:self];
    if (!observer) {
        return;
    }

    [observer recordClass:aClass propertyName:propertyName isSetter:isSetter];
}

static id pdl_nonThreadSafePropertyGetter(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    propertyLog(self, _class, @((char *)_data), NO);
    id object = ((typeof(&pdl_nonThreadSafePropertyGetter))_imp)(self, _cmd);
    return object;
}

static void pdl_nonThreadSafePropertySetter(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id property) {
    PDLImplementationInterceptorRecover(_cmd);
    propertyLog(self, _class, @((char *)_data), YES);
    ((typeof(&pdl_nonThreadSafePropertySetter))_imp)(self, _cmd, property);
}

static id pdl_nonThreadSafePropertyAllocWithZone(__unsafe_unretained id self, SEL _cmd, struct _NSZone *zone) {
    PDLImplementationInterceptorRecover(_cmd);
    id object = nil;
    if (_imp) {
        object = ((id (*)(__unsafe_unretained id, SEL, struct _NSZone *))_imp)(self, _cmd, zone);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }

    [PDLNonThreadSafePropertyObserverObject registerObject:object];

    return object;
}

#pragma mark - public methods

+ (id)observerObjectForObject:(id)object {
    return [PDLNonThreadSafePropertyObserverObject observerObjectForObject:object];
}

+ (void)observeClass:(Class)aClass propertyFilter:(PDLNonThreadSafePropertyObserver_PropertyFilter)propertyFilter {
    if (!aClass) {
        return;
    }

    if ([NSStringFromClass(aClass) hasPrefix:@"PDLNonThreadSafe"]) {
        return;
    }

    BOOL classObserved = NO;
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList(aClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        objc_property_t property = propertyList[i];
        const char *name = property_getName(property);
        NSString *propertyName = @(name);
        if (propertyFilter && !propertyFilter(propertyName)) {
            continue;
        }

        char *strongValue = property_copyAttributeValue(property, "&");
        if (!strongValue) {
            char *copyValue = property_copyAttributeValue(property, "C");
            if (!copyValue) {
                continue;
            }
            free(copyValue);
        } else {
            free(strongValue);
        }
        assert(!property_copyAttributeValue(property, "W"));

        char *nonatomicValue = property_copyAttributeValue(property, "N");
        if (!nonatomicValue) {
            continue;
        } else {
            free(nonatomicValue);
        }

        char *readonlyValue = property_copyAttributeValue(property, "R");
        if (readonlyValue) {
            free(readonlyValue);
            continue;
        }

        char *dynamicValue = property_copyAttributeValue(property, "D");
        if (dynamicValue) {
            free(dynamicValue);
            continue;
        }

        NSString *getterString = nil;
        NSString *setterString = nil;
        char *getterValue = property_copyAttributeValue(property, "G");
        if (getterValue) {
            getterString = @(getterValue);
            free(getterValue);
        } else {
            getterString = propertyName;
        }

        char *setterValue = property_copyAttributeValue(property, "S");
        if (setterValue) {
            setterString = @(setterValue);
            free(setterValue);
        } else {
            setterString = [NSString stringWithFormat:@"set%@%@:", [propertyName substringToIndex:1].uppercaseString, [propertyName substringFromIndex:1]];
        }

        SEL getter = NSSelectorFromString(getterString);
        SEL setter = NSSelectorFromString(setterString);
        assert(getter && setter);

        BOOL ret = pdl_interceptSelector(aClass, getter, (IMP)&pdl_nonThreadSafePropertyGetter, nil, NO, (void *)name);
        if (ret) {
            ret = pdl_interceptSelector(aClass, setter, (IMP)&pdl_nonThreadSafePropertySetter, nil, NO, (void *)name);
            if (!ret) {
                NSLog(@"%@.%@ does not exist", aClass, setterString);
            } else {
                classObserved = YES;
            }
        } else {
            NSLog(@"%@.%@ does not exist", aClass, getterString);
        }
    }
    free(propertyList);

    if (classObserved) {
        pdl_interceptSelector(object_getClass(aClass), @selector(allocWithZone:), (IMP)&pdl_nonThreadSafePropertyAllocWithZone, nil, YES, NULL);
    }
}

+ (void)observeClassesForImage:(const char * _Nonnull)image classFilter:(PDLNonThreadSafePropertyObserver_ClassFilter)classFilter classPropertyFilter:(PDLNonThreadSafePropertyObserver_ClassPropertyFilter)classPropertyFilter {
    unsigned int outCount = 0;
    const char **classNames = objc_copyClassNamesForImage(image, &outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        const char *className = classNames[i];
        if (classFilter) {
            if (!classFilter(@(className))) {
                continue;
            }
        }
        Class aClass = objc_getClass(className);
        PDLNonThreadSafePropertyObserver_PropertyFilter propertyFilter = nil;
        if (classPropertyFilter) {
            propertyFilter = classPropertyFilter(@(className));
        }
        [self observeClass:aClass propertyFilter:propertyFilter];
    }
    free(classNames);
}

@end
