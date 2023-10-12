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

+ (instancetype)lockItemWithObject:(NSUInteger)object {
    @synchronized (_map) {
        PDLGlobalLockItem *lockItem = [_map objectForKey:@(object)];
        if (!lockItem) {
            lockItem = [[PDLGlobalLockItem alloc] init];
            lockItem.object = object;
            [_map setObject:lockItem forKey:@(object)];
        }
        return lockItem;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@, 0x%lx>", [super description], self.object];
}

@end
