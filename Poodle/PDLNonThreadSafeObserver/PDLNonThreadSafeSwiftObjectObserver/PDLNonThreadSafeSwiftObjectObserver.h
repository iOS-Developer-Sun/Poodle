//
//  PDLNonThreadSafeSwiftObjectObserver.h
//  Poodle
//
//  Created by Poodle on 2023/6/5.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLNonThreadSafeSwiftObjectObserverSwiftObject.h"
#import "PDLBacktrace.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafeSwiftObjectObserver : NSObject

+ (void)observeWithFilter:(BOOL(^_Nullable)(PDLBacktrace *backtrace, NSString *_Nonnull * _Nullable name))filter;

@end

NS_ASSUME_NONNULL_END
