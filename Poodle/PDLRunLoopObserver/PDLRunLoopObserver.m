//
//  PDLRunLoopObserver.m
//  Poodle
//
//  Created by Poodle on 2020/10/29.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLRunLoopObserver.h"
#import <mach/mach_time.h>

@interface PDLRunLoopObserverLoop ()

- (PDLRunLoopObserverLoopActivity *)addActivity:(CFRunLoopActivity)activity;

@end


@interface PDLRunLoopObserver ()

@property (nonatomic, strong) NSRunLoop *runLoop;
@property (nonatomic, strong) PDLRunLoopObserverLoop *loop;
@property (nonatomic, weak) id observer;

@end

@implementation PDLRunLoopObserver

static void PDLRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    PDLRunLoopObserver *self = (__bridge PDLRunLoopObserver *)info;
    [self callBack:activity];
}

+ (NSString *)activityString:(CFRunLoopActivity)activity {
    NSMutableArray *activities = [NSMutableArray array];
    if (activity & kCFRunLoopEntry) {
        [activities addObject:@"entry"];
    }
    if (activity & kCFRunLoopBeforeTimers) {
        [activities addObject:@"before timers"];
    }
    if (activity & kCFRunLoopBeforeSources) {
        [activities addObject:@"before sources"];
    }
    if (activity & kCFRunLoopBeforeWaiting) {
        [activities addObject:@"before waiting"];
    }
    if (activity & kCFRunLoopAfterWaiting) {
        [activities addObject:@"after waiting"];
    }
    if (activity & kCFRunLoopExit) {
        [activities addObject:@"exit"];
    }
    NSString *activityString = [activities componentsJoinedByString:@", "];
    return activityString;
}

- (instancetype)initWithRunLoop:(NSRunLoop *)runLoop {
    self = [super init];
    if (self) {
        _runLoop = runLoop;
    }
    return self;
}

- (void)start {
    if (self.observer) {
        return;
    }

    CFRunLoopObserverContext context = {0, (__bridge void *)self, NULL, NULL};
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &PDLRunLoopObserverCallBack, &context);
    CFRunLoopRef runLoop = [self.runLoop getCFRunLoop];
    CFRunLoopAddObserver(runLoop, observer, kCFRunLoopCommonModes);
    self.observer = (__bridge id)(observer);
}

- (void)stop {
    if (!self.observer) {
        return;
    }

    CFRunLoopRef runLoop = [self.runLoop getCFRunLoop];
    CFRunLoopObserverRef observer = (__bridge CFRunLoopObserverRef)(self.observer);
    CFRunLoopRemoveObserver(runLoop, observer, kCFRunLoopCommonModes);
}

- (void)callBack:(CFRunLoopActivity)activity {
    if (self.logEnabled) {
        NSLog(@"%@: %@", self.class, [self.class activityString:activity]);
    }

    if (activity == kCFRunLoopAfterWaiting) {
        PDLRunLoopObserverLoop *loop = [[PDLRunLoopObserverLoop alloc] init];
        PDLRunLoopObserverLoopActivity *loopActivity = [loop addActivity:activity];
        loop.begin = loopActivity.time;
        self.loop = loop;
    } else if (activity == kCFRunLoopBeforeWaiting) {
        PDLRunLoopObserverLoop *loop = self.loop;
        PDLRunLoopObserverLoopActivity *loopActivity = [loop addActivity:activity];
        loop.end = loopActivity.time;
        [self.delegate runLoopObserver:self didFinishLoop:loop];
        self.loop = nil;
    } else {
        [self.loop addActivity:activity];
    }
}

@end
