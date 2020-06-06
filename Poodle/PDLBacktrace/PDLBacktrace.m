//
//  PDLBacktrace.m
//  PoodleApplication
//
//  Created by Poodle on 2020/6/1.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLBacktrace.h"
#import "pdl_backtrace.h"

@interface PDLBacktrace ()

@property (nonatomic, assign) pdl_backtrace_t backtrace;

@end

@implementation PDLBacktrace

- (instancetype)init {
    self = [super init];
    if (self) {
        _backtrace = pdl_backtrace_create();
    }
    return self;
}

- (void)dealloc {
    pdl_backtrace_destroy(_backtrace);
}

- (NSString *)name {
    @synchronized (self) {
        const char *name = pdl_backtrace_get_name(self.backtrace);
        if (!name) {
            return nil;
        }

        return @(name);
    }
}

- (void)setName:(NSString *)name {
    @synchronized (self) {
        pdl_backtrace_set_name(self.backtrace, name ? name.UTF8String : NULL);
    }
}

- (void)record {
    pdl_backtrace_record(self.backtrace, 0);
}

- (void)record:(unsigned int)hiddenCount {
    pdl_backtrace_record(self.backtrace, hiddenCount);
}

- (BOOL)isShown {
    return pdl_backtrace_thread_is_shown(self.backtrace);
}

- (NSArray<NSNumber *> *)frames {
    void **frames = pdl_backtrace_get_frames(self.backtrace);
    if (frames == NULL) {
        return NULL;
    }

    NSMutableArray <NSNumber *>*ret = [NSMutableArray array];
    int count = pdl_backtrace_get_frames_count(self.backtrace);
    for (int i = 0; i < count; i++) {
        void *frame = frames[i];
        [ret addObject:@((uintptr_t)frame)];
    }
    return ret.copy;
}

- (void)show {
    pdl_backtrace_thread_show(self.backtrace, YES);
}

- (void)showWithoutWaiting {
    pdl_backtrace_thread_show(self.backtrace, NO);
}

- (void)hide {
    pdl_backtrace_thread_hide(self.backtrace);
}

@end
