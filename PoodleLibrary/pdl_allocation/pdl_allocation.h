//
//  pdl_allocation.h
//  Poodle
//
//  Created by Poodle on 2020/6/18.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "pdl_backtrace.h"

typedef enum pdl_allocation_policy {
    pdl_allocation_policy_live_allocations,
    pdl_allocation_policy_allocation_and_free,
} pdl_allocation_policy;

extern unsigned int pdl_allocation_record_hidden_count;
extern unsigned int pdl_record_max_count;

extern pdl_backtrace_t pdl_allocation_backtrace(__unsafe_unretained id object);
extern pdl_backtrace_t pdl_deallocation_backtrace(__unsafe_unretained id object);

extern bool pdl_allocation_enable(pdl_allocation_policy policy);
