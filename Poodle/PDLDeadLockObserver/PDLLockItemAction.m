//
//  PDLLockItemAction.m
//  Poodle
//
//  Created by Poodle on 10/10/23.
//  Copyright © 2023 Poodle. All rights reserved.
//

#import "PDLLockItemAction.h"
#import <mach/mach.h>
#import "pdl_dispatch.h"

@implementation PDLLockItemAction

- (instancetype)init {
    self = [super init];
    if (self) {
        mach_port_t thread = mach_thread_self();
        dispatch_queue_t queue = pdl_dispatch_get_current_queue();

        _thread = thread;
        _queueIdentifier = @(pdl_dispatch_get_queue_unique_identifier(queue)).stringValue;
        _queueLabel = @(queue ? (dispatch_queue_get_label(queue) ?: "") : "");
        _time = [[NSDate date] timeIntervalSinceDate:self.class.processStartDate];
        PDLBacktrace *bt = [[PDLBacktrace alloc] init];
        _backtrace = bt;
    }
    return self;
}

- (NSString *)description {
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
    NSString *queueString = self.queueIdentifier ? [NSString stringWithFormat:@"[q%@(%@)]", self.queueIdentifier, self.queueLabel] : @"";
    NSString *targetQueueString = self.targetQueueIdentifier ? [NSString stringWithFormat:@"[q%@(%@)]", self.targetQueueIdentifier, self.targetQueueLabel] : @"";
    NSString *timeString = [NSString stringWithFormat:@"[%.3f]", self.time];

    NSString *actionString = [NSString stringWithFormat:@"<%@>%@%@%@%@%@<%p>", self.item, typeString, threadString, queueString, targetQueueString, timeString, self];
    return actionString;
}

static NSDate *_processStartDate = nil;
+ (NSDate *)processStartDate {
    return _processStartDate;
}

+ (void)setProcessStartDate:(NSDate *)processStartDate {
    _processStartDate = processStartDate;
}

@end
