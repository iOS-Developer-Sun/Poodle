//
//  PDLBacktrace.m
//  Poodle
//
//  Created by Poodle on 2020/6/1.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLBacktrace.h"
#import <dlfcn.h>

@interface PDLBacktrace ()

@property (assign) pdl_backtrace_t backtrace;

@end

@implementation PDLBacktrace

- (instancetype)init {
    self = [super init];
    if (self) {
        _backtrace = pdl_backtrace_create();
    }
    return self;
}

- (instancetype)initWithBacktrace:(pdl_backtrace_t)backtrace {
    if (!backtrace) {
        return nil;
    }

    self = [super init];
    if (self) {
        _backtrace = backtrace;
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
    pdl_backtrace_record(self.backtrace, NULL);
}

- (void)record:(unsigned int)hiddenCount {
    pdl_backtrace_record_attr attr = PDL_BACKTRACE_RECORD_ATTR_INIT;
    attr.hidden_count = hiddenCount;
    pdl_backtrace_record(self.backtrace, &attr);
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
    return [ret copy];
}

- (void)show {
    pdl_backtrace_thread_show(self.backtrace, YES);
}

- (void)showWithoutWaiting {
    pdl_backtrace_thread_show(self.backtrace, NO);
}

- (void)showWithThreadStart:(int (*)(pthread_t *, const pthread_attr_t *, void *(*)(void *), void *))thread_create {
    pdl_backtrace_thread_show_with_start(self.backtrace, YES, thread_create);
}

- (void)hide {
    pdl_backtrace_thread_hide(self.backtrace);
}

- (void)execute:(void *(*)(void *))start arg:(void *)arg hidden_count:(int)hidden_count {
    if (self.backtrace) {
        pdl_backtrace_thread_execute(self.backtrace, start, arg, hidden_count);
    }
}

- (NSString *)framesDescription {
    void **frames = pdl_backtrace_get_frames(self.backtrace);
    if (frames == NULL) {
        return nil;
    }

    NSMutableString *string = [NSMutableString string];
    int count = pdl_backtrace_get_frames_count(self.backtrace);
    Dl_info info;
    for (int i = 0; i < count; i++) {
        void *frame = frames[i];
        int ret = dladdr(frame, &info);
        if (ret) {
            [string appendFormat:@"%d:\t%s\t%p\n", i, info.dli_sname, frame];
        } else {
            [string appendFormat:@"%d:\t%p\n", i, frame];
        }
    }
    return [string copy];

}


@end
