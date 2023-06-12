//
//  pdl_dispatch.h
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <dispatch/dispatch.h>

#ifdef __cplusplus
extern "C" {
#endif

extern DISPATCH_RETURNS_RETAINED dispatch_queue_t pdl_dispatch_queue_create(const char *label, dispatch_queue_attr_t attr, DISPATCH_RETURNS_RETAINED dispatch_queue_t (*dispatch_queue_create_original)(const char *label, dispatch_queue_attr_t attr));
extern DISPATCH_RETURNS_RETAINED dispatch_queue_t pdl_dispatch_queue_create_with_target(const char *label, dispatch_queue_attr_t attr, dispatch_queue_t target, DISPATCH_RETURNS_RETAINED dispatch_queue_t (*dispatch_queue_create_with_target_original)(const char *label, dispatch_queue_attr_t attr, dispatch_queue_t target));

extern dispatch_queue_t pdl_dispatch_get_current_queue(void);
extern unsigned long pdl_dispatch_get_queue_width(dispatch_queue_t queue);
extern unsigned long pdl_dispatch_get_queue_unique_identifier(dispatch_queue_t queue);
extern void pdl_dispatch_queue_enable(void);

#ifdef __cplusplus
}
#endif


