//
//  pdl_os_unfair_lock_tracer.h
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//
//

#import <stdbool.h>

#if !TARGET_IPHONE_SIMULATOR

extern bool pdl_os_unfair_lock_log_enabled;
extern void pdl_print_os_unfair_lock_map(void);

#endif
