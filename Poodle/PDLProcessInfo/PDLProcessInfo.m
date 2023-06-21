//
//  PDLProcessInfo.m
//  Poodle
//
//  Created by Poodle on 2021/2/1.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLProcessInfo.h"
#import <sys/sysctl.h>
#import <sys/types.h>
#import <QuartzCore/QuartzCore.h>

@implementation PDLProcessInfo

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        pid_t pid = [[NSProcessInfo processInfo] processIdentifier];
        int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, pid };
        struct kinfo_proc proc;
        size_t size = sizeof(proc);
        int ret = sysctl(mib, 4, &proc, &size, NULL, 0);
        NSDate *now = [NSDate date];
        NSTimeInterval current = CACurrentMediaTime();
        NSTimeInterval processStartMediaTime = 0;
        NSDate *processStartDate = nil;
        if (ret == 0) {
            NSTimeInterval timeInterval = proc.kp_proc.p_starttime.tv_sec + proc.kp_proc.p_starttime.tv_usec * 1e-6;
            processStartDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            NSTimeInterval diff = [now timeIntervalSinceDate:processStartDate];
            processStartMediaTime = current - diff;
        } else {
            processStartDate = now;
            processStartMediaTime = current;
        }
        _processStartDate = processStartDate;
        _processStartMediaTime = processStartMediaTime;
    }
    return self;
}

@end
