//
//  PDLSessionTaskStatistics.m
//  Poodle
//
//  Created by Poodle on 2020/12/29.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLSessionTaskStatistics.h"
#import "PDLProcessInfo.h"

@implementation PDLSessionTaskStatistics

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
            NSDate *processStartDate = [PDLProcessInfo sharedInstance].processStartDate;
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
