//
//  PDLObjectLockItem.m
//  Poodle
//
//  Created by Poodle on 10/10/23.
//  Copyright © 2023 Poodle. All rights reserved.
//

#import "PDLObjectLockItem.h"
#import <objc/runtime.h>

@implementation PDLObjectLockItem

+ (instancetype)lockItemWithObject:(id)object {
    static void *key = &key;
    PDLObjectLockItem *lockItem = objc_getAssociatedObject(object, key);
    if (!lockItem) {
        lockItem = [[self alloc] init];
        lockItem.object = object;
        objc_setAssociatedObject(object, key, lockItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return lockItem;
}

@end

