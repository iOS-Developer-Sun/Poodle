//
//  PDLNonThreadSafeArrayObserver.m
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeArrayObserver.h"
#import "PDLNonThreadSafeArrayObserverObject.h"
#import "NSObject+PDLImplementationInterceptor.h"
#import "PDLNonThreadSafeObserver.h"

@implementation PDLNonThreadSafeArrayObserver

static void logBegin(__unsafe_unretained id self, Class aClass, SEL sel, void *flags) {
    if ([PDLNonThreadSafeObserver ignoredForObject:self]) {
        return;
    }

    PDLNonThreadSafeArrayObserverObject *observer = [PDLNonThreadSafeArrayObserverObject observerObjectForObject:self];
    if (!observer) {
        return;
    }

    BOOL isExclusive = ((unsigned long)flags) & 0b10;
    if (!isExclusive) {
        BOOL ready = [observer startRecording];
        if (!ready) {
            return;
        }
    }

    BOOL isSetter = ((unsigned long)flags) & 0b1;
    [observer recordClass:aClass selectorString:NSStringFromSelector(sel) isSetter:isSetter];
//    NSLog(@"%@ %@ %@", aClass, NSStringFromSelector(sel), @(isSetter));
}

static void logEnd(__unsafe_unretained id self, Class aClass, SEL sel, void *flags) {
    if ([PDLNonThreadSafeObserver ignoredForObject:self]) {
        return;
    }

    PDLNonThreadSafeArrayObserverObject *observer = [PDLNonThreadSafeArrayObserverObject observerObjectForObject:self];
    if (!observer) {
        return;
    }

    [observer finishRecording];
}

static void arrayRegister(__unsafe_unretained id array) {
    if ([array isKindOfClass:[NSMutableArray class]]) {
        [PDLNonThreadSafeArrayObserverObject registerObject:array];
    }
}

#pragma mark - imp

