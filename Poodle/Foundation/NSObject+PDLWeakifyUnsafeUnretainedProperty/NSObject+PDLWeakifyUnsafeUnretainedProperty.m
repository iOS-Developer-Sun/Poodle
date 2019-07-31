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

@implementation NSObject (PDLWeakifyUnsafeUnretainedProperty)

static id NSObjectWeakifyPropertyLockObject(void) {
    static id object = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object = [NSObject new];
    });
    return object;
}

static BOOL NSObjectWeakifyProperty(Class aClass, NSString *propertyName, BOOL needsSync) {
    NSString *ivarName = [@"_" stringByAppendingString:propertyName];
    Ivar ivar = class_getInstanceVariable(aClass, ivarName.UTF8String);
    if (ivar == NULL) {
        return NO;
    }

    NSString *setterName = [NSString stringWithFormat:@"set%@%@:", [propertyName substringToIndex:1].uppercaseString, [propertyName substringFromIndex:1]];
    SEL selector = NSSelectorFromString(setterName);
    Method method = class_getInstanceMethod(aClass, selector);
    if (method == NULL) {
        return NO;
    }

    IMP originalImplementation = method_getImplementation(method);
    const char *typeEncoding = method_getTypeEncoding(method);
    ptrdiff_t offset = ivar_getOffset(ivar);
    id block = ^(__unsafe_unretained id self, __unsafe_unretained id property) {
        id __autoreleasing *location = (id __autoreleasing *)(void *)(((char *)(__bridge void *)self) + offset);
        if (needsSync) {
            @synchronized (NSObjectWeakifyPropertyLockObject()) {
                ((void (*)(id, SEL, id))originalImplementation)(self, selector, property);
                objc_storeWeak(location, property);
            }
        } else {
            ((void (*)(id, SEL, id))originalImplementation)(self, selector, property);
            objc_storeWeak(location, property);
        }
    };

    IMP blockImplementation = imp_implementationWithBlock(block);
    IMP replacedImplementation = class_replaceMethod(aClass, selector, blockImplementation, typeEncoding);
    assert(replacedImplementation == originalImplementation);

    return YES;
}

+ (BOOL)pdl_weakifyProperty:(NSString *)propertyName {
    return [self pdl_weakifyProperty:propertyName needsSync:NO];
}

+ (BOOL)pdl_weakifyProperty:(NSString *)propertyName needsSync:(BOOL)needsSync {
    return NSObjectWeakifyProperty(self, propertyName, needsSync);
}

@end
