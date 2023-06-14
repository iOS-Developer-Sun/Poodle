//
//  PDLNonThreadSafeArrayObserverArray.m
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeArrayObserverArray.h"
#import "PDLNonThreadSafeArrayObserver.h"

@interface PDLNonThreadSafeArrayObserverArray ()

@end

@implementation PDLNonThreadSafeArrayObserverArray

+ (BOOL (^)(PDLBacktrace * _Nonnull, NSString * _Nonnull __autoreleasing * _Nullable))filter {
    return [PDLNonThreadSafeArrayObserver filter];
}

@end
