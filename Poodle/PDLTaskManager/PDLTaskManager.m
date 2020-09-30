//
//  PDLTaskManager.m
//  Poodle
//
//  Created by Poodle on 2020/9/29.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLTaskManager.h"

@interface PDLTask ()

@property (nonatomic, weak) PDLTaskManager *manager;

- (void)start;
- (void)finish;
- (void)cancel;

@end

@interface PDLTaskManager ()

@property (nonatomic, strong) NSMutableArray *taskList;
@property (nonatomic, strong) NSMutableSet *allTasks;
@property (nonatomic, assign) PDLTaskManagerState state;
@property (nonatomic, strong) PDLTaskManager *runningManager;

@end

@implementation PDLTaskManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _taskList = [NSMutableArray array];
        _allTasks = [NSMutableSet set];
    }
    return self;
}

- (NSArray *)tasks {
    return [self.taskList copy];
}

- (void)addTask:(PDLTask *)task {
    if (![self.allTasks containsObject:task]) {
        assert(task.manager != self);
        task.manager = self;
        [self.taskList addObject:task];
        [self.allTasks addObject:task];
    }
}

- (void)removeTask:(PDLTask *)task {
    if ([self.allTasks containsObject:task]) {
        assert(task.manager == self);
        task.manager = nil;
        [self.taskList removeObject:task];
        [self.allTasks removeObject:task];
    }
}

- (void)start {
    PDLTaskManagerState state = self.state;
    if (state != PDLTaskManagerStateNone) {
        return;
    }

    self.runningManager = self;
    [self run];
}

- (void)run {
    PDLTaskManagerState state = self.state;
    if (state != PDLTaskManagerStateNone) {
        return;
    }

    self.state = PDLTaskManagerStateRunning;
    for (PDLTask *task in self.taskList) {
        [task start];
    }

    NSTimeInterval timeoutInterval = self.timeoutInterval;
    if (timeoutInterval > 0) {
        [self performSelector:@selector(timeout) withObject:nil afterDelay:timeoutInterval];
    }
}

- (void)complete {
    [self cancelAllTasks];
    if (self.completion) {
        self.completion(self, self.state == PDLTaskManagerStateFinished);
    }
    self.runningManager = nil;
}

- (void)timeout {
    PDLTaskManagerState state = self.state;
    if (state != PDLTaskManagerStateRunning) {
        return;
    }

    self.state = PDLTaskManagerStateTimedOut;
    [self complete];
}

- (void)finish {
    PDLTaskManagerState state = self.state;
    if (state == PDLTaskManagerStateCanceled || state == PDLTaskManagerStateTimedOut) {
        return;
    }

    self.state = PDLTaskManagerStateFinished;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
    [self complete];
}

- (void)cancel {
    PDLTaskManagerState state = self.state;
    if (state == PDLTaskManagerStateCanceled || state != PDLTaskManagerStateTimedOut) {
        return;
    }

    self.state = PDLTaskManagerStateCanceled;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
    [self complete];
}

- (void)finishTask:(PDLTask *)task {
    assert(task.manager == self);
    [task finish];
}

- (void)cancelTask:(PDLTask *)task {
    assert(task.manager == self);
    [task cancel];
}

- (void)cancelLatterTasks:(PDLTask *)task {
    assert(task.manager == self);
    NSInteger index = [self.taskList indexOfObject:task];
    for (NSInteger i = index + 1; i < self.taskList.count; i++) {
        PDLTask *each = self.taskList[i];
        [each cancel];
    }
}

- (void)cancelLowerTasks:(PDLTask *)task {
    assert(task.manager == self);
    NSInteger priority = task.priority;
    for (PDLTask *each in self.taskList) {
        if (each.priority < priority) {
            [each cancel];
        }
    }
}

- (void)cancelAllTasks {
    for (PDLTask *task in self.taskList) {
        [task cancel];
    }
}

@end
