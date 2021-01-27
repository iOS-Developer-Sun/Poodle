//
//  PDLReuseItemManager.h
//  Poodle
//
//  Created by Poodle on 2021/1/27.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLReuseItemManager : NSObject

- (NSString *)reuseIdentifierForItem:(id)item;
- (void)setReuseIdentifier:(NSString *_Nullable)identifier forItem:(id)item;
- (void)enqueue:(id)item;
- (id)dequeueReusableItemWithIdentifier:(NSString *)identifier;
- (NSDictionary <NSString *, NSMutableArray *>*)dequeueAllReusableItems;

@end

NS_ASSUME_NONNULL_END
