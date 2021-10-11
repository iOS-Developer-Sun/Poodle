//
//  PDLNonThreadSafeDictionaryObserver.h
//  Poodle
//
//  Created by Poodle on 2021/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLNonThreadSafeDictionaryObserverDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafeDictionaryObserver : NSObject

+ (BOOL(^)(PDLBacktrace *backtrace, NSString * _Nullable * _Nonnull name))filter;
+ (void)enableWithFilter:(BOOL(^)(PDLBacktrace *backtrace, NSString * _Nullable * _Nonnull name))filter;

@end

NS_ASSUME_NONNULL_END
