//
//  PDLNonThreadSafeDictionaryObserver.m
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeDictionaryObserver.h"
#import "PDLNonThreadSafeDictionaryObserverObject.h"
#import "NSObject+PDLImplementationInterceptor.h"
#import "PDLNonThreadSafeObserver.h"

@implementation PDLNonThreadSafeDictionaryObserver

static void dictionaryLog(__unsafe_unretained id self, Class aClass, SEL sel, BOOL isSetter) {
    if ([PDLNonThreadSafeObserver ignoredForObject:self]) {
        return;
    }

    PDLNonThreadSafeDictionaryObserverObject *observer = [PDLNonThreadSafeDictionaryObserverObject observerObjectForObject:self];
    if (!observer) {
        return;
    }

    [observer recordClass:aClass selectorString:NSStringFromSelector(sel) isSetter:isSetter];
}

static void dictionaryRegister(__unsafe_unretained id dictionary) {
    [PDLNonThreadSafeDictionaryObserverObject registerObject:dictionary];
}

#pragma mark - getters

static void *getterA0(__unsafe_unretained NSMutableDictionary *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    void *ret = ((typeof(&getterA0))_imp)(self, _cmd);
    dictionaryLog(self, _class, _cmd, NO);
    return ret;
}

static void *getterA1(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, void *a1) {
    PDLImplementationInterceptorRecover(_cmd);
    void *ret = ((typeof(&getterA1))_imp)(self, _cmd, a1);
    dictionaryLog(self, _class, _cmd, NO);
    return ret;
}

static void *getterA2(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, void *a1, void *a2) {
    PDLImplementationInterceptorRecover(_cmd);
    void *ret = ((typeof(&getterA2))_imp)(self, _cmd, a1, a2);
    dictionaryLog(self, _class, _cmd, NO);
    return ret;
}

#pragma mark - setters

static void *setterA0(__unsafe_unretained NSMutableDictionary *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    void *ret = ((typeof(&setterA0))_imp)(self, _cmd);
    dictionaryLog(self, _class, _cmd, YES);
    return ret;
}

static void *setterA1(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, void *a1) {
    PDLImplementationInterceptorRecover(_cmd);
    void *ret = ((typeof(&setterA1))_imp)(self, _cmd, a1);
    dictionaryLog(self, _class, _cmd, YES);
    return ret;
}

static void *setterA2(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, void *a1, void *a2) {
    PDLImplementationInterceptorRecover(_cmd);
    void *ret = ((typeof(&setterA2))_imp)(self, _cmd, a1, a2);
    dictionaryLog(self, _class, _cmd, YES);
    return ret;
}

#pragma mark - initializers

static id mutableCopy(__unsafe_unretained id *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    id dictionary = ((typeof(&mutableCopy))_imp)(self, _cmd);
    dictionaryRegister(dictionary);
    return dictionary;
}

static id mutableCopyWithZone(__unsafe_unretained id *self, SEL _cmd, struct _NSZone *zone) {
    PDLImplementationInterceptorRecover(_cmd);
    id dictionary = ((typeof(&mutableCopyWithZone))_imp)(self, _cmd, zone);
    dictionaryRegister(dictionary);
    return dictionary;
}

static id initWithCapacity(__unsafe_unretained id *self, SEL _cmd, NSUInteger capacity) {
    PDLImplementationInterceptorRecover(_cmd);
    id dictionary = ((typeof(&initWithCapacity))_imp)(self, _cmd, capacity);
    dictionaryRegister(dictionary);
    return dictionary;
}

static id initWithContents(__unsafe_unretained id *self, SEL _cmd, __unsafe_unretained id contents) {
    PDLImplementationInterceptorRecover(_cmd);
    id dictionary = ((typeof(&initWithContents))_imp)(self, _cmd, contents);
    dictionaryRegister(dictionary);
    return dictionary;
}

static id initWithObjectsForKeysCount(__unsafe_unretained id *self, SEL _cmd, void *objects, void *keys, NSUInteger count) {
    PDLImplementationInterceptorRecover(_cmd);
    id dictionary = ((typeof(&initWithObjectsForKeysCount))_imp)(self, _cmd, objects, keys, count);
    dictionaryRegister(dictionary);
    return dictionary;
}

static BOOL (^_filter)(PDLBacktrace *backtrace, NSString **name) = nil;
+ (BOOL (^)(PDLBacktrace *backtrace, NSString **name))filter {
    return _filter;
}

+ (void)enableWithFilter:(BOOL(^)(PDLBacktrace *backtrace, NSString **name))filter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _filter = filter;
        Class dictionaryClass = [NSDictionary class];
        __unused BOOL ret = [dictionaryClass pdl_interceptClusterSelector:@selector(objectForKey:) withInterceptorImplementation:(IMP)&getterA1];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(objectForKeyedSubscript:) withInterceptorImplementation:(IMP)&getterA1];

        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(count) withInterceptorImplementation:(IMP)&getterA0];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(keyEnumerator) withInterceptorImplementation:(IMP)&getterA0];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(allKeys) withInterceptorImplementation:(IMP)&getterA0];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(allValues) withInterceptorImplementation:(IMP)&getterA0];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(allKeysForObject:) withInterceptorImplementation:(IMP)&getterA1];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(isEqualToDictionary:) withInterceptorImplementation:(IMP)&getterA1];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(objectEnumerator) withInterceptorImplementation:(IMP)&getterA0];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(objectsForKeys:notFoundMarker:) withInterceptorImplementation:(IMP)&getterA2];

        Class mutableDictionaryClass = [NSMutableDictionary class];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(setObject:forKey:) withInterceptorImplementation:(IMP)&setterA2];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(setObject:forKeyedSubscript:) withInterceptorImplementation:(IMP)&setterA2];

        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(removeObjectForKey:) withInterceptorImplementation:(IMP)&setterA1];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(removeObjectsForKeys:) withInterceptorImplementation:(IMP)&setterA1];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(addEntriesFromDictionary:) withInterceptorImplementation:(IMP)&setterA1];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(setDictionary:) withInterceptorImplementation:(IMP)&setterA1];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(removeAllObjects) withInterceptorImplementation:(IMP)&setterA0];

        BOOL m1 = [mutableDictionaryClass pdl_interceptClusterSelector:@selector(mutableCopy) withInterceptorImplementation:(IMP)&mutableCopy];
        BOOL m2 = [mutableDictionaryClass pdl_interceptClusterSelector:@selector(mutableCopyWithZone:) withInterceptorImplementation:(IMP)&mutableCopyWithZone];
        ret = ret && (m1 || m2);

        Class placeholderClass = NSClassFromString(@"__NSPlaceholderDictionary");
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithCapacity:) withInterceptorImplementation:(IMP)&initWithCapacity];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithContentsOfFile:) withInterceptorImplementation:(IMP)&initWithContents];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithContentsOfURL:) withInterceptorImplementation:(IMP)&initWithContents];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithObjects:forKeys:count:) withInterceptorImplementation:(IMP)&initWithObjectsForKeysCount];
        assert(ret);
    });
}

@end
