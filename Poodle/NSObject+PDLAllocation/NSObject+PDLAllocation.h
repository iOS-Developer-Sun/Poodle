//
//  NSObject+PDLAllocation.h
//  Poodle
//
//  Created by Poodle on 2020/6/18.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PDLAllocationPolicy) {
    PDLAllocationPolicyLiveAllocations,
    PDLAllocationPolicyAllocationAndFree,
};


@interface NSObject (PDLAllocation)

@property (assign, class) unsigned int pdl_allocationRecordHiddenCount;

+ (BOOL)pdl_enableAllocation:(PDLAllocationPolicy)policy;

@end

NS_ASSUME_NONNULL_END
