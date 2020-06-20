//
//  NSObject+PDLAllocation.h
//  Poodle
//
//  Created by Poodle on 2020/6/18.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLBacktrace.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PDLAllocationPolicy) {
    PDLAllocationPolicyLiveAllocations,
    PDLAllocationPolicyAllocationAndFree,
};


@interface NSObject (PDLAllocation)

@property (assign, class) unsigned int pdl_allocationRecordHiddenCount;
@property (assign, class) unsigned int pdl_recordMaxCount;

+ (PDLBacktrace *)pdl_allocationBacktrace:(__unsafe_unretained id)object;
+ (PDLBacktrace *)pdl_deallocationBacktrace:(__unsafe_unretained id)object;

+ (BOOL)pdl_enableAllocation:(PDLAllocationPolicy)policy;

@end

NS_ASSUME_NONNULL_END
