//
//  PDLRunLoopObserverLoop.h
//  Poodle
//
//  Created by Poodle on 2020/11/3.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLRunLoopObserverLoopActivity : NSObject

@property (nonatomic, assign) CFTimeInterval time;
@property (nonatomic, assign) CFRunLoopActivity activity;

@end

@interface PDLRunLoopObserverLoop : NSObject

@property (nonatomic, assign) CFTimeInterval begin;
@property (nonatomic, assign) CFTimeInterval end;
@property (nonatomic, copy, readonly) NSArray <PDLRunLoopObserverLoopActivity *>*activities;
@property (nonatomic, copy, readonly) NSArray <PDLRunLoopObserverLoopActivity *>*intervals;

@end

NS_ASSUME_NONNULL_END
