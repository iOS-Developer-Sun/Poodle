//
//  PDLBacktrace.m
//  Poodle
//
//  Created by Poodle on 2020/6/1.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLBacktrace.h"
#import <dlfcn.h>
#import "PDLCrash.h"

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

- (void)showWithBlock:(void(^)(void(^start)(void)))block {
    pdl_backtrace_thread_show_with_block(self.backtrace, YES, block);
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
    NSMutableString *string = [NSMutableString string];
    [self enumerateFrames:^(NSInteger index, void *address, NSString *symbol, NSString *image, BOOL *stops) {
        if (symbol.length > 0) {
            [string appendFormat:@"%@:\t%@\t%p\n", @(index), symbol, address];
        } else {
            [string appendFormat:@"%@:\t%p\n", @(index), address];
        }
    }];
    return [string copy];
}

+ (NSMutableDictionary *)symbolCache {
    static NSMutableDictionary *symbolCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        symbolCache = [NSMutableDictionary dictionary];
    });
    return symbolCache;
}

+ (int)dladdr:(const void *)frame :(Dl_info *)info {
    int ret = 0;
    NSMutableDictionary *symbolCache = [self symbolCache];
    @synchronized (symbolCache) {
        NSNumber *key = @((NSUInteger)frame);
        NSDictionary *value = symbolCache[key];
        if (!value) {
            ret = dladdr(frame, info);
            NSMutableDictionary *v = [NSMutableDictionary dictionary];
            v[@"return"] = @(ret);
            v[@"dli_fname"] = @((NSUInteger)(info->dli_fname));
            v[@"dli_fbase"] = @((NSUInteger)(info->dli_fbase));
            v[@"dli_sname"] = @((NSUInteger)(info->dli_sname));
            v[@"dli_saddr"] = @((NSUInteger)(info->dli_saddr));
            value = [v copy];
            symbolCache[key] = value;
        } else {
            ret = [value[@"return"] intValue];
            info->dli_fname = (void *)[value[@"dli_fname"] unsignedIntegerValue];
            info->dli_fbase = (void *)[value[@"dli_fbase"] unsignedIntegerValue];
            info->dli_sname = (void *)[value[@"dli_sname"] unsignedIntegerValue];
            info->dli_saddr = (void *)[value[@"dli_saddr"] unsignedIntegerValue];
        }
    }
    return ret;
}

- (void)enumerateFrames:(void(^)(NSInteger index, void *address, NSString *symbol, NSString *image, BOOL *stops))enumerator {
    if (!enumerator) {
        return;
    }

    void **frames = pdl_backtrace_get_frames(self.backtrace);
    if (frames == NULL) {
        return;
    }

    int count = pdl_backtrace_get_frames_count(self.backtrace);
    Dl_info info;
    for (int i = 0; i < count; i++) {
        void *frame = frames[i];
        int ret = [PDLBacktrace dladdr:frame :&info];
        NSString *symbol = nil;
        NSString *image = nil;
        if (ret) {
            symbol = @(info.dli_sname ?: "");
            image = @(info.dli_fname ?: "");
        }
        BOOL stops = NO;
        symbol = [PDLCrash demangle:symbol] ?: symbol;
        enumerator(i, frame, symbol, image, &stops);
        if (stops) {
            break;
        }
    }
}

+ (void)clearSymbolCache {
    NSMutableDictionary *symbolCache = [self symbolCache];
    @synchronized (symbolCache) {
        [symbolCache removeAllObjects];
    }
}

@end
