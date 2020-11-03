//
//  PDLRunLoopObserverLoop.m
//  Poodle
//
//  Created by Poodle on 2020/11/3.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLRunLoopObserverLoop.h"
#import <QuartzCore/QuartzCore.h>
#import "PDLRunLoopObserver.h"

@implementation PDLRunLoopObserverLoopActivity

- (NSString *)description {
    NSString *description = [super description];
    return [description stringByAppendingFormat:@" %.3fms %@", self.time * 1000, [PDLRunLoopObserver activityString:self.activity]];
}

@end

@interface PDLRunLoopObserverLoop () {
    NSMutableArray *_activities;
    NSMutableArray *_intervals;
}

@end

@implementation PDLRunLoopObserverLoop

- (instancetype)init {
    self = [super init];
    if (self) {
        _activities = [NSMutableArray array];
        _intervals = [NSMutableArray array];
    }
    return self;
}

- (NSString *)description {
    NSString *description = [super description];
    return description;
}

- (PDLRunLoopObserverLoopActivity *)addActivity:(CFRunLoopActivity)activity {
    PDLRunLoopObserverLoopActivity *previous = _activities.lastObject;

    PDLRunLoopObserverLoopActivity *loopActivity = [[PDLRunLoopObserverLoopActivity alloc] init];
    loopActivity.time = CACurrentMediaTime();
    loopActivity.activity = activity;
    [_activities addObject:loopActivity];

    if (previous) {
        PDLRunLoopObserverLoopActivity *interval = [[PDLRunLoopObserverLoopActivity alloc] init];
        interval.activity = previous.activity;
        interval.time = loopActivity.time - previous.time;
        [_intervals addObject:interval];
    }

    return loopActivity;
}

- (NSArray<PDLRunLoopObserverLoopActivity *> *)activities {
    return [_activities copy];
}

- (NSArray<PDLRunLoopObserverLoopActivity *> *)intervals {
    return [_intervals copy];
}

@end
