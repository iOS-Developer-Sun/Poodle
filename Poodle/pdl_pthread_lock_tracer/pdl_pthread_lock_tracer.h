//
//  pdl_pthread_lock_tracer.h
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

extern bool pdl_rw_lock_log_enabled;
extern void pdl_print_rw_lock_map(void);

#ifdef __cplusplus
}
#endif
