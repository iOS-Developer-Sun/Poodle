//
//  PDLSessionTaskStatisticsManager.m
//  Poodle
//
//  Created by Poodle on 2020/12/28.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLSessionTaskStatisticsManager.h"
#import "NSObject+PDLImplementationInterceptor.h"

@interface PDLSessionTaskStatistics ()

- (instancetype)initWithTask:(NSURLSessionTask *)task;

@end

@interface PDLSessionTaskStatisticsManager ()

@property (readonly) NSMutableArray *records;

@end

@implementation PDLSessionTaskStatisticsManager

static void pdl_NSURLSessionTaskSetState(__unsafe_unretained NSURLSessionTask *self, SEL _cmd, NSURLSessionTaskState state) {
    PDLImplementationInterceptorRecover(_cmd);
    ((typeof(&pdl_NSURLSessionTaskSetState))_imp)(self, _cmd, state);

    [[PDLSessionTaskStatisticsManager sharedInstance] taskDidSetState:self];
}

+ (BOOL)setup {
    return [NSURLSessionTask pdl_interceptSelector:sel_registerName("setState:") withInterceptorImplementation:(IMP)&pdl_NSURLSessionTaskSetState];
}

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
        _records = [NSMutableArray array];
    }
    return self;
}

- (NSArray<PDLSessionTaskStatistics *> *)statisticsRecords {
    @synchronized (_records) {
        return [_records copy];
    }
}

- (void)taskDidSetState:(NSURLSessionTask *)task {
    NSURLSessionTaskState state = task.state;
    switch (state) {
        case NSURLSessionTaskStateCanceling:
        case NSURLSessionTaskStateCompleted: {
            PDLSessionTaskStatistics *taskStatistics = [[PDLSessionTaskStatistics alloc] initWithTask:task];
            @synchronized (_records) {
                [_records addObject:taskStatistics];
            }
        } break;
        default:
            break;
    }
}

@end
