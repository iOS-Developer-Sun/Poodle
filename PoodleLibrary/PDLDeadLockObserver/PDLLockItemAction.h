//
//  PDLLockItemAction.h
//  Poodle
//
//  Created by Poodle on 10/10/23.
//  Copyright © 2023 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLBacktrace.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PDLLockItemActionType) {
    PDLLockItemActionTypeNone,
    PDLLockItemActionTypeLock,
    PDLLockItemActionTypeWait,
};

typedef NS_ENUM(NSInteger, PDLLockItemActionSubtype) {
    PDLLockItemActionSubtypeNone,
    PDLLockItemActionSubtypeNSLock,
    PDLLockItemActionSubtypeNSRecursiveLock,
    PDLLockItemActionSubtypePthreadMutex,
    PDLLockItemActionSubtypePthreadRWLock,
    PDLLockItemActionSubtypeSynchronized,
    PDLLockItemActionSubtypeDispatchOnce,
};

@class PDLLockItem;

@interface PDLLockItemAction : NSObject

@property (nonatomic, strong, class) NSDate *processStartDate;

@property (nonatomic, weak) PDLLockItem *item;

@property (nonatomic, assign) mach_port_t thread;
@property (nonatomic, copy) NSString *_Nullable queueIdentifier;
@property (nonatomic, copy) NSString *_Nullable queueLabel;
@property (nonatomic, assign) PDLLockItemActionType type;
@property (nonatomic, assign) PDLLockItemActionSubtype subtype;
@property (nonatomic, assign) NSTimeInterval time;

@property (nonatomic, copy) NSString *_Nullable targetQueueIdentifier;
@property (nonatomic, copy) NSString *_Nullable targetQueueLabel;
@property (nonatomic, strong, readonly) PDLBacktrace *backtrace;

@end

NS_ASSUME_NONNULL_END
