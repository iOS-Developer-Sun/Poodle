//
//  NSMutableDictionary+PDLThreadSafety.m
//  Poodle
//
//  Created by Poodle on 2020/7/15.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "NSMutableDictionary+PDLThreadSafety.h"
#import "NSObject+PDLImplementationInterceptor.h"

@implementation NSMutableDictionary (PDLThreadSafety)

#pragma mark - getters

static id dictionaryIdToId(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, __unsafe_unretained id object) {
    PDLImplementationInterceptorRecover(_cmd);
    @synchronized (self) {
        struct objc_super su = {self, class_getSuperclass(_class)};
        id(*msgSend)(struct objc_super *, SEL, id) = (id(*)(struct objc_super *, SEL, id))objc_msgSendSuper;
        id ret = msgSend(&su, _cmd, object);
        return ret;
    }
}

static NSUInteger dictionaryToUnsignedInteger(__unsafe_unretained NSMutableDictionary *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    @synchronized (self) {
        struct objc_super su = {self, class_getSuperclass(_class)};
        NSUInteger(*msgSend)(struct objc_super *, SEL) = (NSUInteger(*)(struct objc_super *, SEL))objc_msgSendSuper;
        NSUInteger ret = msgSend(&su, _cmd);
        return ret;
    }
}

static id dictionaryToId(__unsafe_unretained NSMutableDictionary *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    @synchronized (self) {
        struct objc_super su = {self, class_getSuperclass(_class)};
        id(*msgSend)(struct objc_super *, SEL) = (id(*)(struct objc_super *, SEL))objc_msgSendSuper;
        id ret = msgSend(&su, _cmd);
        return ret;
    }
}

static BOOL dictionaryIdToBool(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, __unsafe_unretained id object) {
    PDLImplementationInterceptorRecover(_cmd);
    @synchronized (self) {
        struct objc_super su = {self, class_getSuperclass(_class)};
        BOOL(*msgSend)(struct objc_super *, SEL, id) = (BOOL(*)(struct objc_super *, SEL, id))objc_msgSendSuper;
        BOOL ret = msgSend(&su, _cmd, object);
        return ret;
    }
}

static id dictionaryIdIdToId(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, __unsafe_unretained id object, __unsafe_unretained id object2) {
    PDLImplementationInterceptorRecover(_cmd);
    @synchronized (self) {
        struct objc_super su = {self, class_getSuperclass(_class)};
        id(*msgSend)(struct objc_super *, SEL, id, id) = (id(*)(struct objc_super *, SEL, id, id))objc_msgSendSuper;
        id ret = msgSend(&su, _cmd, object, object2);
        return ret;
    }
}

static id dictionaryPointerToId(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, void *pointer) {
    PDLImplementationInterceptorRecover(_cmd);
    @synchronized (self) {
        struct objc_super su = {self, class_getSuperclass(_class)};
        id(*msgSend)(struct objc_super *, SEL, void *) = (id(*)(struct objc_super *, SEL, void *))objc_msgSendSuper;
        id ret = msgSend(&su, _cmd, pointer);
        return ret;
    }
}

static NSUInteger dictionaryPointerPointerUnsignedIntegerToUnsignedInteger(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, void *pointer, void *pointer2, NSUInteger unsignedInteger) {
    PDLImplementationInterceptorRecover(_cmd);
    @synchronized (self) {
        struct objc_super su = {self, class_getSuperclass(_class)};
        NSUInteger(*msgSend)(struct objc_super *, SEL, void *, void *, NSUInteger) = (NSUInteger(*)(struct objc_super *, SEL, void *, void *, NSUInteger))objc_msgSendSuper;
        NSUInteger ret = msgSend(&su, _cmd, pointer, pointer2, unsignedInteger);
        return ret;
    }
}

#pragma mark - setters

