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

@property (nonatomic, strong) NSMutableArray <PDLLockItemAction *>*actions;
@property (nonatomic, strong, readonly) PDLLockItemAction *keyAction;
@property (nonatomic, copy, readonly) NSString *suspiciousReason;

- (PDLLockItemAction *)lock;
- (PDLLockItemAction *)syncWait:(dispatch_queue_t)queue;
- (void)addAction:(PDLLockItemAction *)action;

- (BOOL)isSuspicious;

+ (NSArray *)suspiciousDeadLockItems;

@end

NS_ASSUME_NONNULL_END
