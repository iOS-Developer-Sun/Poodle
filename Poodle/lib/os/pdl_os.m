//
//  pdl_os.m
//  Sun
//
//  Created by Sun on 14-6-27.
//
//

#import "pdl_os.h"

OS_UNFAIR_LOCK_AVAILABILITY
mach_port_t pdl_os_unfair_lock_owner(os_unfair_lock_t lock) {
    uint32_t opaque = lock->_os_unfair_lock_opaque;
    return opaque ? opaque | 0x1 : 0;
}
