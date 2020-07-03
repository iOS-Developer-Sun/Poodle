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
    pdl_allocation_policy_zombie_only,
} pdl_allocation_policy;

extern unsigned int pdl_allocation_record_alloc_hidden_count(void);
extern void pdl_allocation_set_record_alloc_hidden_count(unsigned int hidden_count);
extern unsigned int pdl_allocation_record_dealloc_hidden_count(void);
extern void pdl_allocation_set_record_dealloc_hidden_count(unsigned int hidden_count);

extern unsigned int pdl_allocation_record_max_object_count(void);
extern void pdl_allocation_set_record_max_object_count(unsigned int max_count);

extern unsigned int pdl_allocation_zombie_duration(void);
extern void pdl_allocation_set_zombie_duration(unsigned int zombie_duration);

extern bool pdl_allocation_is_zombie(__unsafe_unretained id object);

extern pdl_backtrace_t pdl_allocation_backtrace(__unsafe_unretained id object);
extern pdl_backtrace_t pdl_deallocation_backtrace(__unsafe_unretained id object);

extern bool pdl_allocation_enable(pdl_allocation_policy policy);
