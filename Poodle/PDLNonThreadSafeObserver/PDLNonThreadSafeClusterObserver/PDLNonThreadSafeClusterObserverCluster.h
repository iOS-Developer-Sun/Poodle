//
//  PDLNonThreadSafeClusterObserverCluster.h
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeObserverCriticalResource.h"
#import "PDLBacktrace.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafeClusterObserverCluster : PDLNonThreadSafeObserverCriticalResource

@property (readonly) NSString *name;
@property (readonly) PDLBacktrace *backtrace;

+ (BOOL(^_Nullable)(PDLBacktrace *, NSString *_Nonnull* _Nullable))filter;

@end

NS_ASSUME_NONNULL_END
