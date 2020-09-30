//
//  PDLTask.h
//  Poodle
//
//  Created by Poodle on 2020/9/29.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PDLTaskState) {
    PDLTaskStateNone,
    PDLTaskStateWaiting,
    PDLTaskStateRunning,
    PDLTaskStateSucceeded,
    PDLTaskStateFailed,
    PDLTaskStateCanceled,
    PDLTaskStateTimedOut,
};

@class PDLTaskManager;

@interface PDLTask : NSObject

@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, assign, readonly) PDLTaskState state;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, copy) void (^action)(PDLTask *task);
@property (nonatomic, copy) void (^completion)(PDLTask *task, BOOL finished);
@property (nonatomic, weak, readonly) PDLTaskManager *manager;

@end

NS_ASSUME_NONNULL_END
