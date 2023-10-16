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
        [self.actions addObject:action];
    }
}

- (void)action:(PDLLockItemAction *)action addChild:(PDLLockItemAction *)child {
    @synchronized ([PDLLockItem class]) {
        [action.children addObject:child];
        child.parent = action;
    }
}

- (PDLLockItemAction *)lock {
    PDLLockItemAction *action = [[PDLLockItemAction alloc] init];
    [action.backtrace record:3];
    action.item = self;
    action.type = PDLLockItemActionTypeLock;
    [self addAction:action];
    return action;
}

- (PDLLockItemAction *)waitAction:(PDLLockItemAction *)waitAction {
    if (waitAction.type != PDLLockItemActionTypeWait) {
        return nil;
    }

    NSString *targetQueueIdentifier = waitAction.targetQueueIdentifier;
    for (PDLLockItemAction *action in self.actions) {
        if (action.type != PDLLockItemActionTypeLock) {
            continue;
        }

        if ([targetQueueIdentifier isEqualToString:action.queueIdentifier]) {
            return action;
        }
    }

    for (PDLLockItemAction *action in waitAction.children) {
        PDLLockItemAction *sub = [self waitAction:action];
        if (sub) {
            return sub;
        }
    }

    return nil;
}

- (PDLLockItemAction *)childContainsItem:(PDLLockItem *)item notInQueueThread:(NSString *)queueThreadId exceptions:(NSMutableSet *)exceptions {
    for (PDLLockItemAction *action in self.actions) {
        for (PDLLockItemAction *child in action.children) {
            if (child.type != PDLLockItemActionTypeLock) {
                continue;
            }

            if (child.item == item && ![child.queueThreadId isEqualToString:queueThreadId]) {
                return child;
            }

            if (child.item != self && ![exceptions containsObject:self]) {
                [exceptions addObject:self];
                PDLLockItemAction *suspicious = [child.item childContainsItem:item notInQueueThread:queueThreadId exceptions:exceptions];
                [exceptions removeObject:self];
                if (suspicious) {
                    return suspicious;
                }
            }
        }
    }
    return nil;
}

- (void)check:(PDLLockItemAction *)checkedAction {
    @synchronized ([PDLLockItem class]) {
        if (_isSuspicious) {
            return;
        }

        for (PDLLockItemAction *action in self.actions) {
            for (PDLLockItemAction *child in action.children) {
                if (child.item != self) {
                    if (child.type == PDLLockItemActionTypeLock) {
                        NSMutableArray *decendants = [[child decendants] mutableCopy];
                        [decendants addObject:child];
                        for (PDLLockItemAction *decendant in decendants) {
                            NSMutableSet *exceptions = [NSMutableSet set];
                            [exceptions addObject:self];
                            PDLLockItemAction *lockAction = [decendant.item childContainsItem:self notInQueueThread:action.queueThreadId exceptions:exceptions];
                            if (lockAction) {
                                _isSuspicious = YES;
                                _suspiciousReason = [NSString stringWithFormat:@"<%@ %p> conflicts with <%@ %p>", decendant.class, decendant, lockAction.class, lockAction];
                                _suspiciousActions = @[decendant, lockAction];
                                _keyAction = checkedAction;
                                [PDLLockItem addSuspicious:self];
                                return;
                            }
                        }
                    } else if (child.type == PDLLockItemActionTypeWait) {
                        PDLLockItemAction *waitAction = [self waitAction:child];
                        if (waitAction) {
                            _isSuspicious = YES;
                            NSString *targetQueueString = child.targetQueueIdentifier ? [NSString stringWithFormat:@"[q%@(%@)]", child.targetQueueIdentifier, child.targetQueueLabel] : @"";
                            _suspiciousReason = [NSString stringWithFormat:@"<%@ %p> is waiting for %@ while <%@ %p> locks it.", child.class, child, targetQueueString, waitAction.class, waitAction];
                            _suspiciousActions = @[child, waitAction];
                            _keyAction = checkedAction;
                            [PDLLockItem addSuspicious:self];
                            return;
                        }
                    }
                }
            }
        }
    }
}

static NSMutableSet *_suspiciousDeadLockItems = nil;

+ (void)initialize {
    if (self == [PDLLockItem self]) {
        _suspiciousDeadLockItems = [NSMutableSet set];
    }
}

+ (void)addSuspicious:(PDLLockItem *)item {
    @synchronized (_suspiciousDeadLockItems) {
        [_suspiciousDeadLockItems addObject:item];
    }
}

+ (NSArray *)suspiciousDeadLockItems {
    @synchronized (_suspiciousDeadLockItems) {
        return _suspiciousDeadLockItems.allObjects;
    }
}

@end