static void dictionaryIdIdToVoid(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, __unsafe_unretained id object, __unsafe_unretained id object2) {
    PDLImplementationInterceptorRecover(_cmd);
    @synchronized (self) {
        struct objc_super su = {self, class_getSuperclass(_class)};
        void(*msgSend)(struct objc_super *, SEL, id, id) = (void(*)(struct objc_super *, SEL, id, id))objc_msgSendSuper;
        msgSend(&su, _cmd, object, object2);
    }
}

static void dictionaryIdToVoid(__unsafe_unretained NSMutableDictionary *self, SEL _cmd, __unsafe_unretained id object) {
    PDLImplementationInterceptorRecover(_cmd);
    @synchronized (self) {
        struct objc_super su = {self, class_getSuperclass(_class)};
        void(*msgSend)(struct objc_super *, SEL, id) = (void(*)(struct objc_super *, SEL, id))objc_msgSendSuper;
        msgSend(&su, _cmd, object);
    }
}

static void dictionaryToVoid(__unsafe_unretained NSMutableDictionary *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    @synchronized (self) {
        struct objc_super su = {self, class_getSuperclass(_class)};
        void(*msgSend)(struct objc_super *, SEL) = (void(*)(struct objc_super *, SEL))objc_msgSendSuper;
        msgSend(&su, _cmd);
    }
}

static Class dictionaryClass(Class dictionaryClass) {
    const char *subclassName = [NSString stringWithFormat:@"PDLThreadSafety_%s", object_getClassName(dictionaryClass)].UTF8String;
    Class subclass = objc_allocateClassPair(dictionaryClass, subclassName, sizeof(id));
    if (!subclass) {
        return nil;
    }

    BOOL ret = YES;

    // getters
    ret = ret && pdl_interceptSelector(subclass, @selector(objectForKey:), (IMP)&dictionaryIdToId, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(objectForKeyedSubscript:), (IMP)&dictionaryIdToId, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(count), (IMP)&dictionaryToUnsignedInteger, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(keyEnumerator), (IMP)&dictionaryToId, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(allKeys), (IMP)&dictionaryToId, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(allKeys), (IMP)&dictionaryToId, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(allKeysForObject:), (IMP)&dictionaryIdToId, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(isEqualToDictionary:), (IMP)&dictionaryIdToBool, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(objectEnumerator), (IMP)&dictionaryToId, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(objectsForKeys:notFoundMarker:), (IMP)&dictionaryIdIdToId, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(copy), (IMP)&dictionaryToId, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(mutableCopy), (IMP)&dictionaryToId, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(copyWithZone:), (IMP)&dictionaryPointerToId, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(mutableCopyWithZone:), (IMP)&dictionaryPointerToId, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(countByEnumeratingWithState:objects:count:), (IMP)&dictionaryPointerPointerUnsignedIntegerToUnsignedInteger, @(NO), YES, NULL);

    // setters
    ret = ret && pdl_interceptSelector(subclass, @selector(setObject:forKey:), (IMP)&dictionaryIdIdToVoid, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(setObject:forKeyedSubscript:), (IMP)&dictionaryIdIdToVoid, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(removeObjectForKey:), (IMP)&dictionaryIdToVoid, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(removeObjectsForKeys:), (IMP)&dictionaryIdToVoid, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(addEntriesFromDictionary:), (IMP)&dictionaryIdToVoid, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(setDictionary:), (IMP)&dictionaryIdToVoid, @(NO), YES, NULL);
    ret = ret && pdl_interceptSelector(subclass, @selector(removeAllObjects), (IMP)&dictionaryToVoid, @(NO), YES, NULL);

    if (!ret) {
        return nil;
    }

    objc_registerClassPair(subclass);
    return subclass;
}

- (BOOL)pdl_threadSafetify {
    @synchronized (self) {
        static void *key = &key;
        NSNumber *enabled = objc_getAssociatedObject(self, key);
        if (enabled.boolValue) {
            return YES;
        }

        Class aClass = object_getClass(self);
        Class subclass = dictionaryClass(aClass);
        if (!subclass) {
            return NO;
        }

        object_setClass(self, subclass);
        objc_setAssociatedObject(self, key, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return YES;
    }
}

@end
