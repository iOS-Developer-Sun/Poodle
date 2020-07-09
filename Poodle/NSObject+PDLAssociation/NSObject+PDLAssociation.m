//
//  NSObject+PDLAssociation.m
//  Poodle
//
//  Created by Poodle on 2020/6/8.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "NSObject+PDLAssociation.h"

@interface PDLWeakWrapper : NSObject

@property (weak) id object;

@end

@implementation PDLWeakWrapper

@end

@implementation NSObject (PDLAssociation)

static void *nonatomicStrongKey = NULL;

- (id)pdl_nonatomicStrongAssociatedObject {
    return objc_getAssociatedObject(self, &nonatomicStrongKey);
}

- (void)pdl_setNonatomicStrongAssociatedObject:(__unsafe_unretained id)pdl_nonatomicStrongAssociatedObject {
    objc_setAssociatedObject(self, &nonatomicStrongKey, pdl_nonatomicStrongAssociatedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void *strongKey = NULL;

- (id)pdl_strongAssociatedObject {
    return objc_getAssociatedObject(self, &strongKey);
}

- (void)pdl_setStrongAssociatedObject:(__unsafe_unretained id)pdl_strongAssociatedObject {
    objc_setAssociatedObject(self, &strongKey, pdl_strongAssociatedObject, OBJC_ASSOCIATION_RETAIN);
}

static void *nonatomicCopyKey = NULL;

- (id)pdl_nonatomicCopyAssociatedObject {
    return objc_getAssociatedObject(self, &nonatomicCopyKey);
}

- (void)pdl_setNonatomicCopyAssociatedObject:(__unsafe_unretained id)pdl_nonatomicCopyAssociatedObject {
    objc_setAssociatedObject(self, &nonatomicCopyKey, pdl_nonatomicCopyAssociatedObject, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

static void *copyKey = NULL;

- (id)pdl_copyAssociatedObject {
    return objc_getAssociatedObject(self, &copyKey);
}

- (void)pdl_setCopyAssociatedObject:(__unsafe_unretained id)pdl_copyAssociatedObject {
    objc_setAssociatedObject(self, &copyKey, pdl_copyAssociatedObject, OBJC_ASSOCIATION_COPY);
}

static void *unsafeUnretainedKey = NULL;

- (id)pdl_unsafeUnretainedAssociatedObject {
    return objc_getAssociatedObject(self, &unsafeUnretainedKey);
}

- (void)pdl_setUnsafeUnretainedAssociatedObject:(__unsafe_unretained id)pdl_unsafeUnretainedAssociatedObject {
    objc_setAssociatedObject(self, &unsafeUnretainedKey, pdl_unsafeUnretainedAssociatedObject, OBJC_ASSOCIATION_ASSIGN);
}

- (id _Nullable)pdl_associatedObjectForKey:(void *)key {
    return objc_getAssociatedObject(self, key);
}

- (void)pdl_setAssociatedObject:(id _Nullable)object forKey:(void *)key policy:(objc_AssociationPolicy)policy {
    objc_setAssociatedObject(self, key, object, policy);
}

#pragma mark - weak

static void *nonatomicWeakKey = NULL;

- (id)pdl_nonatomicWeakAssociatedObject {
    return [self pdl_nonatomicWeakAssociatedObjectForKey:&nonatomicWeakKey];
}

- (void)pdl_setNonatomicWeakAssociatedObject:(__unsafe_unretained id)pdl_nonatomicWeakAssociatedObject {
    [self pdl_setNonatomicWeakAssociatedObject:pdl_nonatomicWeakAssociatedObject forKey:&nonatomicWeakKey];
}

static void *weakKey = NULL;

static id weakWrapperLock(__unsafe_unretained id object) {
    static void *weakWrapperLockKey = NULL;
    id lock = nil;
    @synchronized ([PDLWeakWrapper class]) {
        lock = objc_getAssociatedObject(object, &weakWrapperLockKey);
        if (!lock) {
            lock = [[NSObject alloc] init];
            objc_setAssociatedObject(object, &weakWrapperLockKey, lock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    return lock;
}

- (id)pdl_weakAssociatedObject {
    return [self pdl_weakAssociatedObjectForKey:&weakKey];
}

- (void)pdl_setWeakAssociatedObject:(__unsafe_unretained id)pdl_weakAssociatedObject {
    [self pdl_setWeakAssociatedObject:pdl_weakAssociatedObject forKey:&weakKey];
}

- (id)pdl_nonatomicWeakAssociatedObjectForKey:(void *)key {
    PDLWeakWrapper *wrapper = objc_getAssociatedObject(self, key);
    return wrapper.object;
}

- (void)pdl_setNonatomicWeakAssociatedObject:(id)object forKey:(void *)key {
    PDLWeakWrapper *wrapper = objc_getAssociatedObject(self, key);
    if (!wrapper) {
        wrapper = [[PDLWeakWrapper alloc] init];
        objc_setAssociatedObject(self, key, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    wrapper.object = object;
}

- (id)pdl_weakAssociatedObjectForKey:(void *)key {
    PDLWeakWrapper *wrapper = nil;
    @synchronized (weakWrapperLock(self)) {
        wrapper = objc_getAssociatedObject(self, key);
    }
    return wrapper.object;
}

- (void)pdl_setWeakAssociatedObject:(id)object forKey:(void *)key {
    PDLWeakWrapper *wrapper = nil;
    @synchronized (weakWrapperLock(self)) {
        wrapper = objc_getAssociatedObject(self, key);
        if (!wrapper) {
            wrapper = [[PDLWeakWrapper alloc] init];
            objc_setAssociatedObject(self, key, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    wrapper.object = object;
}

@end
