//
//  PDLNonThreadSafeArrayObserver.m
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeArrayObserver.h"
#import "PDLNonThreadSafeClusterObserver.h"
#import "PDLNonThreadSafeArrayObserverObject.h"
#import "NSObject+PDLImplementationInterceptor.h"
#import "PDLNonThreadSafeObserver.h"

@implementation PDLNonThreadSafeArrayObserver

+ (void)registerObject:(id)object {
    if ([object isKindOfClass:[NSMutableArray class]]) {
        [PDLNonThreadSafeArrayObserverObject registerObject:object];
    }
}

PDLNonThreadSafeClusterObserverDeclLogImp(logA0);
PDLNonThreadSafeClusterObserverDeclLogImp1(logA1, void *);
PDLNonThreadSafeClusterObserverDeclLogImp1(logR1, NSRange);
PDLNonThreadSafeClusterObserverDeclLogImp2(logA2, void *, void *);
PDLNonThreadSafeClusterObserverDeclLogImp3(logA3, void *, void *, void *);
PDLNonThreadSafeClusterObserverDeclLogImp2(logA1R1, void *, NSRange);
PDLNonThreadSafeClusterObserverDeclLogImp2(logR1A1, NSRange, void *);
PDLNonThreadSafeClusterObserverDeclLogImp3(logR1A1R1, NSRange, void *, NSRange);
PDLNonThreadSafeClusterObserverDeclLogImp4(logA1R1A2, void *, NSRange, void *, void *);

