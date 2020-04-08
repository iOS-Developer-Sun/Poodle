//
//  NSObject+PDLWeakifyUnsafeUnretainedProperty.m
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSObject+PDLWeakifyUnsafeUnretainedProperty.h"
#import <objc/runtime.h>
#import <objc/message.h>

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

static void *PDLWeakifyUnsafeUnretainedPropertyCxxDestructorKey = NULL;
static void PDLWeakifyUnsafeUnretainedPropertyAddCxxDestructor(__unsafe_unretained id self, ptrdiff_t offset) {
    PDLWeakifyUnsafeUnretainedPropertyCxxDestructor *cxxDestructor =  objc_getAssociatedObject(self, &PDLWeakifyUnsafeUnretainedPropertyCxxDestructorKey);
    @synchronized ([PDLWeakifyUnsafeUnretainedPropertyCxxDestructor class]) {
        if (cxxDestructor == nil) {
            cxxDestructor = [[PDLWeakifyUnsafeUnretainedPropertyCxxDestructor alloc] init];
            cxxDestructor.object = self;
            [cxxDestructor registerOffset:offset];
            objc_setAssociatedObject(self, &PDLWeakifyUnsafeUnretainedPropertyCxxDestructorKey, cxxDestructor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

static BOOL PDLWeakifyUnsafeUnretainedProperty(Class aClass, NSString *propertyName) {
    if (propertyName.length == 0) {
        return NO;
    }

    objc_property_t property = class_getProperty(aClass, propertyName.UTF8String);
    if (!property) {
        return NO;
    }

    const char *attributes = property_getAttributes(property);
    NSArray *attributeList = [@(attributes) componentsSeparatedByString:@","];

    NSString *setterString = [NSString stringWithFormat:@"set%@%@:", [propertyName substringToIndex:1].uppercaseString, [propertyName substringFromIndex:1]];
    NSString *ivarString = nil;
    for (NSString *attributeString in attributeList) {
        if ([attributeString hasPrefix:@"S"]) {
            setterString = [attributeString substringFromIndex:1];
        }
        if ([attributeString hasPrefix:@"V"]) {
            ivarString = [attributeString substringFromIndex:1];
        }
    }

    if (!ivarString) {
        return NO;
    }

    SEL selector = NSSelectorFromString(setterString);
    if (!selector) {
        return NO;
    }

    Ivar ivar = class_getInstanceVariable(aClass, ivarString.UTF8String);
    if (ivar == NULL) {
        return NO;
    }

    Method method = class_getInstanceMethod(aClass, selector);
    if (method == NULL) {
        return NO;
    }

    IMP originalImplementation = method_getImplementation(method);
    const char *typeEncoding = method_getTypeEncoding(method);
    ptrdiff_t offset = ivar_getOffset(ivar);
    id block = ^(__unsafe_unretained id self, __unsafe_unretained id property) {
        id __autoreleasing *location = (id __autoreleasing *)(void *)(((char *)(__bridge void *)self) + offset);
        ((void (*)(id, SEL, id))originalImplementation)(self, selector, property);
        objc_storeWeak(location, property);
        PDLWeakifyUnsafeUnretainedPropertyAddCxxDestructor(self, offset);
    };

    IMP blockImplementation = imp_implementationWithBlock(block);
    IMP replacedImplementation = class_replaceMethod(aClass, selector, blockImplementation, typeEncoding);
    assert(replacedImplementation == originalImplementation);

    return YES;
}

+ (BOOL)pdl_weakifyUnsafeUnretainedProperty:(NSString *)propertyName {
    return PDLWeakifyUnsafeUnretainedProperty(self, propertyName);
}

@end
