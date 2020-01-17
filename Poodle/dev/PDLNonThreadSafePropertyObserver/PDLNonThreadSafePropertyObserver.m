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

@implementation PDLNonThreadSafePropertyObserver

static void propertyLog(__unsafe_unretained id self, Class aClass, void *data, BOOL isSetter) {
    NSString *propertyName = @((char *)data);
    PDLNonThreadSafePropertyObserverObject *observer = [PDLNonThreadSafePropertyObserverObject observerObjectForObject:self];
    [observer recordClass:aClass propertyName:propertyName isSetter:isSetter];
}

static id propertyGetter(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    propertyLog(self, _class, _data, NO);
    id object = ((typeof(&propertyGetter))_imp)(self, _cmd);
    return object;
}

static void propertySetter(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id property) {
    PDLImplementationInterceptorRecover(_cmd);
    propertyLog(self, _class, _data, YES);
    ((typeof(&propertySetter))_imp)(self, _cmd, property);
}

static id observeNonThreadSafePropertiesAllocWithZone(__unsafe_unretained id self, SEL _cmd, struct _NSZone *zone) {
    PDLImplementationInterceptorRecover(_cmd);
    id object = nil;
    if (_imp) {
        object = ((id (*)(id, SEL, struct _NSZone *))_imp)(self, _cmd, zone);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }

    [PDLNonThreadSafePropertyObserverObject registerObject:object];

    return object;
}

#pragma mark - public methods

static BOOL _queueEnabled = NO;

+ (BOOL)queueCheckerEnabled {
    return _queueEnabled;
}

+ (void)registerQueueCheckerEnabled:(BOOL)queueEnabled {
    _queueEnabled = queueEnabled;
}

static void (^_reporter)(PDLNonThreadSafePropertyObserverProperty *property);

+ (void(^)(PDLNonThreadSafePropertyObserverProperty *property))reporter {
    return _reporter;
}

+ (void)registerReporter:(void(^)(PDLNonThreadSafePropertyObserverProperty *property))reporter {
    _reporter = reporter;
}

+ (void)observerClass:(Class)aClass
       propertyFilter:(PDLNonThreadSafePropertyObserver_PropertyFilter)propertyFilter
    propertyMapFilter:(NSArray <NSString *> *)propertyMapFilter {
    if (!aClass) {
        return;
    }

    if ([NSStringFromClass(aClass) hasPrefix:@"PDLNonThreadSafePropertyObserver"]) {
        return;
    }

    BOOL classObserved = NO;
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList(aClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        objc_property_t property = propertyList[i];
        const char *name = property_getName(property);
        const char *attributes = property_getAttributes(property);
        NSString *propertyName = @(name);
        if (propertyFilter && propertyFilter(propertyName)) {
            continue;
        }
        if ([propertyMapFilter containsObject:propertyName]) {
            continue;
        }
        NSArray *attributeList = [@(attributes) componentsSeparatedByString:@","];
        if (![attributeList containsObject:@"&"] && ![attributeList containsObject:@"C"]) {
            continue;
        }
        assert(![attributeList containsObject:@"W"]);
        if (![attributeList containsObject:@"N"]) {
            continue;
        }
        if ([attributeList containsObject:@"R"]) {
            continue;
        }
        if ([attributeList containsObject:@"D"]) {
            continue;
        }

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
        SEL setter = NSSelectorFromString(setterString);;
        assert(getter && setter);

        BOOL ret = pdl_interceptSelector(aClass, getter, (IMP)&propertyGetter, nil, NO, (void *)name);
        if (ret) {
            ret = pdl_interceptSelector(aClass, setter, (IMP)&propertySetter, nil, NO, (void *)name);
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
        pdl_interceptSelector(object_getClass(aClass), @selector(allocWithZone:), (IMP)&observeNonThreadSafePropertiesAllocWithZone, nil, YES, NULL);
    }
}

+ (void)observerClassesForImage:(const char * _Nonnull)image
                    classFilter:(PDLNonThreadSafePropertyObserver_ClassFilter)classFilter
            classPropertyFilter:(PDLNonThreadSafePropertyObserver_ClassPropertyFilter)classPropertyFilter
         classPropertyMapFilter:(NSDictionary <NSString *, NSArray <NSString *> *> *)classPropertyMapFilter {
    unsigned int outCount = 0;
    const char **classNames = objc_copyClassNamesForImage(image, &outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        const char *className = classNames[i];
        if (classFilter) {
            if (classFilter(@(className))) {
                continue;
            }
        }
        Class aClass = objc_getClass(className);
        PDLNonThreadSafePropertyObserver_PropertyFilter propertyFilter = nil;
        if (classPropertyFilter) {
            propertyFilter = classPropertyFilter(@(className));
        }
        [self observerClass:aClass propertyFilter:propertyFilter propertyMapFilter:classPropertyMapFilter[@(className)]];
    }
    free(classNames);
}

@end
