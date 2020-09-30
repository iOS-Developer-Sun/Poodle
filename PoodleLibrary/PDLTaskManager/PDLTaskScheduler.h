//
//  PDLTaskScheduler.h
//  Poodle
//
//  Created by Poodle on 2020/9/30.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLTaskManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLTaskScheduler : NSObject

@property (nonatomic, copy) void(^scheduler)(PDLTaskScheduler *scheduler);

- (void)schedule;

@end

NS_ASSUME_NONNULL_END
