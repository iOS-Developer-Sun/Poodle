//
//  PDLFirstObjectTaskScheduler.m
//  PoodleApplication
//
//  Created by Poodle on 2020/9/30.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLFirstObjectTaskScheduler.h"
#import "PDLTaskSchedulerInternal.h"

@implementation PDLFirstObjectTaskScheduler

- (instancetype)init{
    self = [super init];
    if (self) {
        self.scheduler = ^(PDLTaskScheduler * _Nonnull scheduler) {
            BOOL shouldFinish = YES;
            PDLTaskManager *taskManager = scheduler.taskManager;
            PDLTask *result = nil;
            for (PDLTask *task in taskManager.tasks) {
                PDLTaskState state = task.state;
                if (state == PDLTaskStateWaiting || state == PDLTaskStateRunning) {
                    shouldFinish = NO;
                    break;
                }
                if (state == PDLTaskStateSucceeded) {
                    result = task;
                    shouldFinish = YES;
                    break;
                }
            }
            if (shouldFinish) {
                typeof(self) firstObjectTaskScheduler = (typeof(firstObjectTaskScheduler))scheduler;
                firstObjectTaskScheduler.result = result;
                [taskManager finish];
                firstObjectTaskScheduler.result = nil;
            };
        };
    }
    return self;
}

@end
