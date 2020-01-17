//
//  PDLNonThreadSafePropertyObserverProperty.m
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafePropertyObserverProperty.h"
#import "PDLNonThreadSafePropertyObserverObject.h"
#import "PDLNonThreadSafePropertyObserver.h"
#import "PDLNonThreadSafePropertyObserverChecker.h"
#import <mach/mach.h>
#import <objc/runtime.h>

@interface PDLNonThreadSafePropertyObserverChecker (PDLNonThreadSafePropertyObserverProperty)

- (instancetype)initWithObserverProperty:(PDLNonThreadSafePropertyObserverProperty *)property;
- (void)recordAction:(PDLNonThreadSafePropertyObserverAction *)action;
- (BOOL)check;

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
        _identifier = identifier.copy;

        _actions = [NSMutableArray array];
        _checker = [[PDLNonThreadSafePropertyObserverChecker alloc] initWithObserverProperty:self];
        assert(_checker);
    }
    return self;
}

- (NSString *)queueIdentifier:(dispatch_queue_t)queue {
    if (!queue) {
        return nil;
    }

    static void *PDLNonThreadSafePropertyObserverObjectQueueIdentifierKey = NULL;
    NSString *queueIdentifier = objc_getAssociatedObject(queue, &PDLNonThreadSafePropertyObserverObjectQueueIdentifierKey);
    if (queueIdentifier == nil) {
        static unsigned long _queueIdentifier = 0;
        _queueIdentifier++;
        queueIdentifier = [NSString stringWithFormat:@"%@q%@", ([self isQueueSerial:queue] ? @"s" : @"c"), @(_queueIdentifier)];
        objc_setAssociatedObject(queue, &PDLNonThreadSafePropertyObserverObjectQueueIdentifierKey, queueIdentifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return queueIdentifier;
}

- (NSString *)queueLabel:(dispatch_queue_t)queue {
    if (!queue) {
        return nil;
    }

    return @(dispatch_queue_get_label(queue));
}

- (BOOL)isQueueSerial:(dispatch_queue_t)queue {
    if (!queue) {
        return NO;
    }

    static void *PDLNonThreadSafePropertyObserverObjectIsQueueSerialKey = NULL;
    NSNumber *isQueueSerialNumber = objc_getAssociatedObject(queue, &PDLNonThreadSafePropertyObserverObjectIsQueueSerialKey);
    if (isQueueSerialNumber == nil) {
        NSString *debugDescription = [queue debugDescription];
        NSString *widthString = [debugDescription substringFromIndex:[debugDescription rangeOfString:@"width"].location];
        widthString = [widthString substringToIndex:[widthString rangeOfString:@","].location];
        widthString = [widthString substringFromIndex:[widthString rangeOfString:@"width = "].location + [widthString rangeOfString:@"width = "].length];
        isQueueSerialNumber = @([widthString isEqualToString:@"0x1"]);
        objc_setAssociatedObject(queue, &PDLNonThreadSafePropertyObserverObjectIsQueueSerialKey, isQueueSerialNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return isQueueSerialNumber.boolValue;
}

- (void)recordIsSetter:(BOOL)isSetter isInitializing:(BOOL)isInitializing {
    mach_port_t thread = mach_thread_self();

    NSString *queueIdentifier = nil;
    NSString *queueLabel = nil;
    BOOL isSerialQueue = NO;
    if ([PDLNonThreadSafePropertyObserver queueCheckerEnabled]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        dispatch_queue_t queue = dispatch_get_current_queue();
#pragma clang diagnostic pop
        queueIdentifier = [self queueIdentifier:queue];
        queueLabel = [self queueLabel:queue];
        isSerialQueue = [self isQueueSerial:queue];
    }

    PDLNonThreadSafePropertyObserverAction *action = [[PDLNonThreadSafePropertyObserverAction alloc] init];
    action.thread = thread;
    action.queueIdentifier = queueIdentifier;
    action.queueLabel = queueLabel;
    action.isSetter = isSetter;
    action.isInitializing = isInitializing;
    action.isSerialQueue = isSerialQueue;

    @synchronized (self) {
        [_actions addObject:action];
        [_checker recordAction:action];
        if (![_checker check]) {
            void(^reporter)(PDLNonThreadSafePropertyObserverProperty *property) = [PDLNonThreadSafePropertyObserver reporter];
            if (reporter) {
                reporter(self);
            }
        }
    }
}

- (NSArray *)actions {
    @synchronized (self) {
        return _actions.copy;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@\n%@", self.identifier, self.actions];
}

@end
