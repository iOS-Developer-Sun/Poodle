//
//  PDLNonThreadSafeObserverAction.h
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>
#import "PDLBacktrace.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafeObserverAction : NSObject

@property (nonatomic, assign) BOOL isInitializing;
@property (nonatomic, assign) BOOL isSetter;
@property (nonatomic, assign) mach_port_t thread;
@property (nonatomic, copy) NSString *_Nullable queueIdentifier;
@property (nonatomic, copy) NSString *_Nullable queueLabel;
@property (nonatomic, assign) BOOL isSerialQueue;
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, copy) NSString *_Nullable detail;
@property (nonatomic, strong) PDLBacktrace *backtrace;

@end

NS_ASSUME_NONNULL_END
