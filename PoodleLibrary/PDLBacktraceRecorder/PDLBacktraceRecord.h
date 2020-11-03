//
//  PDLBacktraceRecord.h
//  Poodle
//
//  Created by Poodle on 2020/11/2.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLBacktrace.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLBacktraceRecord : NSObject

@property (nonatomic, assign) CFTimeInterval time;
@property (nonatomic, strong) PDLBacktrace *backtrace;

@end

NS_ASSUME_NONNULL_END
