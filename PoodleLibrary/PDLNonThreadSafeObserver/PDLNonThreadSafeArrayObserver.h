//
//  PDLNonThreadSafeArrayObserver.h
//  Poodle
//
//  Created by Poodle on 2021/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLNonThreadSafeArrayObserverArray.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafeArrayObserver : NSObject

+ (BOOL(^)(PDLBacktrace *backtrace, NSString * _Nullable * _Nonnull name))filter;
+ (void)observeWithFilter:(BOOL(^)(PDLBacktrace *backtrace, NSString * _Nullable * _Nonnull name))filter;

@end

NS_ASSUME_NONNULL_END
