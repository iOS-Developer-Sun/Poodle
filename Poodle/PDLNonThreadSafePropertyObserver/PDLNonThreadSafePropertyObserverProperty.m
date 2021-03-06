//
//  PDLNonThreadSafePropertyObserverProperty.m
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafePropertyObserverProperty.h"
#import <mach/mach.h>
#import <objc/runtime.h>
#import "PDLNonThreadSafePropertyObserverObject.h"
#import "PDLNonThreadSafePropertyObserver.h"
#import "PDLNonThreadSafePropertyObserverChecker.h"
#import "pdl_dispatch.h"
#import "PDLProcessInfo.h"

@interface PDLNonThreadSafePropertyObserverChecker (PDLNonThreadSafePropertyObserverProperty)

- (instancetype)initWithObserverProperty:(PDLNonThreadSafePropertyObserverProperty *)property;

@end

@interface PDLNonThreadSafePropertyObserverProperty () {
    __weak PDLNonThreadSafePropertyObserverObject *_observer;
    NSMutableArray <PDLNonThreadSafePropertyObserverAction *> *_actions;
    PDLNonThreadSafePropertyObserverChecker *_checker;
}

@end

@implementation PDLNonThreadSafePropertyObserverProperty

- (instancetype)initWithObserver:(PDLNonThreadSafePropertyObserverObject *)observer identifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        _observer = observer;
        _identifier = [identifier copy];

        _actions = [NSMutableArray array];
        _checker = [[[PDLNonThreadSafePropertyObserver checkerClass] alloc] initWithObserverProperty:self];
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

- (void)recordIsSetter:(BOOL)isSetter isInitializing:(BOOL)isInitializing {
    mach_port_t thread = mach_thread_self();

    NSString *queueIdentifier = nil;
    NSString *queueLabel = nil;
    BOOL isSerialQueue = NO;
    if ([PDLNonThreadSafePropertyObserver queueCheckerEnabled]) {
        dispatch_queue_t queue = pdl_dispatch_get_current_queue();
        if (queue) {
            queueIdentifier = @(pdl_dispatch_get_queue_unique_identifier(queue)).stringValue;
            isSerialQueue = pdl_dispatch_get_queue_width(queue) == 1;
        }
        queueLabel = [self queueLabel:queue];
    }

    PDLNonThreadSafePropertyObserverAction *action = [[PDLNonThreadSafePropertyObserverAction alloc] init];
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
            void(^reporter)(PDLNonThreadSafePropertyObserverProperty *property) = [PDLNonThreadSafePropertyObserver reporter];
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

- (NSString *)description {
    NSString *description = [super description];
    PDLNonThreadSafePropertyObserverObject *observer = _observer;
    return [NSString stringWithFormat:@"%@, observer: %p\n%@\n%@", description, observer, self.identifier, self.actions];
}

@end
