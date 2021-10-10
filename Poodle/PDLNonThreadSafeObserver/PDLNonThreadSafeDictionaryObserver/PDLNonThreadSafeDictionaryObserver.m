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

static id dictionaryObjectForKey(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, __unsafe_unretained id key) {
    PDLImplementationInterceptorRecover(_cmd);
    id ret = ((typeof(&dictionaryObjectForKey))_imp)(self, _cmd, key);
    dictionaryLog(self, _class, _cmd, NO);
    return ret;
}

static void dictionarySetObjectForKey(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, __unsafe_unretained id object, __unsafe_unretained id key) {
    PDLImplementationInterceptorRecover(_cmd);
    ((typeof(&dictionarySetObjectForKey))_imp)(self, _cmd, object, key);
    dictionaryLog(self, _class, _cmd, YES);
}

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

+ (void)enable {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = [NSMutableDictionary class];
        __unused BOOL ret = [aClass pdl_interceptClusterSelector:@selector(objectForKey:) withInterceptorImplementation:(IMP)&dictionaryObjectForKey];
        ret = ret && [aClass pdl_interceptClusterSelector:@selector(objectForKeyedSubscript:) withInterceptorImplementation:(IMP)&dictionaryObjectForKey];
        ret = ret && [aClass pdl_interceptClusterSelector:@selector(setObject:forKey:) withInterceptorImplementation:(IMP)&dictionarySetObjectForKey];
        ret = ret && [aClass pdl_interceptClusterSelector:@selector(setObject:forKeyedSubscript:) withInterceptorImplementation:(IMP)&dictionarySetObjectForKey];

        ret = ret && [aClass pdl_interceptClusterSelector:@selector(mutableCopy) withInterceptorImplementation:(IMP)&mutableCopy];
        ret = ret && [aClass pdl_interceptClusterSelector:@selector(mutableCopyWithZone:) withInterceptorImplementation:(IMP)&mutableCopyWithZone];

        Class placeholder = NSClassFromString(@"__NSPlaceholderDictionary");
        ret = ret && [placeholder pdl_interceptSelector:@selector(initWithCapacity:) withInterceptorImplementation:(IMP)&initWithCapacity];
        ret = ret && [placeholder pdl_interceptSelector:@selector(initWithContentsOfFile:) withInterceptorImplementation:(IMP)&initWithContents];
        ret = ret && [placeholder pdl_interceptSelector:@selector(initWithContentsOfURL:) withInterceptorImplementation:(IMP)&initWithContents];
        ret = ret && [placeholder pdl_interceptSelector:@selector(initWithObjects:forKeys:count:) withInterceptorImplementation:(IMP)&initWithObjectsForKeysCount];
        assert(ret);
    });
}

@end
