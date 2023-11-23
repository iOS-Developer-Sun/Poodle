//
//  PDLLockItemAction.m
//  Poodle
//
//  Created by Poodle on 10/10/23.
//  Copyright © 2023 Poodle. All rights reserved.
//

#import "PDLLockItemAction.h"
#import <mach/mach.h>
#import "PDLDeadLockObserver.h"
#import "PDLLockItem.h"
#import "pdl_dispatch.h"
#import "PDLProcessInfo.h"

@interface PDLLockItemAction () {
    NSMutableArray <PDLLockItemAction *>*_children;
}

@end

@implementation PDLLockItemAction

- (instancetype)init {
    self = [super init];
    if (self) {
        _children = [NSMutableArray array];
        mach_port_t thread = mach_thread_self();
        _thread = thread;

        dispatch_queue_t queue = pdl_dispatch_get_current_queue();
        _queueIdentifier = @"";
        _queueLabel = @"";
        if (queue) {
            _isSerialQueue = pdl_dispatch_get_queue_width(queue) == 1;
            NSUInteger qid = pdl_dispatch_get_queue_unique_identifier(queue);
            _queueIdentifier = @(qid).stringValue;
            _queueLabel = @((dispatch_queue_get_label(queue) ?: ""));
        }

        _time = [[NSDate date] timeIntervalSinceDate:[PDLProcessInfo sharedInstance].processStartDate];
        PDLBacktrace *bt = [[PDLBacktrace alloc] init];
        _backtrace = bt;
    }
    return self;
}

- (NSString *)queueThreadId {
    return (self.queueIdentifier.length > 0) ? [NSString stringWithFormat:@"q%@", self.queueIdentifier] : [NSString stringWithFormat:@"t%@", @(self.thread).stringValue];
}

- (NSString *)description {
    NSString *description = [super description];
    NSString *typeString = @"";
    switch (self.subtype) {
        case PDLLockItemActionSubtypeNSLock:
            typeString = @"NSLock";
            break;
        case PDLLockItemActionSubtypeNSRecursiveLock:
            typeString = @"NSRecursiveLock";
            break;
        case PDLLockItemActionSubtypePthreadMutex:
            typeString = @"PthreadMutex";
            break;
        case PDLLockItemActionSubtypePthreadRWLock:
            typeString = @"PthreadRWLock";
            break;
        case PDLLockItemActionSubtypeSynchronized:
            typeString = @"Synchronized";
            break;
        case PDLLockItemActionSubtypeDispatchOnce:
            typeString = @"DispatchOnce";
            break;
        default: {
            switch (self.type) {
                case PDLLockItemActionTypeLock:
                    typeString = @"LOCK";
                    break;
                case PDLLockItemActionTypeWait:
                    typeString = @"WAIT";
                    break;
                default:
                    break;
            }
        } break;
    }
    NSString *threadString = [NSString stringWithFormat:@"[t%@]", @(self.thread)];
    NSString *queueString = self.queueIdentifier.length > 0 ? [NSString stringWithFormat:@"[q%@(%@)]", self.queueIdentifier, self.queueLabel] : @"";
    NSString *targetQueueString = self.targetQueueIdentifier.length > 0 ? [NSString stringWithFormat:@"[q%@(%@)]", self.targetQueueIdentifier, self.targetQueueLabel] : @"";
    NSString *timeString = [NSString stringWithFormat:@"[%.3f]", self.time];
    NSString *parentString = self.parent ? [NSString stringWithFormat:@"<parent: %p>", self.parent] : @"";
    NSMutableString *childrenString = [NSMutableString string];
    NSArray *children = self.children;
    if (children.count > 0) {
        [childrenString appendFormat:@"<children: %@", @(children.count)];
        for (PDLLockItemAction *child in children) {
            [childrenString appendFormat:@", %p", child];
        }
        [childrenString appendFormat:@">"];
    }

    NSString *actionString = [NSString stringWithFormat:@"<%@>%@%@%@%@%@<%@ %p>%@%@", description, typeString, threadString, queueString, targetQueueString, timeString, self.item.class, self.item, parentString, childrenString];

    return actionString;
}

- (NSArray<PDLLockItemAction *> *)children {
    if (![PDLDeadLockObserver enabled]) {
        return _children;
    }

    @synchronized (_children) {
        return [_children copy];
    }
}

- (void)addChild:(PDLLockItemAction *)child {
    @synchronized (_children) {
        [_children addObject:child];
        child.parent = self;
    }
}

- (NSArray *)decendants {
    NSMutableArray *array = [NSMutableArray array];
    NSArray *children = self.children;
    [array addObjectsFromArray:children];
    for (PDLLockItemAction *child in children) {
        [array addObjectsFromArray:[child decendants]];
    }
    return array;
}

- (BOOL)showBacktrace:(NSString *)name {
    if (self.backtrace.isShown) {
        return NO;
    }

    self.backtrace.name = name;
    [PDLDeadLockObserver enterObserving];
    [self.backtrace showWithBlock:^(void (^start)(void)) {
        [PDLDeadLockObserver enterObserving];
        start();
        [PDLDeadLockObserver leaveObserving];
    }];
    [PDLDeadLockObserver leaveObserving];
    return self.backtrace.isShown;
}

- (void)hideBacktrace {
    [self.backtrace hide];
}

@end
