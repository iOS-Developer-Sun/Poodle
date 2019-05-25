//
//  pdl_os.h
//  Sun
//
//  Created by Sun on 14-6-27.
//
//

#import <Foundation/Foundation.h>
#import <os/lock.h>

#ifdef __cplusplus
extern "C" {
#endif

OS_UNFAIR_LOCK_AVAILABILITY
extern mach_port_t pdl_os_unfair_lock_owner(os_unfair_lock_t lock);

#ifdef __cplusplus
}
#endif
