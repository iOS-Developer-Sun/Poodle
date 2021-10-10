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
    __weak PDLNonThreadSafeObserverObject *_observer;
    NSMutableArray <PDLNonThreadSafeObserverAction *> *_actions;
    PDLNonThreadSafeObserverChecker *_checker;
}

@end

@implementation PDLNonThreadSafeObserverCriticalResource

- (instancetype)initWithObserver:(PDLNonThreadSafeObserverObject *)observer identifier:(NSString * _Nullable)identifier {
    self = [super init];
    if (self) {
        _observer = observer;
        _identifier = [identifier copy];

        NSMutableArray *actions = [NSMutableArray array];
        [PDLNonThreadSafeObserver setIgnored:YES forObject:actions];
        _actions = actions;

        _checker = [[[PDLNonThreadSafeObserver checkerClass] alloc] initWithObserverCriticalResource:self];
        assert(_checker);
    }
    return self;
}

- (PDLNonThreadSafeObserverObject *)observer {
    return _observer;
}

- (NSString *)queueLabel:(dispatch_queue_t)queue {
    if (!queue) {
        return nil;
    }

    return @(dispatch_queue_get_label(queue) ?: "");
}

- (void)recordIsSetter:(BOOL)isSetter isInitializing:(BOOL)isInitializing {
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
    action.isInitializing = isInitializing;
    action.isSerialQueue = isSerialQueue;
    action.time = [[NSDate date] timeIntervalSinceDate:[PDLProcessInfo sharedInstance].processStartDate];

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
}

- (NSArray *)actions {
    @synchronized (self) {
        return [_actions copy];
    }
}

@end
