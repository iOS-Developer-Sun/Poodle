//
//  PDLNonThreadSafeDictionaryObserver.m
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeDictionaryObserver.h"
#import "PDLNonThreadSafeClusterObserver.h"
#import "PDLNonThreadSafeDictionaryObserverObject.h"
#import "NSObject+PDLImplementationInterceptor.h"
#import "PDLNonThreadSafeObserver.h"

@implementation PDLNonThreadSafeDictionaryObserver

+ (void)registerObject:(id)object {
    if ([object isKindOfClass:[NSMutableDictionary class]]) {
        [PDLNonThreadSafeDictionaryObserverObject registerObject:object];
    }
}

PDLNonThreadSafeClusterObserverDeclLogImp(logA0);
PDLNonThreadSafeClusterObserverDeclLogImp1(logA1, void *);
PDLNonThreadSafeClusterObserverDeclLogImp2(logA2, void *, void *);
PDLNonThreadSafeClusterObserverDeclLogImp3(logA3, void *, void *, void *);

PDLNonThreadSafeClusterObserverDeclRegisterImp(registerA0);
PDLNonThreadSafeClusterObserverDeclRegisterImp1(registerA1, void *);
PDLNonThreadSafeClusterObserverDeclRegisterImp2(registerA2, void *, void *);
PDLNonThreadSafeClusterObserverDeclRegisterImp3(registerA3, void *, void *, void *);

static BOOL (^_filter)(PDLBacktrace *backtrace, NSString **name) = nil;
+ (BOOL (^)(PDLBacktrace *backtrace, NSString **name))filter {
    return _filter;
}

+ (void)observeWithFilter:(BOOL(^)(PDLBacktrace *backtrace, NSString **name))filter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _filter = filter;

        static PDLNonThreadSafeClusterObserverLogData *getter = nil;
        getter = [[PDLNonThreadSafeClusterObserverLogData alloc] init];
        getter.clusterClass = [PDLNonThreadSafeDictionaryObserverObject class];

        static PDLNonThreadSafeClusterObserverLogData *exclusiveGetter = nil;
        exclusiveGetter = [[PDLNonThreadSafeClusterObserverLogData alloc] init];
        exclusiveGetter.clusterClass = [PDLNonThreadSafeDictionaryObserverObject class];
        exclusiveGetter.isExclusive = YES;

        static PDLNonThreadSafeClusterObserverLogData *setter = nil;
        setter = [[PDLNonThreadSafeClusterObserverLogData alloc] init];
        setter.clusterClass = [PDLNonThreadSafeDictionaryObserverObject class];
        setter.isSetter = YES;

        __unused BOOL ret = YES;

        // getters
        Class dictionaryClass = [NSDictionary class];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(count) withInterceptorImplementation:(IMP)&logA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(objectForKey:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(keyEnumerator) withInterceptorImplementation:(IMP)&logA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(allKeys) withInterceptorImplementation:(IMP)&logA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(allKeysForObject:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(allValues) withInterceptorImplementation:(IMP)&logA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(description) withInterceptorImplementation:(IMP)&logA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(descriptionInStringsFileFormat) withInterceptorImplementation:(IMP)&logA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(descriptionWithLocale:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(descriptionWithLocale:indent:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(isEqualToDictionary:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(objectEnumerator) withInterceptorImplementation:(IMP)&logA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(objectsForKeys:notFoundMarker:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(writeToURL:error:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(keysSortedByValueUsingSelector:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(getObjects:andKeys:count:) withInterceptorImplementation:(IMP)&logA3 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(objectForKeyedSubscript:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(enumerateKeysAndObjectsUsingBlock:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)exclusiveGetter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(enumerateKeysAndObjectsWithOptions:usingBlock:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)exclusiveGetter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(keysSortedByValueUsingComparator:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(keysSortedByValueWithOptions:usingComparator:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(keysOfEntriesPassingTest:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)exclusiveGetter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(keysOfEntriesWithOptions:passingTest:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)exclusiveGetter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(getObjects:andKeys:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(writeToFile:atomically:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(writeToURL:atomically:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [dictionaryClass pdl_interceptClusterSelector:@selector(valueForKey:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];

        // setters
        Class mutableDictionaryClass = [NSMutableDictionary class];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(removeObjectForKey:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(setObject:forKey:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(addEntriesFromDictionary:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(removeAllObjects) withInterceptorImplementation:(IMP)&logA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(removeObjectsForKeys:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(setDictionary:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(setObject:forKeyedSubscript:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableDictionaryClass pdl_interceptClusterSelector:@selector(setValue:forKey:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];

        // creations
        BOOL m1 = [dictionaryClass pdl_interceptClusterSelector:@selector(mutableCopy) withInterceptorImplementation:(IMP)&registerA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)self];
        BOOL m2 = [dictionaryClass pdl_interceptClusterSelector:@selector(mutableCopyWithZone:) withInterceptorImplementation:(IMP)&registerA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)self];
        ret = ret && (m1 || m2);

        Class placeholderClass = NSClassFromString(@"__NSPlaceholderDictionary");
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithCapacity:) withInterceptorImplementation:(IMP)&registerA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)self];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithContentsOfFile:) withInterceptorImplementation:(IMP)&registerA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)self];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithContentsOfURL:) withInterceptorImplementation:(IMP)&registerA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)self];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithObjects:forKeys:count:) withInterceptorImplementation:(IMP)&registerA3 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)self];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithDictionary:copyItems:) withInterceptorImplementation:(IMP)&registerA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)self];
        assert(ret);
    });
}

@end
