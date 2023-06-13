//
//  PDLNonThreadSafeObserverCriticalResource.m
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeObserverCriticalResource.h"
#import <mach/mach.h>
#import <objc/runtime.h>
#import "PDLNonThreadSafeObserver.h"
#import "PDLNonThreadSafeObserverChecker.h"
#import "pdl_dispatch.h"
#import "PDLProcessInfo.h"

@interface PDLNonThreadSafeObserverCriticalResource () {
    NSMutableArray <PDLNonThreadSafeObserverAction *> *_actions;
    PDLNonThreadSafeObserverChecker *_checker;
}

@end

@implementation PDLNonThreadSafeObserverCriticalResource

- (instancetype)init {
    self = [super init];
    if (self) {
        NSMutableArray *actions = [NSMutableArray array];
        [PDLNonThreadSafeObserver setIgnored:YES forObject:actions];
        _actions = actions;

        _checker = [[[PDLNonThreadSafeObserver checkerClass] alloc] initWithObserverCriticalResource:self];
        assert(_checker);
    }
    return self;
}

- (NSString *)queueLabel:(dispatch_queue_t)queue {
    if (!queue) {
        return nil;
    }

    return @(dispatch_queue_get_label(queue) ?: "");
}

- (PDLNonThreadSafeObserverAction *)record:(BOOL)isSetter {
    PDLNonThreadSafeObserverObject *observer = self.observer;
    assert(observer);

    mach_port_t thread = mach_thread_self();
    NSString *queueIdentifier = nil;
    NSString *queueLabel = nil;
    BOOL isSerialQueue = NO;
    if ([PDLNonThreadSafeObserver queueCheckerEnabled]) {
        dispatch_queue_t queue = pdl_dispatch_get_current_queue();
        if (queue) {
            queueIdentifier = @(pdl_dispatch_get_queue_unique_identifier(queue)).stringValue;
            isSerialQueue = pdl_dispatch_get_queue_width(queue) == 1;
        }
        queueLabel = [self queueLabel:queue];
    }

    PDLNonThreadSafeObserverAction *action = [[PDLNonThreadSafeObserverAction alloc] init];
    action.thread = thread;
    action.queueIdentifier = queueIdentifier;
    action.queueLabel = queueLabel;
    action.isSetter = isSetter;
    action.isInitializing = observer.checkInitializing;
    action.isSerialQueue = isSerialQueue;
    action.time = [[NSDate date] timeIntervalSinceDate:[PDLProcessInfo sharedInstance].processStartDate];
    if ([self.class recordsBacktrace]) {
        PDLBacktrace *backtrace = [[PDLBacktrace alloc] init];
        [backtrace record:5];
        action.backtrace = backtrace;
    }

    @synchronized (self) {
        [_actions addObject:action];
        [_checker recordAction:action];
        if (![_checker isThreadSafe]) {
            void(^reporter)(PDLNonThreadSafeObserverCriticalResource *resource) = [PDLNonThreadSafeObserver reporter];
            if (reporter) {
                reporter(self);
            }
        }
    }

    return action;
}

- (NSArray *)actions {
    @synchronized (self) {
        return [_actions copy];
    }
}

+ (BOOL)recordsBacktrace {
    return NO;
}

@end
