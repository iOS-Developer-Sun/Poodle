//
//  PDLRunLoopObserver.h
//  Poodle
//
//  Created by Poodle on 2020/10/29.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLRunLoopObserverLoop.h"

NS_ASSUME_NONNULL_BEGIN

@class PDLRunLoopObserver;

@protocol PDLRunLoopObserverDelegate <NSObject>

- (void)runLoopObserver:(PDLRunLoopObserver *)runLoopObserver didFinishLoop:(PDLRunLoopObserverLoop *)loop;

@end

@interface PDLRunLoopObserver : NSObject

- (instancetype)initWithRunLoop:(NSRunLoop *)runLoop;

@property (nonatomic, weak) id <PDLRunLoopObserverDelegate> delegate;
@property (nonatomic, assign) BOOL logEnabled;

- (void)start;
- (void)stop;

+ (NSString *)activityString:(CFRunLoopActivity)activity;

@end

NS_ASSUME_NONNULL_END
