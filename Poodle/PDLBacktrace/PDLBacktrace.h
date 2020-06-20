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

- (instancetype)init;
- (instancetype)initWithBacktrace:(pdl_backtrace_t)backtrace;
- (void)record;
- (void)record:(unsigned int)hiddenCount;
- (void)show;
- (void)showWithoutWaiting;
- (void)showWithThreadStart:(int (*)(pthread_t *, const pthread_attr_t *, void *(*)(void *), void *))thread_create;
- (void)hide;

@end
