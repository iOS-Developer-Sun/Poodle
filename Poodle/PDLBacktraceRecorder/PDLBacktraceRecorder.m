//
//  PDLBacktraceRecorder.m
//  Poodle
//
//  Created by Poodle on 2020/10/29.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLBacktraceRecorder.h"
#import <QuartzCore/QuartzCore.h>
#import <mach/mach.h>
#import <sys/ucontext.h>
#import "pdl_backtrace.h"
#import "pdl_thread.h"
#import "PDLBacktrace.h"

@interface PDLBacktraceRecorder ()

@property (nonatomic, strong) NSMutableArray *records;
@property (nonatomic, assign) mach_port_t thread;
@property (nonatomic, assign) BOOL invalidated;

@end

@implementation PDLBacktraceRecorder

static void *PDLBacktraceRecorderMain(void *data) {
    PDLBacktraceRecorder *self = (__bridge PDLBacktraceRecorder *)(data);
    [self main];
    return NULL;
}

- (instancetype)initWithThread:(mach_port_t)thread {
    self = [super init];
    if (self) {
        _thread = thread;
        _records = [NSMutableArray array];
        pthread_t t;
        pthread_create(&t, NULL, PDLBacktraceRecorderMain, (__bridge void *)(self));
    }
    return self;
}

- (void)invalidate {
    self.invalidated = YES;
}

- (void)main {
    [NSThread currentThread].name = NSStringFromClass(self.class);
    while (!self.invalidated) {
        [self tick];
        usleep(1000 * 1000 / 60 / 2);
    }
}

- (void)tick {
    @synchronized (self.records) {
        if (self.records.count >= 120 * 60) {
            [self.records removeObjectAtIndex:0];
        }
    }

    void *frames[128 + 1] = {0};
    unsigned int frames_count = 0;
    void *fp = NULL;
    void *lr = NULL;
    void *pc = NULL;

    mach_port_t thread = self.thread;
    thread_suspend(thread);

//#ifdef __arm64__
//    _STRUCT_MCONTEXT machine_context = {0};
//    mach_msg_type_number_t state_count = ARM_THREAD_STATE64_COUNT;
//    kern_return_t kr = thread_get_state(self.thread, ARM_THREAD_STATE64, (thread_state_t)&(machine_context.__ss), &state_count);
//    if (kr == KERN_SUCCESS) {
//        fp = (void *)machine_context.__ss.__fp;
//        lr = (void *)machine_context.__ss.__lr;
//        pc = (void *)machine_context.__ss.__pc;
//    }
//    void *fp_lr[2] = {fp, lr};
//    void *frame_pointer = &fp_lr;
//    frames_count = pdl_thread_frames(pc, frame_pointer, frames, sizeof(frames) / sizeof(frames[0]) - 1);
//#endif

    thread_resume(thread);

    pdl_backtrace_t bt = pdl_backtrace_create();
    pdl_backtrace_set_frames(bt, frames, frames_count);
    PDLBacktrace *backtrace = [[PDLBacktrace alloc] initWithBacktrace:bt];
    PDLBacktraceRecord *record = [[PDLBacktraceRecord alloc] init];
    record.time = CACurrentMediaTime();
    record.backtrace = backtrace;
    @synchronized (self.records) {
        [self.records addObject:record];
    }
}

- (NSArray<PDLBacktraceRecord *> *)recordsFrom:(CFTimeInterval)from to:(CFTimeInterval)to {
    NSArray *records = nil;
    @synchronized (self.records) {
        records = [self.records copy];
    }
    NSInteger beginIndex = 0;
    NSInteger endIndex = records.count - 1;
    BOOL beginFound = NO;
    BOOL endFound = NO;
    while (beginIndex < endIndex) {
        PDLBacktraceRecord *beginRecord = records[beginIndex];
        PDLBacktraceRecord *endRecord = records[endIndex];
        CFTimeInterval begin = beginRecord.time;
        CFTimeInterval end = endRecord.time;
        if (begin <= from) {
            beginIndex++;
        } else {
            beginFound = YES;
        }
        if (end >= to) {
            endIndex--;
        } else {
            endFound = YES;
        }
        if (beginFound && endFound) {
            break;
        }
    }

    NSInteger count = endIndex - beginIndex;
    NSArray *ret = @[];
    if (count > 0) {
        ret = [records subarrayWithRange:NSMakeRange(beginIndex, count)];
    }

    return ret;
}

@end
