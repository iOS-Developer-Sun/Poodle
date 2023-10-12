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
}

@end

@implementation PDLLockItem

static NSMutableSet *_suspiciousDeadLockItems = nil;

+ (void)initialize {
    if (self == [PDLLockItem self]) {
        _suspiciousDeadLockItems = [NSMutableSet set];
    }
}

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
    pdl_spinlock_lock(&_spinlock);
    BOOL isSuspicious = self.isSuspicious;
    [self.actions addObject:action];
    if (!isSuspicious && self.isSuspicious) {
        self.keyAction = action;
        [_suspiciousDeadLockItems addObject:self];
    }
    pdl_spinlock_unlock(&_spinlock);
}

- (PDLLockItemAction *)lock {
    PDLLockItemAction *action = [[PDLLockItemAction alloc] init];
    action.item = self;
    action.type = PDLLockItemActionTypeLock;
    [self addAction:action];
    return action;
}

- (PDLLockItemAction *)wait:(dispatch_queue_t)queue {
    NSString *queueIdentifier = @(pdl_dispatch_get_queue_unique_identifier(queue)).stringValue;
    NSString *queueLabel = @(queue ? (dispatch_queue_get_label(queue) ?: "") : "");

    PDLLockItemAction *action = [[PDLLockItemAction alloc] init];
    action.item = self;
    action.type = PDLLockItemActionTypeWait;
    action.targetQueueLabel = queueLabel;
    action.targetQueueIdentifier = queueIdentifier;
    [self addAction:action];
    return action;
}

- (BOOL)findActionWaitingFor:(PDLLockItemAction *)target {
    NSString *targetQueueIdentifier = target.targetQueueIdentifier;
    for (PDLLockItemAction *action in self.actions) {
        if (action == target) {
            continue;
        }

        if ([targetQueueIdentifier isEqualToString:action.queueIdentifier]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)actionsContainsItem:(PDLLockItem *)item {
    for (PDLLockItemAction *action in self.actions) {
        if (action.item == item) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isSuspicious {
    for (PDLLockItemAction *action in self.actions) {
        NSString *targetQueueIdentifier = action.targetQueueIdentifier;
        if (action.item == self && targetQueueIdentifier.length != 0) {
            if ([self findActionWaitingFor:action]) {
                return YES;
            }
        }

        if (action.item != self) {
            if ([action.item actionsContainsItem:self]) {
                return YES;
            }
        }
    }
    return NO;
}

+ (NSArray *)suspiciousDeadLockItems {
    return _suspiciousDeadLockItems.allObjects;
}

@end
