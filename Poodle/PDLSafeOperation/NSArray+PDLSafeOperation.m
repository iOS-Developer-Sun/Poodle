//
//  NSArray+PDLSafeOperation.m
//  Poodle
//
//  Created by Poodle on 07/04/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+PDLImplementationInterceptor.h"

#if __has_feature(objc_arc)
#error This file must be compiled with flag "-fno-objc-arc"
#endif

@implementation NSArray (PDLSafeOperation)

static id pdl_arrayWithObjectsCount(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id *objects, NSUInteger count) {
    PDLImplementationInterceptorRecover(_cmd);

    __unsafe_unretained id *validObjects = (__unsafe_unretained id *)malloc(sizeof(id) * count);
    NSUInteger validCount = 0;
    for (NSUInteger i = 0; i < count; i++) {
        id object = objects[i];
        if (object == nil) {
            NSAssert(NO, @"array with nil object!");
            continue;
        }

        validObjects[validCount] = object;
        validCount++;
    }

    id array = ((typeof(&pdl_arrayWithObjectsCount))_imp)(self, _cmd, validObjects, validCount);
    for (NSUInteger i = 0; i < validCount; i++) {
        validObjects[i] = nil;
    }
    free(validObjects);

    return array;
}

static id pdl_objectAtIndex(__unsafe_unretained NSArray *self, SEL _cmd, NSUInteger idx) {
    PDLImplementationInterceptorRecover(_cmd);

    if (idx >= self.count) {
        NSAssert(NO, @"array %s out of range!", sel_getName(_cmd));
        return nil;
    }

    __unsafe_unretained id ret = ((typeof(&pdl_objectAtIndex))_imp)(self, _cmd, idx);
    return ret;
}

static void pdl_setObjectAtIndex(__unsafe_unretained NSMutableArray *self, SEL _cmd, __unsafe_unretained id obj, NSUInteger idx) {
    PDLImplementationInterceptorRecover(_cmd);

    if (idx > self.count) {
        NSAssert(NO, @"array set object at index out of range!");
        return;
    }

    if (obj == nil) {
        NSAssert(NO, @"array set nil object at index!");
        return;
    }

    ((typeof(&pdl_setObjectAtIndex))_imp)(self, _cmd, obj, idx);
}

+ (void)pdl_safeOperationEnable {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            id metaClass = object_getClass([NSArray class]);
            __unused BOOL ret = [metaClass pdl_interceptSelector:@selector(arrayWithObjects:count:) withInterceptorImplementation:(IMP)&pdl_arrayWithObjectsCount];
            NSAssert(ret, @"arrayWithObjects:count:");
        }
        {
            __unused NSUInteger ret = [NSArray pdl_interceptClusterSelector:@selector(objectAtIndex:) withInterceptorImplementation:(IMP)&pdl_objectAtIndex];
            NSAssert(ret > 0, @"objectAtIndex:");
        }
        {
            __unused NSUInteger ret = [NSArray pdl_interceptClusterSelector:@selector(objectAtIndexedSubscript:) withInterceptorImplementation:(IMP)&pdl_objectAtIndex];
            NSAssert(ret > 0, @"objectAtIndexedSubscript:");
        }
        {
            __unused NSUInteger ret = [NSMutableArray pdl_interceptClusterSelector:@selector(setObject:atIndex:) withInterceptorImplementation:(IMP)&pdl_setObjectAtIndex];
            NSAssert(ret > 0, @"setObject:atIndex:");
        }
        {
            __unused NSUInteger ret = [NSMutableArray pdl_interceptClusterSelector:@selector(setObject:atIndexedSubscript:) withInterceptorImplementation:(IMP)&pdl_setObjectAtIndex];
            NSAssert(ret > 0, @"setObject:atIndexedSubscript:");
        }
    });
}

@end
