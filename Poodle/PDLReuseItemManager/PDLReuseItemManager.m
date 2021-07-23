//
//  PDLReuseItemManager.m
//  Poodle
//
//  Created by Poodle on 2021/1/27.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLReuseItemManager.h"
#import "NSMapTable+PDLExtension.h"

@interface PDLReuseItemManager ()

@property (nonatomic, strong) NSMapTable *reuseIdentifierMapTable;
@property (nonatomic, strong) NSMutableDictionary *items;

@end

@implementation PDLReuseItemManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _reuseIdentifierMapTable = [NSMapTable weakToStrongObjectsMapTable];
        _items = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)reuseIdentifierForItem:(id)item {
    NSString *reuseIdentifier = self.reuseIdentifierMapTable[item];
    return reuseIdentifier;
}

- (void)setReuseIdentifier:(NSString *)identifier forItem:(id)item {
    self.reuseIdentifierMapTable[item] = [identifier copy];
}

- (void)enqueue:(id)item {
    NSString *reuseIdentifier = [self reuseIdentifierForItem:item];
    if (reuseIdentifier == nil) {
        return;
    }

    NSMutableArray *items = self.items[reuseIdentifier];
    if (items == nil) {
        items = [NSMutableArray array];
        self.items[reuseIdentifier] = items;
    }
    [items addObject:item];
}

- (id)dequeueReusableItemWithIdentifier:(NSString *)identifier {
    if (identifier == nil) {
        return nil;
    }

    NSMutableArray *items = self.items[identifier];
    if (items == nil) {
        return nil;
    }

    id item = items.lastObject;
    [items removeLastObject];
    return item;
}

- (NSDictionary <NSString *, NSMutableArray *>*)dequeueAllReusableItems {
    NSDictionary *cacheItems = [self.items copy];
    [self.items removeAllObjects];
    return cacheItems;
}

@end
