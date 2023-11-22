//
//  PDLLockItem.m
//  Poodle
//
//  Created by Poodle on 10/10/23.
//  Copyright © 2023 Poodle. All rights reserved.
//

#import "PDLLockItem.h"
#import "pdl_dispatch.h"

@interface PDLLockItem () {
    NSMutableArray <PDLLockItemAction *>*_actions;
    NSString *_suspiciousReason;
    NSString *_identifier;
}

@end

@implementation PDLLockItem

static NSMutableSet *PDLLockItemLockItems = nil;
static NSMutableSet *PDLLockItemSuspiciousDeadLockItems = nil;

- (instancetype)init {
    self = [super init];
    if (self) {
        _actions = [NSMutableArray array];

        @synchronized (PDLLockItemLockItems) {
            [PDLLockItemLockItems addObject:self];
        }
    }
    return self;
}

- (NSArray<PDLLockItemAction *> *)actions {
    @synchronized (_actions) {
        return [_actions copy];
    }
}

- (NSString *)identifier {
    if (_identifier) {
        return _identifier;
    }

    PDLLockItemAction *action = self.actions.firstObject;
    if (!action) {
        return nil;
    }

    __block NSString *firstSymbol = nil;
    [action.backtrace enumerateFrames:^(NSInteger index, void *address, NSString *symbol, NSString *image, BOOL *stops) {
        if (symbol) {
            firstSymbol = symbol;
        } else {
            firstSymbol = [NSString stringWithFormat:@"%p", address];
        }
        *stops = YES;
    }];

    _identifier = firstSymbol;
    return _identifier;
}

- (void)addAction:(PDLLockItemAction *)action {
    @synchronized (_actions) {
        [_actions addObject:action];
    }
}

- (void)action:(PDLLockItemAction *)action addChild:(PDLLockItemAction *)child {
    [action addChild:child];
}

- (PDLLockItemAction *)lock {
    PDLLockItemAction *action = [[PDLLockItemAction alloc] init];
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

- (void)check {
    if (_isSuspicious) {
        return;
    }

    NSArray *actions = nil;
    @synchronized (self.actions) {
        actions = [self.actions copy];
    }
    for (NSInteger i = 0; i < actions.count; i++) {
        PDLLockItemAction *action = actions[i];
        NSArray *children = action.children;
        for (NSInteger j = 0; j < children.count; j++) {
            PDLLockItemAction *child = children[j];
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
                        [PDLLockItem addSuspicious:self];
                        return;
                    }
                }
            }
        }
    }
}

+ (void)initialize {
    if (self == [PDLLockItem self]) {
        PDLLockItemSuspiciousDeadLockItems = [NSMutableSet set];
        PDLLockItemLockItems = [NSMutableSet set];
    }
}

+ (void)addSuspicious:(PDLLockItem *)item {
    @synchronized (PDLLockItemSuspiciousDeadLockItems) {
        [PDLLockItemSuspiciousDeadLockItems addObject:item];
    }
}

+ (NSArray *)suspiciousDeadLockItems {
    @synchronized (PDLLockItemSuspiciousDeadLockItems) {
        return PDLLockItemSuspiciousDeadLockItems.allObjects;
    }
}

+ (NSArray *)lockItems {
    @synchronized (PDLLockItemLockItems) {
        return [PDLLockItemLockItems allObjects];
    }
}

@end
