//
//  PDLBacktrace.h
//  Poodle
//
//  Created by Poodle on 2020/6/1.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "pdl_backtrace.h"

@interface PDLBacktrace : NSObject

@property (atomic, copy) NSString *name;
@property (readonly) BOOL isShown;
@property (readonly) NSArray <NSNumber *>*frames;

@property (readonly) NSString *framesDescription;

- (instancetype)init;
- (instancetype)initWithBacktrace:(pdl_backtrace_t)backtrace;
- (void)record;
- (void)record:(unsigned int)hiddenCount;
- (void)show;
- (void)showWithoutWaiting;
- (void)showWithThreadStart:(int (*)(pthread_t *, const pthread_attr_t *, void *(*)(void *), void *))thread_create;
- (void)showWithBlock:(void(^)(void(^start)(void)))block;
- (void)hide;
- (void)execute:(void *(*)(void *))start arg:(void *)arg hidden_count:(int)hidden_count;
- (void)enumerateFrames:(void(^)(NSInteger index, void *address, NSString *symbol, NSString *image, BOOL *stops))enumerator;

+ (void)clearSymbolCache;

@end
