//
//  PDLSessionTaskStatistics.m
//  Poodle
//
//  Created by Poodle on 2020/12/29.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLSessionTaskStatistics.h"
#import <sys/sysctl.h>
#import <sys/types.h>

@implementation PDLSessionTaskStatistics

static NSDate *PDLSessionTaskStatisticsProcessStartDate(void) {
    static NSDate *_processStartDate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pid_t pid = [[NSProcessInfo processInfo] processIdentifier];
        int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, pid };
        struct kinfo_proc proc;
        size_t size = sizeof(proc);
        sysctl(mib, 4, &proc, &size, NULL, 0);

        NSDate *processStartDate = [NSDate dateWithTimeIntervalSince1970:proc.kp_proc.p_starttime.tv_sec];
        _processStartDate = processStartDate;
    });
    return _processStartDate;
}

- (instancetype)initWithTask:(NSURLSessionTask *)task {
    self = [super init];
    if (self) {
        NSString *urlString = task.originalRequest.URL.absoluteString;
        if (urlString.length == 0) {
            return nil;
        }

        _taskClass = [task class];
        _urlString = urlString;
        _countOfBytesReceived = [task countOfBytesReceived];
        _countOfBytesSent = [task countOfBytesSent];
        _error = task.error;

        NSTimeInterval taskStartTime = 0;
        if ([task respondsToSelector:@selector(startTime)]) {
            taskStartTime = [((typeof(self))task) startTime];
            NSDate *startTimeDate = [NSDate dateWithTimeIntervalSinceReferenceDate:taskStartTime];
            NSDate *processStartDate = PDLSessionTaskStatisticsProcessStartDate();
            NSTimeInterval startTime = [startTimeDate timeIntervalSinceDate:processStartDate];
            _startTime = startTime;
            _duration = [[NSDate date] timeIntervalSinceDate:startTimeDate];
        }

        if (_urlString.length == 0) {
            free(NULL);
        }
    }
    return self;
}

- (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"%@(%@), %@, [%@|%@] %.3fs, %.3fs", _taskClass, @(_error.code), _urlString, @(_countOfBytesSent), @(_countOfBytesReceived), _startTime, _duration];
    return description;
}

@end
