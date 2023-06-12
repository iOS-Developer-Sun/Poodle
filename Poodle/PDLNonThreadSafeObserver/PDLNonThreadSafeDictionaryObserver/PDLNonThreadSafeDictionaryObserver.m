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

static void logBegin(__unsafe_unretained id self, Class aClass, SEL sel, BOOL isSetter) {
    if ([PDLNonThreadSafeObserver ignoredForObject:self]) {
        return;
    }

    PDLNonThreadSafeDictionaryObserverObject *observer = [PDLNonThreadSafeDictionaryObserverObject observerObjectForObject:self];
    if (!observer) {
        return;
    }

    BOOL ready = [observer startRecording];
    if (!ready) {
        return;
    }

    [observer recordClass:aClass selectorString:NSStringFromSelector(sel) isSetter:isSetter];
//    NSLog(@"%@ %@ %@", aClass, NSStringFromSelector(sel), @(isSetter));
}

static void logEnd(__unsafe_unretained id self, Class aClass, SEL sel, BOOL isSetter) {
    if ([PDLNonThreadSafeObserver ignoredForObject:self]) {
        return;
    }

    PDLNonThreadSafeDictionaryObserverObject *observer = [PDLNonThreadSafeDictionaryObserverObject observerObjectForObject:self];
    if (!observer) {
        return;
    }

    [observer finishRecording];
}

static void dictionaryRegister(__unsafe_unretained id dictionary) {
    if ([dictionary isKindOfClass:[NSMutableDictionary class]]) {
        [PDLNonThreadSafeDictionaryObserverObject registerObject:dictionary];
    }
}

#pragma mark - imp

#define DECL_IMP(FUNC_NAME) \
static void *FUNC_NAME(__unsafe_unretained NSMutableArray *self, SEL _cmd) {\
    PDLImplementationInterceptorRecover(_cmd);\
    logBegin(self, _class, _cmd, _data);\
    void *ret = NULL;\
    if (_imp) {\
        ret = ((typeof(&FUNC_NAME))_imp)(self, _cmd);\
    } else {\
        _imp = &objc_msgSendSuper;\
        struct objc_super su = {self, class_getSuperclass(_class)};\
        ret = ((typeof(&FUNC_NAME))_imp)((__bridge typeof(self))&su, _cmd);\
    }\
    logEnd(self, _class, _cmd, _data);\
    return ret;\
}

#define DECL_IMP1(FUNC_NAME, TYPE1) \
static void *FUNC_NAME(__unsafe_unretained NSMutableArray *self, SEL _cmd, TYPE1 a1) {\
    PDLImplementationInterceptorRecover(_cmd);\
    logBegin(self, _class, _cmd, _data);\
    void *ret = NULL;\
    if (_imp) {\
        ret = ((typeof(&FUNC_NAME))_imp)(self, _cmd, a1);\
    } else {\
        _imp = &objc_msgSendSuper;\
        struct objc_super su = {self, class_getSuperclass(_class)};\
        ret = ((typeof(&FUNC_NAME))_imp)((__bridge typeof(self))&su, _cmd, a1);\
    }\
    logEnd(self, _class, _cmd, _data);\
    return ret;\
}

#define DECL_IMP2(FUNC_NAME, TYPE1, TYPE2) \
static void *FUNC_NAME(__unsafe_unretained NSMutableArray *self, SEL _cmd, TYPE1 a1, TYPE2 a2) {\
    PDLImplementationInterceptorRecover(_cmd);\
    logBegin(self, _class, _cmd, _data);\
    void *ret = NULL;\
    if (_imp) {\
        ret = ((typeof(&FUNC_NAME))_imp)(self, _cmd, a1, a2);\
    } else {\
        _imp = &objc_msgSendSuper;\
        struct objc_super su = {self, class_getSuperclass(_class)};\
        ret = ((typeof(&FUNC_NAME))_imp)((__bridge typeof(self))&su, _cmd, a1, a2);\
    }\
    logEnd(self, _class, _cmd, _data);\
    return ret;\
}

#define DECL_IMP3(FUNC_NAME, TYPE1, TYPE2, TYPE3) \
static void *FUNC_NAME(__unsafe_unretained NSMutableArray *self, SEL _cmd, TYPE1 a1, TYPE2 a2, TYPE3 a3) {\
    PDLImplementationInterceptorRecover(_cmd);\
    logBegin(self, _class, _cmd, _data);\
    void *ret = NULL;\
    if (_imp) {\
        ret = ((typeof(&FUNC_NAME))_imp)(self, _cmd, a1, a2, a3);\
    } else {\
        _imp = &objc_msgSendSuper;\
        struct objc_super su = {self, class_getSuperclass(_class)};\
        ret = ((typeof(&FUNC_NAME))_imp)((__bridge typeof(self))&su, _cmd, a1, a2, a3);\
    }\
    logEnd(self, _class, _cmd, _data);\
    return ret;\
}

#define DECL_IMP4(FUNC_NAME, TYPE1, TYPE2, TYPE3, TYPE4) \
static void *FUNC_NAME(__unsafe_unretained NSMutableArray *self, SEL _cmd, TYPE1 a1, TYPE2 a2, TYPE3 a3, TYPE4 a4) {\
    PDLImplementationInterceptorRecover(_cmd);\
    logBegin(self, _class, _cmd, _data);\
    void *ret = NULL;\
    if (_imp) {\
        ret = ((typeof(&FUNC_NAME))_imp)(self, _cmd, a1, a2, a3, a4);\
    } else {\
        _imp = &objc_msgSendSuper;\
        struct objc_super su = {self, class_getSuperclass(_class)};\
        ret = ((typeof(&FUNC_NAME))_imp)((__bridge typeof(self))&su, _cmd, a1, a2, a3, a4);\
    }\
    logEnd(self, _class, _cmd, _data);\
    return ret;\
}

