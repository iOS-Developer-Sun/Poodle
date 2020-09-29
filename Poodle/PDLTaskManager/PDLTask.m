//
//  PDLTask.m
//  Poodle
//
//  Created by Poodle on 2020/9/29.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLTask.h"
#import "PDLTaskManager.h"

@interface PDLTask ()

@property (nonatomic, assign) PDLTaskState state;
@property (nonatomic, weak) PDLTaskManager *manager;

@end

@implementation PDLTask

- (NSString *)description {
    NSString *description = [super description];
    return [NSString stringWithFormat:@"%@, %@", description, [self stateString]];
}

- (NSString *)stateString {
    NSDictionary *states = @{
        @(PDLTaskStateNone) : @"none",
        @(PDLTaskStateWaiting) : @"waiting",
        @(PDLTaskStateRunning) : @"running",
        @(PDLTaskStateFinished) : @"finished",
        @(PDLTaskStateCanceled) : @"canceled",
        @(PDLTaskStateTimedOut) : @"timed out",
    };
    return states[@(self.state)] ?: @"unknown";
}

- (void)start {
    PDLTaskState state = self.state;
    if (state == PDLTaskStateNone) {
        self.state = PDLTaskStateWaiting;
        NSTimeInterval delay = self.delay;
        if (delay > 0) {
            [self performSelector:@selector(run) withObject:nil afterDelay:delay];
        } else {
            [self run];
        }
    }
}

- (void)run {
    PDLTaskState state = self.state;
    if (state == PDLTaskStateWaiting) {
        self.state = PDLTaskStateRunning;
        if (self.action) {
            self.action(self);
        }
    }

    NSTimeInterval timeoutInterval = self.timeoutInterval;
    if (timeoutInterval > 0) {
        [self performSelector:@selector(timeout) withObject:nil afterDelay:timeoutInterval];
    }
}

- (void)timeout {
    PDLTaskState state = self.state;
    if (state == PDLTaskStateRunning) {
        self.state = PDLTaskStateTimedOut;
        if (self.completion) {
            self.completion(self, NO);
        }
    }
}

- (void)finish {
    PDLTaskState state = self.state;
    if (state != PDLTaskStateCanceled && state != PDLTaskStateTimedOut) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
        self.state = PDLTaskStateFinished;
        if (self.completion) {
            self.completion(self, YES);
        }
    }
}

- (void)cancel {
    PDLTaskState state = self.state;
    if (state == PDLTaskStateWaiting || state == PDLTaskStateRunning) {
        self.state = PDLTaskStateCanceled;
        if (state == PDLTaskStateWaiting) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(run) object:nil];
        } else if (state == PDLTaskStateRunning) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
        }
        if (self.completion) {
            self.completion(self, NO);
        }
    }
}

@end
