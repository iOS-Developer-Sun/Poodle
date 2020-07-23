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

- (id)pdl_associatedObjectForKey:(const void *)key {
    return objc_getAssociatedObject(self, key);
}

- (void)pdl_setAssociatedObject:(id)object forKey:(const void *)key policy:(objc_AssociationPolicy)policy {
    objc_setAssociatedObject(self, key, object, policy);
}

#pragma mark - weak

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

- (id)pdl_nonatomicWeakAssociatedObjectForKey:(const void *)key {
    PDLWeakWrapper *wrapper = objc_getAssociatedObject(self, key);
    return wrapper.object;
}

- (void)pdl_setNonatomicWeakAssociatedObject:(id)object forKey:(const void *)key {
    PDLWeakWrapper *wrapper = objc_getAssociatedObject(self, key);
    if (!wrapper) {
        wrapper = [[PDLWeakWrapper alloc] init];
        objc_setAssociatedObject(self, key, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    wrapper.object = object;
}

- (id)pdl_weakAssociatedObjectForKey:(const void *)key {
    PDLWeakWrapper *wrapper = nil;
    @synchronized (weakWrapperLock(self)) {
        wrapper = objc_getAssociatedObject(self, key);
    }
    return wrapper.object;
}

- (void)pdl_setWeakAssociatedObject:(id)object forKey:(const void *)key {
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
