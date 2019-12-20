//
//  pdl_os.m
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "pdl_os.h"

OS_UNFAIR_LOCK_AVAILABILITY
mach_port_t pdl_os_unfair_lock_owner(os_unfair_lock_t lock) {
    uint32_t opaque = lock->_os_unfair_lock_opaque;
    return opaque ? opaque | 0x1 : 0;
}
