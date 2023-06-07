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
    [observer recordClass:aClass selectorString:NSStringFromSelector(sel) isSetter:isSetter];
}

static void dictionaryRegister(__unsafe_unretained id dictionary) {
    [PDLNonThreadSafeDictionaryObserverObject registerObject:dictionary];
}

#pragma mark - getters

static id dictionaryObjectForKey(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, __unsafe_unretained id key) {
    PDLImplementationInterceptorRecover(_cmd);
    id ret = ((typeof(&dictionaryObjectForKey))_imp)(self, _cmd, key);
    dictionaryLog(self, _class, _cmd, NO);
    return ret;
}

static NSUInteger dictionaryCount(__unsafe_unretained NSMutableDictionary *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    NSUInteger ret = ((typeof(&dictionaryCount))_imp)(self, _cmd);
    dictionaryLog(self, _class, _cmd, NO);
    return ret;
}

static id dictionaryKeyEnumerator(__unsafe_unretained NSMutableDictionary *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    id ret = ((typeof(&dictionaryKeyEnumerator))_imp)(self, _cmd);
    dictionaryLog(self, _class, _cmd, NO);
    return ret;
}

static BOOL dictionaryIsEqualToDictionary(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, __unsafe_unretained id dictionary) {
    PDLImplementationInterceptorRecover(_cmd);
    BOOL ret = ((typeof(&dictionaryIsEqualToDictionary))_imp)(self, _cmd, dictionary);
    dictionaryLog(self, _class, _cmd, NO);
    return ret;
}

static id dictionaryObjectsForKeysNotFoundMarker(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, __unsafe_unretained id keys, __unsafe_unretained id marker) {
    PDLImplementationInterceptorRecover(_cmd);
    id ret = ((typeof(&dictionaryObjectsForKeysNotFoundMarker))_imp)(self, _cmd, keys, marker);
    dictionaryLog(self, _class, _cmd, NO);
    return ret;
}

#pragma mark - setters

static void dictionarySetObjectForKey(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, __unsafe_unretained id object, __unsafe_unretained id key) {
    PDLImplementationInterceptorRecover(_cmd);
    ((typeof(&dictionarySetObjectForKey))_imp)(self, _cmd, object, key);
    dictionaryLog(self, _class, _cmd, YES);
}

static void dictionaryRemoveObjectForKey(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, __unsafe_unretained id argument) {
    PDLImplementationInterceptorRecover(_cmd);
    ((typeof(&dictionaryRemoveObjectForKey))_imp)(self, _cmd, argument);
    dictionaryLog(self, _class, _cmd, YES);
}

static void dictionaryRemoveAllObjects(__unsafe_unretained NSMutableDictionary *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    ((typeof(&dictionaryRemoveAllObjects))_imp)(self, _cmd);
    dictionaryLog(self, _class, _cmd, YES);
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
        __unused BOOL ret = [dictionaryClass pdl_interceptClusterSelector:@selector(objectForKey:) withInterceptorImplementation:(IMP)&dictionaryObjectForKey];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(objectForKeyedSubscript:) withInterceptorImplementation:(IMP)&dictionaryObjectForKey];

        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(count) withInterceptorImplementation:(IMP)&dictionaryCount];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(keyEnumerator) withInterceptorImplementation:(IMP)&dictionaryKeyEnumerator];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(allKeys) withInterceptorImplementation:(IMP)&dictionaryKeyEnumerator];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(allValues) withInterceptorImplementation:(IMP)&dictionaryKeyEnumerator];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(allKeysForObject:) withInterceptorImplementation:(IMP)&dictionaryObjectForKey];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(isEqualToDictionary:) withInterceptorImplementation:(IMP)&dictionaryIsEqualToDictionary];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(objectEnumerator) withInterceptorImplementation:(IMP)&dictionaryKeyEnumerator];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(objectsForKeys:notFoundMarker:) withInterceptorImplementation:(IMP)&dictionaryObjectsForKeysNotFoundMarker];

        Class mutableDictionaryClass = [NSMutableDictionary class];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(setObject:forKey:) withInterceptorImplementation:(IMP)&dictionarySetObjectForKey];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(setObject:forKeyedSubscript:) withInterceptorImplementation:(IMP)&dictionarySetObjectForKey];

        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(removeObjectForKey:) withInterceptorImplementation:(IMP)&dictionaryRemoveObjectForKey];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(removeObjectsForKeys:) withInterceptorImplementation:(IMP)&dictionaryRemoveObjectForKey];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(addEntriesFromDictionary:) withInterceptorImplementation:(IMP)&dictionaryRemoveObjectForKey];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(setDictionary:) withInterceptorImplementation:(IMP)&dictionaryRemoveObjectForKey];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(removeAllObjects) withInterceptorImplementation:(IMP)&dictionaryRemoveAllObjects];

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
