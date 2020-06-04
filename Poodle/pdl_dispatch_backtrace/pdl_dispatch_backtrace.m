//
//  pdl_dispatch_backtrace.m
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "pdl_dispatch_backtrace.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "pdl_backtrace.h"

@interface PDLDispatchBlockBacktrace : NSObject

@property (nonatomic, copy) dispatch_block_t block;
@property (nonatomic, assign) pdl_backtrace_t backtrace;

@end

@implementation PDLDispatchBlockBacktrace

static void *pdl_dispatch_backtrace_invoke(void *arg) {
    PDLDispatchBlockBacktrace *self = (__bridge PDLDispatchBlockBacktrace *)(arg);
    return ((void *(^)(void))self.block)();
}

- (void)run {
    pdl_backtrace_thread_execute(_backtrace, pdl_dispatch_backtrace_invoke, (__bridge void *)(self), false);
    pdl_backtrace_destroy(_backtrace);
    _backtrace = NULL;
}

- (void)dealloc {
    pdl_backtrace_destroy(_backtrace);
    _backtrace = NULL;
}

void pdl_dispatch_backtrace_async(dispatch_queue_t queue, dispatch_block_t block, void (*dispatch_async_original)(dispatch_queue_t queue, dispatch_block_t block)) {
    PDLDispatchBlockBacktrace *blockBacktrace = [[PDLDispatchBlockBacktrace alloc] init];
    blockBacktrace.block = block;
    pdl_backtrace_t backtrace = pdl_backtrace_create();
    pdl_backtrace_record(backtrace);
    blockBacktrace.backtrace = backtrace;
    typeof(dispatch_async_original) dispatch_async_ptr = dispatch_async_original ?: &dispatch_async;
    dispatch_async_ptr(queue, ^{
        [blockBacktrace run];
    });
}

void pdl_dispatch_backtrace_async_f(dispatch_queue_t queue, void *context, dispatch_function_t work, void (*dispatch_async_original)(dispatch_queue_t queue, dispatch_block_t block)) {
    PDLDispatchBlockBacktrace *blockBacktrace = [[PDLDispatchBlockBacktrace alloc] init];
    blockBacktrace.block = ^{
        work(context);
    };
    pdl_backtrace_t backtrace = pdl_backtrace_create();
    pdl_backtrace_record(backtrace);
    blockBacktrace.backtrace = backtrace;
    typeof(dispatch_async_original) dispatch_async_ptr = dispatch_async_original ?: &dispatch_async;
    dispatch_async_ptr(queue, ^{
        [blockBacktrace run];
    });
}

void pdl_dispatch_backtrace_after(dispatch_time_t when, dispatch_queue_t queue, dispatch_block_t block, void (*dispatch_after_original)(dispatch_time_t when, dispatch_queue_t queue, dispatch_block_t block)) {
    PDLDispatchBlockBacktrace *blockBacktrace = [[PDLDispatchBlockBacktrace alloc] init];
    blockBacktrace.block = block;
    pdl_backtrace_t backtrace = pdl_backtrace_create();
    pdl_backtrace_record(backtrace);
    blockBacktrace.backtrace = backtrace;
    typeof(dispatch_after_original) dispatch_after_ptr = dispatch_after_original ?: &dispatch_after;
    dispatch_after_ptr(when, queue, ^{
        [blockBacktrace run];
    });
}

@end
