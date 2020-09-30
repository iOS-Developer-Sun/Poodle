//
//  PDLTask.m
//  Poodle
//
//  Created by Poodle on 2020/9/29.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLTask.h"
#import "PDLTaskInternal.h"
#import "PDLTaskManager.h"

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
        @(PDLTaskStateSucceeded) : @"succeeded",
        @(PDLTaskStateFailed) : @"failed",
        @(PDLTaskStateCanceled) : @"canceled",
        @(PDLTaskStateTimedOut) : @"timed out",
    };
    return states[@(self.state)] ?: @"unknown";
}

- (void)setDelay:(NSTimeInterval)delay {
    if (fabs(_delay - delay) <= DBL_EPSILON) {
        return;
    }

    _delay = delay;
    if (self.state != PDLTaskStateWaiting) {
        return;
    }

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(run) object:nil];
    if (delay > 0) {
        [self performSelector:@selector(run) withObject:nil afterDelay:delay];
    } else {
        [self run];
    }
}

- (void)start {
    PDLTaskState state = self.state;
    if (state != PDLTaskStateNone) {
        return;
    }

    self.state = PDLTaskStateWaiting;
    NSTimeInterval delay = self.delay;
    if (delay > 0) {
        [self performSelector:@selector(run) withObject:nil afterDelay:delay];
    } else {
        [self run];
    }
}

- (void)run {
    PDLTaskState state = self.state;
    if (state != PDLTaskStateWaiting) {
        return;
    }

    self.state = PDLTaskStateRunning;
    if (self.action) {
        self.action(self);
    }

    NSTimeInterval timeoutInterval = self.timeoutInterval;
    if (timeoutInterval > 0) {
        [self performSelector:@selector(timeout) withObject:nil afterDelay:timeoutInterval];
    }
}

- (void)complete {
    if (self.completion) {
        self.completion(self, self.state == PDLTaskStateSucceeded);
    }
}

- (void)timeout {
    PDLTaskState state = self.state;
    if (state != PDLTaskStateRunning) {
        return;
    }

    self.state = PDLTaskStateTimedOut;
    [self complete];
}

- (void)succeed {
    PDLTaskState state = self.state;
    if (state != PDLTaskStateWaiting && state != PDLTaskStateRunning) {
        return;
    }

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
    self.state = PDLTaskStateSucceeded;
    [self complete];
}

- (void)fail {
    PDLTaskState state = self.state;
    if (state != PDLTaskStateWaiting && state != PDLTaskStateRunning) {
        return;
    }

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
    self.state = PDLTaskStateFailed;
    [self complete];
}

- (void)cancel {
    PDLTaskState state = self.state;
    if (state != PDLTaskStateWaiting && state != PDLTaskStateRunning) {
        return;
    }

    self.state = PDLTaskStateCanceled;
    if (state == PDLTaskStateWaiting) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(run) object:nil];
    } else if (state == PDLTaskStateRunning) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
    } else {
        assert(0);
    }
    [self complete];
}

@end