#define DECL_IMP(FUNC_NAME) \
static void *FUNC_NAME(__unsafe_unretained id self, SEL _cmd) {\
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
static void *FUNC_NAME(__unsafe_unretained id self, SEL _cmd, TYPE1 a1) {\
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
static void *FUNC_NAME(__unsafe_unretained id self, SEL _cmd, TYPE1 a1, TYPE2 a2) {\
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
static void *FUNC_NAME(__unsafe_unretained id self, SEL _cmd, TYPE1 a1, TYPE2 a2, TYPE3 a3) {\
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
static void *FUNC_NAME(__unsafe_unretained id self, SEL _cmd, TYPE1 a1, TYPE2 a2, TYPE3 a3, TYPE4 a4) {\
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
    id array = ((typeof(&mutableCopy))_imp)(self, _cmd);
    arrayRegister(array);
    return array;
}

static id mutableCopyWithZone(__unsafe_unretained id *self, SEL _cmd, struct _NSZone *zone) {
    PDLImplementationInterceptorRecover(_cmd);
    id array = ((typeof(&mutableCopyWithZone))_imp)(self, _cmd, zone);
    arrayRegister(array);
    return array;
}

static id initWithCapacity(__unsafe_unretained id *self, SEL _cmd, NSUInteger capacity) {
    PDLImplementationInterceptorRecover(_cmd);
    id array = ((typeof(&initWithCapacity))_imp)(self, _cmd, capacity);
    arrayRegister(array);
    return array;
}

static id initWithObjectsCount(__unsafe_unretained id *self, SEL _cmd, void *objects, void *keys, NSUInteger count) {
    PDLImplementationInterceptorRecover(_cmd);
    id array = ((typeof(&initWithObjectsCount))_imp)(self, _cmd, objects, keys, count);
    arrayRegister(array);
    return array;
}

static BOOL (^_filter)(PDLBacktrace *backtrace, NSString **name) = nil;
+ (BOOL (^)(PDLBacktrace *backtrace, NSString **name))filter {
    return _filter;
}

+ (void)enableWithFilter:(BOOL(^)(PDLBacktrace *backtrace, NSString **name))filter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _filter = filter;
        void *exclusiveFlag = (void *)0b10UL;
        void *setterFlag = (void *)0b01UL;

        __unused BOOL ret = YES;

        // getters
        Class arrayClass = [NSArray class];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(count) withInterceptorImplementation:(IMP)&impA0];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(objectAtIndex:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(arrayByAddingObject:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(arrayByAddingObjectsFromArray:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(componentsJoinedByString:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(containsObject:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(description) withInterceptorImplementation:(IMP)&impA0];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(descriptionWithLocale:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(descriptionWithLocale:indent:) withInterceptorImplementation:(IMP)&impA2];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(firstObjectCommonWithArray:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(getObjects:range:) withInterceptorImplementation:(IMP)&impA1R1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexOfObject:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexOfObject:inRange:) withInterceptorImplementation:(IMP)&impA1R1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexOfObjectIdenticalTo:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexOfObjectIdenticalTo:inRange:) withInterceptorImplementation:(IMP)&impA1R1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(isEqualToArray:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(firstObject) withInterceptorImplementation:(IMP)&impA0];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(lastObject) withInterceptorImplementation:(IMP)&impA0];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(objectEnumerator) withInterceptorImplementation:(IMP)&impA0];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(reverseObjectEnumerator) withInterceptorImplementation:(IMP)&impA0];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(sortedArrayHint) withInterceptorImplementation:(IMP)&impA0];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(sortedArrayUsingFunction:context:) withInterceptorImplementation:(IMP)&impA2];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(sortedArrayUsingFunction:context:hint:) withInterceptorImplementation:(IMP)&impA3];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(sortedArrayUsingSelector:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(subarrayWithRange:) withInterceptorImplementation:(IMP)&impR1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(writeToURL:error:) withInterceptorImplementation:(IMP)&impA2];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(makeObjectsPerformSelector:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:exclusiveFlag];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(makeObjectsPerformSelector:withObject:) withInterceptorImplementation:(IMP)&impA2 isStructRet:@(NO) addIfNotExistent:NO data:exclusiveFlag];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(objectsAtIndexes:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(objectAtIndexedSubscript:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(enumerateObjectsUsingBlock:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:exclusiveFlag];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(enumerateObjectsWithOptions:usingBlock:) withInterceptorImplementation:(IMP)&impA2 isStructRet:@(NO) addIfNotExistent:NO data:exclusiveFlag];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(enumerateObjectsAtIndexes:options:usingBlock:) withInterceptorImplementation:(IMP)&impA3 isStructRet:@(NO) addIfNotExistent:NO data:exclusiveFlag];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(enumerateObjectsAtIndexes:options:usingBlock:) withInterceptorImplementation:(IMP)&impA3 isStructRet:@(NO) addIfNotExistent:NO data:exclusiveFlag];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexOfObjectPassingTest:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexOfObjectWithOptions:passingTest:) withInterceptorImplementation:(IMP)&impA2];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexOfObjectAtIndexes:options:passingTest:) withInterceptorImplementation:(IMP)&impA3];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexesOfObjectsPassingTest:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexesOfObjectsWithOptions:passingTest:) withInterceptorImplementation:(IMP)&impA2];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexesOfObjectsAtIndexes:options:passingTest:) withInterceptorImplementation:(IMP)&impA3];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(sortedArrayUsingComparator:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(sortedArrayWithOptions:usingComparator:) withInterceptorImplementation:(IMP)&impA2];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(indexOfObject:inSortedRange:options:usingComparator:) withInterceptorImplementation:(IMP)&impA1R1A2];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(differenceFromArray:withOptions:usingEquivalenceTest:) withInterceptorImplementation:(IMP)&impA3 isStructRet:@(NO) addIfNotExistent:NO data:exclusiveFlag];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(differenceFromArray:withOptions:) withInterceptorImplementation:(IMP)&impA2 isStructRet:@(NO) addIfNotExistent:NO data:exclusiveFlag];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(differenceFromArray:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:exclusiveFlag];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(arrayByApplyingDifference:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(getObjects:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(writeToFile:atomically:) withInterceptorImplementation:(IMP)&impA2];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(writeToURL:atomically:) withInterceptorImplementation:(IMP)&impA2];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(valueForKey:) withInterceptorImplementation:(IMP)&impA1];
        ret = ret && [arrayClass pdl_interceptClusterSelector:@selector(setValue:forKey:) withInterceptorImplementation:(IMP)&impA2];

        // setters
        Class mutableArrayClass = [NSMutableArray class];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(addObject:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(insertObject:atIndex:) withInterceptorImplementation:(IMP)&impA2 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeLastObject) withInterceptorImplementation:(IMP)&impA0 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObjectAtIndex:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(replaceObjectAtIndex:withObject:) withInterceptorImplementation:(IMP)&impA2 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(addObjectsFromArray:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(exchangeObjectAtIndex:withObjectAtIndex:) withInterceptorImplementation:(IMP)&impA2 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeAllObjects) withInterceptorImplementation:(IMP)&impA0 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObject:inRange:) withInterceptorImplementation:(IMP)&impA1R1 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObject:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObjectIdenticalTo:inRange:) withInterceptorImplementation:(IMP)&impA1R1 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObjectIdenticalTo:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObjectsFromIndices:numIndices:) withInterceptorImplementation:(IMP)&impA2 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObjectsInArray:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObjectsInRange:) withInterceptorImplementation:(IMP)&impR1 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(replaceObjectsInRange:withObjectsFromArray:range:) withInterceptorImplementation:(IMP)&impR1A1R1 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(replaceObjectsInRange:withObjectsFromArray:) withInterceptorImplementation:(IMP)&impR1A1 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(setArray:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(sortUsingFunction:context:) withInterceptorImplementation:(IMP)&impA2 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(sortUsingSelector:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(insertObjects:atIndexes:) withInterceptorImplementation:(IMP)&impA2 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(removeObjectsAtIndexes:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(replaceObjectsAtIndexes:withObjects:) withInterceptorImplementation:(IMP)&impA2 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(setObject:atIndexedSubscript:) withInterceptorImplementation:(IMP)&impA2 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(sortUsingComparator:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(sortWithOptions:usingComparator:) withInterceptorImplementation:(IMP)&impA2 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];
        ret = ret && [mutableArrayClass pdl_interceptClusterSelector:@selector(applyDifference:) withInterceptorImplementation:(IMP)&impA1 isStructRet:@(NO) addIfNotExistent:NO data:setterFlag];

        // creations
        NSUInteger m1 = [arrayClass pdl_interceptClusterSelector:@selector(mutableCopy) withInterceptorImplementation:(IMP)&mutableCopy];
        NSUInteger m2 = [arrayClass pdl_interceptClusterSelector:@selector(mutableCopyWithZone:) withInterceptorImplementation:(IMP)&mutableCopyWithZone];
        ret = ret && (m1 || m2);

        Class placeholderClass = NSClassFromString(@"__NSPlaceholderArray");
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithCapacity:) withInterceptorImplementation:(IMP)&initWithCapacity];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithContentsOfFile:) withInterceptorImplementation:(IMP)&initWithCapacity];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithContentsOfURL:) withInterceptorImplementation:(IMP)&initWithCapacity];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithObjects:count:) withInterceptorImplementation:(IMP)&initWithObjectsCount];
        ret = ret && [placeholderClass pdl_interceptSelector:@selector(initWithArray:) withInterceptorImplementation:(IMP)&initWithCapacity];
        assert(ret);
    });
}

@end
