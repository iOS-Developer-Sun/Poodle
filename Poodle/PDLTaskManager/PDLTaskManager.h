//
//  PDLTaskManager.h
//  Poodle
//
//  Created by Poodle on 2020/9/29.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLTask.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PDLTaskManagerState) {
    PDLTaskManagerStateNone,
    PDLTaskManagerStateRunning,
    PDLTaskManagerStateFinished,
    PDLTaskManagerStateCanceled,
    PDLTaskManagerStateTimedOut,
};

@interface PDLTaskManager : NSObject

@property (nonatomic, copy, readonly) NSArray *tasks;
@property (nonatomic, assign, readonly) PDLTaskManagerState state;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, copy) void (^completion)(PDLTaskManager *taskManager, BOOL finished);

- (void)addTask:(PDLTask *)task;
- (void)removeTask:(PDLTask *)task;

- (void)start;
- (void)finish;
- (void)cancel;

- (void)startTask:(PDLTask *)task;
- (void)finishTask:(PDLTask *)task;
- (void)cancelTask:(PDLTask *)task;
- (void)cancelLatterTasks:(PDLTask *)task;
- (void)cancelLowerTasks:(PDLTask *)task;
- (void)cancelAllTasks;

@end

NS_ASSUME_NONNULL_END