PDLNonThreadSafeClusterObserverDeclRegisterImp(registerA0);
PDLNonThreadSafeClusterObserverDeclRegisterImp1(registerA1, void *);
PDLNonThreadSafeClusterObserverDeclRegisterImp2(registerA2, void *, void *);

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
        getter.clusterClass = [PDLNonThreadSafeArrayObserverObject class];

        static PDLNonThreadSafeClusterObserverLogData *exclusiveGetter = nil;
        exclusiveGetter = [[PDLNonThreadSafeClusterObserverLogData alloc] init];
        exclusiveGetter.clusterClass = [PDLNonThreadSafeArrayObserverObject class];
        exclusiveGetter.isExclusive = YES;

        static PDLNonThreadSafeClusterObserverLogData *setter = nil;
        setter = [[PDLNonThreadSafeClusterObserverLogData alloc] init];
        setter.clusterClass = [PDLNonThreadSafeArrayObserverObject class];
        setter.isSetter = YES;

        __unused BOOL ret = YES;

        // getters
        Class arrayClass = [NSArray class];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(count) withInterceptorImplementation:(IMP)&logA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(objectAtIndex:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(arrayByAddingObject:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(arrayByAddingObjectsFromArray:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(componentsJoinedByString:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(containsObject:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(description) withInterceptorImplementation:(IMP)&logA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(descriptionWithLocale:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(descriptionWithLocale:indent:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(firstObjectCommonWithArray:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(getObjects:range:) withInterceptorImplementation:(IMP)&logA1R1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexOfObject:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexOfObject:inRange:) withInterceptorImplementation:(IMP)&logA1R1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexOfObjectIdenticalTo:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexOfObjectIdenticalTo:inRange:) withInterceptorImplementation:(IMP)&logA1R1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(isEqualToArray:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(firstObject) withInterceptorImplementation:(IMP)&logA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(lastObject) withInterceptorImplementation:(IMP)&logA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(objectEnumerator) withInterceptorImplementation:(IMP)&logA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(reverseObjectEnumerator) withInterceptorImplementation:(IMP)&logA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(sortedArrayHint) withInterceptorImplementation:(IMP)&logA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(sortedArrayUsingFunction:context:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(sortedArrayUsingFunction:context:hint:) withInterceptorImplementation:(IMP)&logA3 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(sortedArrayUsingSelector:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(subarrayWithRange:) withInterceptorImplementation:(IMP)&logR1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(writeToURL:error:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(makeObjectsPerformSelector:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)exclusiveGetter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(makeObjectsPerformSelector:withObject:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)exclusiveGetter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(objectsAtIndexes:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(objectAtIndexedSubscript:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(enumerateObjectsUsingBlock:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)exclusiveGetter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(enumerateObjectsWithOptions:usingBlock:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)exclusiveGetter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(enumerateObjectsAtIndexes:options:usingBlock:) withInterceptorImplementation:(IMP)&logA3 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)exclusiveGetter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(enumerateObjectsAtIndexes:options:usingBlock:) withInterceptorImplementation:(IMP)&logA3 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)exclusiveGetter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexOfObjectPassingTest:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexOfObjectWithOptions:passingTest:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexOfObjectAtIndexes:options:passingTest:) withInterceptorImplementation:(IMP)&logA3 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexesOfObjectsPassingTest:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexesOfObjectsWithOptions:passingTest:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexesOfObjectsAtIndexes:options:passingTest:) withInterceptorImplementation:(IMP)&logA3 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(sortedArrayUsingComparator:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(sortedArrayWithOptions:usingComparator:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexOfObject:inSortedRange:options:usingComparator:) withInterceptorImplementation:(IMP)&logA1R1A2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(differenceFromArray:withOptions:usingEquivalenceTest:) withInterceptorImplementation:(IMP)&logA3 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)exclusiveGetter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(differenceFromArray:withOptions:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)exclusiveGetter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(differenceFromArray:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)exclusiveGetter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(arrayByApplyingDifference:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(getObjects:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(writeToFile:atomically:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(writeToURL:atomically:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(valueForKey:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(setValue:forKey:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)getter];

        // setters
        Class mutableArrayClass = [NSMutableArray class];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(addObject:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(insertObject:atIndex:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeLastObject) withInterceptorImplementation:(IMP)&logA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObjectAtIndex:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(replaceObjectAtIndex:withObject:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(addObjectsFromArray:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(exchangeObjectAtIndex:withObjectAtIndex:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeAllObjects) withInterceptorImplementation:(IMP)&logA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObject:inRange:) withInterceptorImplementation:(IMP)&logA1R1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObject:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObjectIdenticalTo:inRange:) withInterceptorImplementation:(IMP)&logA1R1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObjectIdenticalTo:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObjectsFromIndices:numIndices:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObjectsInArray:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObjectsInRange:) withInterceptorImplementation:(IMP)&logR1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(replaceObjectsInRange:withObjectsFromArray:range:) withInterceptorImplementation:(IMP)&logR1A1R1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(replaceObjectsInRange:withObjectsFromArray:) withInterceptorImplementation:(IMP)&logR1A1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(setArray:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(sortUsingFunction:context:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(sortUsingSelector:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(insertObjects:atIndexes:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObjectsAtIndexes:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(replaceObjectsAtIndexes:withObjects:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(setObject:atIndexedSubscript:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(sortUsingComparator:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(sortWithOptions:usingComparator:) withInterceptorImplementation:(IMP)&logA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(applyDifference:) withInterceptorImplementation:(IMP)&logA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)setter];

        // creations
        NSUInteger m1 = [arrayClass pdl_interceptClusterSelector:@selector(mutableCopy) withInterceptorImplementation:(IMP)&registerA0 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)self];
        NSUInteger m2 = [arrayClass pdl_interceptClusterSelector:@selector(mutableCopyWithZone:) withInterceptorImplementation:(IMP)&registerA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)self];
        ret = ret && (m1 || m2);

        Class placeholderClass = NSClassFromString(@"__NSPlaceholderArray");
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithCapacity:) withInterceptorImplementation:(IMP)&registerA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)self];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithContentsOfFile:) withInterceptorImplementation:(IMP)&registerA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)self];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithContentsOfURL:) withInterceptorImplementation:(IMP)&registerA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)self];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithObjects:count:) withInterceptorImplementation:(IMP)&registerA2 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)self];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithArray:) withInterceptorImplementation:(IMP)&registerA1 isStructRet:@(NO) addIfNotExistent:NO data:(__bridge void *)self];
        assert(ret);
    });
}

@end
