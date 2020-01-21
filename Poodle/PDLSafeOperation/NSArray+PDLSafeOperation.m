//
//  NSArray+SafeOperation.m
//  Poodle
//
//  Created by Poodle on 07/04/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSArray+PDLSafeOperation.h"
#import "NSObject+PDLImplementationInterceptor.h"

#if __has_feature(objc_arc)
#error This file must be compiled with flag "-fno-objc-arc"
#endif

@implementation NSArray (SafeOperation)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            id metaClass = object_getClass([NSArray class]);
            BOOL ret = [metaClass pdl_interceptSelector:@selector(arrayWithObjects:count:) withInterceptorImplementation:(IMP)&NSArray_SafeOperation_arrayWithObjects_count_Imp];
            (void)ret;
            NSAssert(ret, @"arrayWithObjects:count: not protected");
        }
        {
            NSUInteger ret = [NSArray pdl_interceptClusterSelector:@selector(objectAtIndex:) withInterceptorImplementation:(IMP)&NSArray_SafeOperation_objectAtIndex_Imps];
            (void)ret;
            NSAssert(ret > 0, @"objectAtIndex: not protected");
        }
        {
            NSUInteger ret = [NSArray pdl_interceptClusterSelector:@selector(objectAtIndexedSubscript:) withInterceptorImplementation:(IMP)&NSArray_SafeOperation_objectAtIndex_Imps];
            (void)ret;
            NSAssert(ret > 0, @"objectAtIndexedSubscript: not pretected");
        }
        {
            NSUInteger ret = [NSMutableArray pdl_interceptClusterSelector:@selector(setObject:atIndexedSubscript:) withInterceptorImplementation:(IMP)&NSMutableArray_SafeOperation_setObject_atIndexedSubscript_Imp];
            (void)ret;
            NSAssert(ret > 0, @"setObject:atIndexedSubscript: not pretected");
        }
    });
}

static id NSArray_SafeOperation_arrayWithObjects_count_Imp(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id *objects, NSUInteger count) {
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

    id array = ((id(*)(id, SEL, __unsafe_unretained id *, NSUInteger))_imp)(self, _cmd, validObjects, validCount);
    for (NSUInteger i = 0; i < validCount; i++) {
        validObjects[i] = nil;
    }
    free(validObjects);

    return array;
}

static id NSArray_SafeOperation_objectAtIndex_Imps(__unsafe_unretained NSArray *self, SEL _cmd, NSUInteger idx) {
    PDLImplementationInterceptorRecover(_cmd);

    if (idx >= self.count) {
        NSAssert(NO, @"array %s out of range!", sel_getName(_cmd));
        return nil;
    }

    __unsafe_unretained id ret = ((id(*)(__unsafe_unretained id, SEL, NSUInteger))_imp)(self, _cmd, idx);
    return ret;
}

static void NSMutableArray_SafeOperation_setObject_atIndexedSubscript_Imp(__unsafe_unretained NSMutableArray *self, SEL _cmd, __unsafe_unretained id obj, NSUInteger idx) {
    PDLImplementationInterceptorRecover(_cmd);

    if (idx > self.count) {
        NSAssert(NO, @"array set object at indexed subscript out of range!");
        return;
    }

    if (obj == nil) {
        NSAssert(NO, @"array set nil object at indexed subscript!");
        return;
    }

    ((void(*)(id, SEL, id, NSUInteger))_imp)(self, _cmd, obj, idx);
}

@end
