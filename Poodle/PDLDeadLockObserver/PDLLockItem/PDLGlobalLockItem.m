//
//  PDLGlobalLockItem.m
//  Poodle
//
//  Created by Poodle on 10/10/23.
//  Copyright © 2023 Poodle. All rights reserved.
//

#import "PDLGlobalLockItem.h"
#import <objc/runtime.h>

@implementation PDLGlobalLockItem

static NSMapTable *_map = nil;
+ (void)initialize {
    if (self == [PDLGlobalLockItem self]) {
        _map = [NSMapTable strongToStrongObjectsMapTable];
    }
}

+ (NSMapTable *)map {
    return _map;
}

+ (instancetype)lockItemWithObject:(NSUInteger)object {
    PDLGlobalLockItem *lockItem = [_map objectForKey:@(object)];
    if (!lockItem) {
        lockItem = [[PDLGlobalLockItem alloc] init];
        lockItem.object = object;
        [_map setObject:lockItem forKey:@(object)];
    }
    return lockItem;
}

@end
