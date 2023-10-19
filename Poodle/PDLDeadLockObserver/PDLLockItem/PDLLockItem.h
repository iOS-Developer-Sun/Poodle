//
//  PDLLockItem.h
//  Poodle
//
//  Created by Poodle on 10/10/23.
//  Copyright © 2023 Poodle. All rights reserved.
//

#import "PDLLockItemAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLLockItem : NSObject

@property (nonatomic, copy, readonly) NSArray <PDLLockItemAction *>*actions;
@property (nonatomic, copy, readonly) NSArray *suspiciousActions;
@property (nonatomic, copy, readonly) NSString *suspiciousReason;
@property (nonatomic, assign, readonly) BOOL isSuspicious;
@property (nonatomic, copy, readonly) NSString *identifier;

- (PDLLockItemAction *)lock;
- (void)addAction:(PDLLockItemAction *)action;
- (void)action:(PDLLockItemAction *)action addChild:(PDLLockItemAction *)child;
- (void)check;

+ (NSArray *)suspiciousDeadLockItems;
+ (NSArray *)lockItems;

@end

NS_ASSUME_NONNULL_END