DECL_IMP(impA0);
DECL_IMP1(impA1, void *);
DECL_IMP1(impR1, NSRange);
DECL_IMP2(impA2, void *, void *);
DECL_IMP3(impA3, void *, void *, void *);
DECL_IMP2(impA1R1, void *, NSRange);
DECL_IMP2(impR1A1, NSRange, void *);
DECL_IMP3(impR1A1R1, NSRange, void *, NSRange);
DECL_IMP4(impA1R1A2, void *, NSRange, void *, void *);

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

static id initWithObjectsForKeysCount(__unsafe_unretained id *self, SEL _cmd, void *objects, void *keys, NSUInteger count) {
    PDLImplementationInterceptorRecover(_cmd);
    id dictionary = ((typeof(&initWithObjectsForKeysCount))_imp)(self, _cmd, objects, keys, count);
    dictionaryRegister(dictionary);
    return dictionary;
}

static id initWithDictionaryCopyItems(__unsafe_unretained id *self, SEL _cmd, __unsafe_unretained id *d, BOOL copyItems) {
    PDLImplementationInterceptorRecover(_cmd);
    id dictionary = ((typeof(&initWithDictionaryCopyItems))_imp)(self, _cmd, d, copyItems);
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
        __unused BOOL ret = YES;

        // getters
        Class dictionaryClass = [NSDictionary class];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(count) withInterceptorImplementation:(IMP)&impA0];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(objectForKey:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(keyEnumerator) withInterceptorImplementation:(IMP)&impA0];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(allKeys) withInterceptorImplementation:(IMP)&impA0];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(allKeysForObject:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(allValues) withInterceptorImplementation:(IMP)&impA0];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(description) withInterceptorImplementation:(IMP)&impA0];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(descriptionInStringsFileFormat) withInterceptorImplementation:(IMP)&impA0];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(descriptionWithLocale:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(descriptionWithLocale:indent:) withInterceptorImplementation:(IMP)&impA2];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(isEqualToDictionary:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(objectEnumerator) withInterceptorImplementation:(IMP)&impA0];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(objectsForKeys:notFoundMarker:) withInterceptorImplementation:(IMP)&impA2];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(writeToURL:error:) withInterceptorImplementation:(IMP)&impA2];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(keysSortedByValueUsingSelector:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(getObjects:andKeys:count:) withInterceptorImplementation:(IMP)&impA3];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(objectForKeyedSubscript:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(enumerateKeysAndObjectsUsingBlock:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(enumerateKeysAndObjectsWithOptions:usingBlock:) withInterceptorImplementation:(IMP)&impA2];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(keysSortedByValueUsingComparator:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(keysSortedByValueWithOptions:usingComparator:) withInterceptorImplementation:(IMP)&impA2];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(keysOfEntriesPassingTest:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(keysOfEntriesWithOptions:passingTest:) withInterceptorImplementation:(IMP)&impA2];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(getObjects:andKeys:) withInterceptorImplementation:(IMP)&impA2];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(writeToFile:atomically:) withInterceptorImplementation:(IMP)&impA2];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(writeToURL:atomically:) withInterceptorImplementation:(IMP)&impA2];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(valueForKey:) withInterceptorImplementation:(IMP)&impA1];

        // setters
        Class mutableDictionaryClass = [NSMutableDictionary class];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(removeObjectForKey:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:(void *)YES];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(setObject:forKey:) withInterceptorImplementation:(IMP)&impA2 isStructRet:@(NO) addIfNotExistent:NO data:(void *)YES];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(addEntriesFromDictionary:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:(void *)YES];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(removeAllObjects) withInterceptorImplementation:(IMP)&impA0 isStructRet:@(NO) addIfNotExistent:NO data:(void *)YES];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(removeObjectsForKeys:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:(void *)YES];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(setDictionary:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:(void *)YES];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(setObject:forKeyedSubscript:) withInterceptorImplementation:(IMP)&impA2 isStructRet:@(NO) addIfNotExistent:NO data:(void *)YES];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(setValue:forKey:) withInterceptorImplementation:(IMP)&impA2 isStructRet:@(NO) addIfNotExistent:NO data:(void *)YES];

        // creations
        BOOL m1 = [dictionaryClass pdl_interceptClusterSelector:@selector(mutableCopy) withInterceptorImplementation:(IMP)&mutableCopy];
        BOOL m2 = [dictionaryClass pdl_interceptClusterSelector:@selector(mutableCopyWithZone:) withInterceptorImplementation:(IMP)&mutableCopyWithZone];
        ret = ret && (m1 || m2);

        Class placeholderClass = NSClassFromString(@"__NSPlaceholderDictionary");
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithCapacity:) withInterceptorImplementation:(IMP)&initWithCapacity];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithContentsOfFile:) withInterceptorImplementation:(IMP)&initWithCapacity];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithContentsOfURL:) withInterceptorImplementation:(IMP)&initWithCapacity];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithObjects:forKeys:count:) withInterceptorImplementation:(IMP)&initWithObjectsForKeysCount];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithDictionary:copyItems:) withInterceptorImplementation:(IMP)&initWithDictionaryCopyItems];
        assert(ret);
    });
}

@end
