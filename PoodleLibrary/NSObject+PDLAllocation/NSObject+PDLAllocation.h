//
//  NSObject+PDLAllocation.h
//  Poodle
//
//  Created by Poodle on 2020/6/18.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "pdl_backtrace.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PDLAllocationPolicy) {
    PDLAllocationPolicyLiveAllocations,
    PDLAllocationPolicyAllocationAndFree,
};


@interface NSObject (PDLAllocation)

extern unsigned int pdl_allocation_record_hidden_count;
extern unsigned int pdl_record_max_count;

pdl_backtrace_t pdl_allocation_backtrace(__unsafe_unretained id object);
pdl_backtrace_t pdl_deallocation_backtrace(__unsafe_unretained id object);

+ (BOOL)pdl_enableAllocation:(PDLAllocationPolicy)policy;

@end

NS_ASSUME_NONNULL_END
