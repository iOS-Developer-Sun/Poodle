//
//  PDLTaskScheduler.m
//  Poodle
//
//  Created by Poodle on 2020/9/30.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLTaskScheduler.h"
#import "PDLTaskSchedulerInternal.h"

@implementation PDLTaskScheduler

- (void)schedule {
    if (self.scheduler) {
        self.scheduler(self);
    }
}

@end
