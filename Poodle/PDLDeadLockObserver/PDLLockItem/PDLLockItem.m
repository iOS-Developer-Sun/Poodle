//
//  PDLLockItem.m
//  Poodle
//
//  Created by Poodle on 10/10/23.
//  Copyright © 2023 Poodle. All rights reserved.
//

#import "PDLLockItem.h"
#import "pdl_dispatch.h"
#import "pdl_spinlock.h"

@interface PDLLockItem () {
    pdl_spinlock _spinlock;
    BOOL _isSuspicious;
    NSString *_suspiciousReason;
}

@end

@implementation PDLLockItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _actions = [NSMutableArray array];
        pdl_spinlock spinlock = PDL_SPINLOCK_INIT;
        _spinlock = spinlock;
    }
    return self;
}

- (void)addAction:(PDLLockItemAction *)action {
    @synchronized ([PDLLockItem class]) {
        BOOL isSuspicious = self.isSuspicious;
        [self.actions addObject:action];
        if (!isSuspicious && self.isSuspicious) {
            _keyAction = action;
            [PDLLockItem addSuspicious:self];
        }
    }
}

- (PDLLockItemAction *)lock {
    PDLLockItemAction *action = [[PDLLockItemAction alloc] init];
    [action.backtrace record:4];
    action.item = self;
    action.type = PDLLockItemActionTypeLock;
    [self addAction:action];
    return action;
}

- (PDLLockItemAction *)syncWait:(dispatch_queue_t)queue {
    NSString *queueIdentifier = @(pdl_dispatch_get_queue_unique_identifier(queue)).stringValue;
    NSString *queueLabel = @(queue ? (dispatch_queue_get_label(queue) ?: "") : "");

    PDLLockItemAction *action = [[PDLLockItemAction alloc] init];
    action.item = self;
    [action.backtrace record:3];
    action.type = PDLLockItemActionTypeWait;
    action.targetQueueLabel = queueLabel;
    action.targetQueueIdentifier = queueIdentifier;
    [self addAction:action];
    return action;
}

- (PDLLockItemAction *)findActionWaitingFor:(PDLLockItemAction *)target {
    NSString *targetQueueIdentifier = target.targetQueueIdentifier;
    for (PDLLockItemAction *action in self.actions) {
        if (action == target) {
            continue;
        }

        if ([targetQueueIdentifier isEqualToString:action.queueIdentifier]) {
            return action;
        }
    }
    return nil;
}

- (PDLLockItemAction *)actionsContainsItem:(PDLLockItem *)item {
    for (PDLLockItemAction *action in self.actions) {
        if (action.type != PDLLockItemActionTypeLock) {
            continue;
        }

        if (action.item == item) {
            return action;
        }
    }
    return nil;
}

- (BOOL)isSuspicious {
    if (_isSuspicious) {
        return YES;
    }

    for (PDLLockItemAction *action in self.actions) {
        NSString *targetQueueIdentifier = action.targetQueueIdentifier;
        if (action.item == self && targetQueueIdentifier.length != 0) {
            PDLLockItemAction *lockAction = [self findActionWaitingFor:action];
            if (lockAction) {
                _isSuspicious = YES;
                _suspiciousReason = [NSString stringWithFormat:@"<Action %p> is waiting for [%@] while <Action %p> locks it.", action, targetQueueIdentifier, lockAction];
                return YES;
            }
        }

        if (action.item != self) {
            PDLLockItemAction *lockAction = [action.item actionsContainsItem:self];
            if (lockAction) {
                _isSuspicious = YES;
                _suspiciousReason = [NSString stringWithFormat:@"<Action %p> conflicts with <Action %p>", action, lockAction];
                return YES;
            }
        }
    }
    return NO;
}

static NSMutableSet *_suspiciousDeadLockItems = nil;

+ (void)initialize {
    if (self == [PDLLockItem self]) {
        _suspiciousDeadLockItems = [NSMutableSet set];
    }
}

+ (void)addSuspicious:(PDLLockItem *)item {
    [_suspiciousDeadLockItems addObject:item];
}

+ (NSArray *)suspiciousDeadLockItems {
    return _suspiciousDeadLockItems.allObjects;
}

@end
