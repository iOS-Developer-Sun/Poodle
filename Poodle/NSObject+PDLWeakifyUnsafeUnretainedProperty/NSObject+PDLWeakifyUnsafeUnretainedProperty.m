//
//  NSObject+PDLWeakifyUnsafeUnretainedProperty.m
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSObject+PDLWeakifyUnsafeUnretainedProperty.h"
#import "NSObject+PDLImplementationInterceptor.h"
#import <pthread.h>

@interface PDLWeakifyUnsafeUnretainedPropertyCxxDestructor : NSObject

@property (nonatomic, unsafe_unretained) id object;
@property (nonatomic, strong) NSMutableSet *offsets;

- (void)registerOffset:(ptrdiff_t)offset;

@end

@implementation PDLWeakifyUnsafeUnretainedPropertyCxxDestructor

- (instancetype)init {
    self = [super init];
    if (self) {
        _offsets = [NSMutableSet set];
    }
    return self;
}

- (void)registerOffset:(ptrdiff_t)offset {
    [_offsets addObject:@(offset)];
}

- (void)dealloc {
    for (NSNumber *offsetNumber in _offsets) {
        ptrdiff_t offset = offsetNumber.integerValue;
        id __autoreleasing *location = (id __autoreleasing *)(void *)(((char *)(__bridge void *)_object) + offset);
        objc_storeWeak(location, nil);
    }
}

@end

@implementation NSObject (PDLWeakifyUnsafeUnretainedProperty)

static id pdl_weakPropertyLock(__unsafe_unretained id self, Class aClass, ptrdiff_t offset) {
    NSString *identifier = [NSString stringWithFormat:@"%@.%@", NSStringFromClass(aClass), @(offset)];
    static pthread_mutex_t _lock = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_lock(&_lock);
    NSMutableDictionary *locks = objc_getAssociatedObject(self, &pdl_weakPropertyLock);
    if (locks == nil) {
        locks = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &pdl_weakPropertyLock, locks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    id lock = locks[identifier];
    if (lock == nil) {
        lock = [[NSObject alloc] init];
        locks[identifier] = lock;
    }
    pthread_mutex_unlock(&_lock);
    return lock;
}

static void pdl_addCxxDestructor(__unsafe_unretained id self, Class aClass, ptrdiff_t offset) {
    PDLWeakifyUnsafeUnretainedPropertyCxxDestructor *cxxDestructor =  objc_getAssociatedObject(self, &pdl_addCxxDestructor);
    @synchronized (pdl_weakPropertyLock(self, aClass, offset)) {
        if (cxxDestructor == nil) {
            cxxDestructor = [[PDLWeakifyUnsafeUnretainedPropertyCxxDestructor alloc] init];
            cxxDestructor.object = self;
            [cxxDestructor registerOffset:offset];
            objc_setAssociatedObject(self, &pdl_addCxxDestructor, cxxDestructor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

static id pdl_weakPropertyGetter(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    ptrdiff_t offset = (ptrdiff_t)_data;
    id __autoreleasing *location = (id __autoreleasing *)(void *)(((char *)(__bridge void *)self) + offset);
    return objc_loadWeak(location);
}

static void pdl_weakPropertySetter(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id property) {
    PDLImplementationInterceptorRecover(_cmd);
    ptrdiff_t offset = (ptrdiff_t)_data;
    id __autoreleasing *location = (id __autoreleasing *)(void *)(((char *)(__bridge void *)self) + offset);
    objc_storeWeak(location, property);
    pdl_addCxxDestructor(self, _class, offset);
}

+ (BOOL)pdl_weakifyUnsafeUnretainedProperty:(NSString *)propertyName {
    return [self pdl_weakifyUnsafeUnretainedProperty:propertyName ivarName:nil ivarClass:nil];
}

+ (BOOL)pdl_weakifyUnsafeUnretainedProperty:(NSString *)propertyName ivarName:(NSString *)ivarName {
    return [self pdl_weakifyUnsafeUnretainedProperty:propertyName ivarName:ivarName ivarClass:nil];
}

+ (BOOL)pdl_weakifyUnsafeUnretainedProperty:(NSString *)propertyName ivarName:(NSString *)ivarName ivarClass:(Class)ivarClass {
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
    NSString *ivarString = ivarName;
    for (NSString *attributeString in attributeList) {
        if ([attributeString hasPrefix:@"G"]) {
            getterString = [attributeString substringFromIndex:1];
        }
        if ([attributeString hasPrefix:@"S"]) {
            setterString = [attributeString substringFromIndex:1];
        }
        if ([attributeString hasPrefix:@"V"] && ivarName == NULL) {
            ivarString = [attributeString substringFromIndex:1];
        }
    }

    if (!ivarString) {
        return NO;
    }

    SEL getter = NSSelectorFromString(getterString);
    if (!getter) {
        return NO;
    }

    SEL setter = NSSelectorFromString(setterString);
    if (!setter) {
        return NO;
    }

    Ivar ivar = class_getInstanceVariable(ivarClass ?: aClass, ivarString.UTF8String);
    if (ivar == NULL) {
        return NO;
    }

    ptrdiff_t offset = ivar_getOffset(ivar);

    BOOL ret = pdl_interceptSelector(aClass, getter, (IMP)&pdl_weakPropertyGetter, nil, NO, (void *)offset);
    ret &= pdl_interceptSelector(aClass, setter, (IMP)&pdl_weakPropertySetter, nil, NO, (void *)offset);

    return ret;
}

@end
