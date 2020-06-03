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

- (instancetype)init {
    self = [super init];
    if (self) {
        ;
    }
    return self;
}

- (void)run {
    self.block();

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
    dispatch_async_original(queue, ^{
        [blockBacktrace run];
    });
}

@end
