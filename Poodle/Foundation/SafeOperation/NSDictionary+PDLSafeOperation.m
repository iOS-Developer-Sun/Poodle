//
//  NSDictionary+SafeOperation.m
//  Poodle
//
//  Created by Poodle on 07/04/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSDictionary+PDLSafeOperation.h"
#import "NSObject+PDLImplementationInterceptor.h"

#if __has_feature(objc_arc)
#error This file must be compiled with flag "-fno-objc-arc"
#endif

@implementation NSDictionary (SafeOperation)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            id metaClass = object_getClass([NSDictionary class]);
            BOOL ret = [metaClass pdl_interceptSelector:@selector(dictionaryWithObjects:forKeys:count:) withInterceptorImplementation:(IMP)&NSDictionary_SafeOperation_dictionaryWithObjects_forKeys_count_Imp];
            (void)ret;
            NSAssert(ret, @"dictionaryWithObjects:forKeys:count:");
        }
        {
            NSUInteger ret = [NSMutableDictionary pdl_interceptClusterSelector:@selector(setObject:forKey:) withInterceptorImplementation:(IMP)&NSMutableDictionary_SafeOperation_setObject_forKey_Imps];
            (void)ret;
            NSAssert(ret > 0, @"setObject:forKeyedSubscript: not pretected");
        }
        {
            NSUInteger ret = [NSMutableDictionary pdl_interceptClusterSelector:@selector(setObject:forKeyedSubscript:) withInterceptorImplementation:(IMP)&NSMutableDictionary_SafeOperation_setObject_forKey_Imps];
            (void)ret;
            NSAssert(ret > 0, @"setObject:forKeyedSubscript: not pretected");
        }
    });
}

static id NSDictionary_SafeOperation_dictionaryWithObjects_forKeys_count_Imp(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id *objects, __unsafe_unretained id *keys, NSUInteger count) {
    PDLImplementationInterceptorRecover(_cmd);

    __unsafe_unretained id *validKeys = (__unsafe_unretained id *)malloc(sizeof(id) * count);
    __unsafe_unretained id *validObjects = (__unsafe_unretained id *)malloc(sizeof(id) * count);
    NSUInteger validCount = 0;
    for (NSUInteger i = 0; i < count; i++) {
        __unsafe_unretained id key = keys[i];
        __unsafe_unretained id object = objects[i];
        if (key == nil || object == nil) {
            NSAssert(NO, @"dictionary with nil key or object!");
            continue;
        }

        validKeys[validCount] = key;
        validObjects[validCount] = object;
        validCount++;
    }

    __unsafe_unretained id dictionary = ((NSDictionary *(*)(__unsafe_unretained id, SEL, __unsafe_unretained id *, __unsafe_unretained id *, NSUInteger))_imp)(self, _cmd, validObjects, validKeys, validCount);
    for (NSUInteger i = 0; i < validCount; i++) {
        validKeys[i] = nil;
        validObjects[i] = nil;
    }
    free(validKeys);
    free(validObjects);

    return dictionary;
}

static void NSMutableDictionary_SafeOperation_setObject_forKey_Imps(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id obj, __unsafe_unretained id <NSCopying> key) {
    PDLImplementationInterceptorRecover(_cmd);

    if (key == nil) {
        NSAssert(NO, @"dictionary set object for nil keyed subscript!");
        return;
    }

    ((void (*)(__unsafe_unretained id, SEL, __unsafe_unretained id, __unsafe_unretained id <NSCopying>))_imp)(self, _cmd, obj, key);
}

@end

