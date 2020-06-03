//
//  pdl_dispatch_backtrace.h
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <dispatch/dispatch.h>

#ifdef __cplusplus
extern "C" {
#endif

void pdl_dispatch_backtrace_async(dispatch_queue_t queue, dispatch_block_t block, void (*dispatch_async_original)(dispatch_queue_t queue, dispatch_block_t block));

#ifdef __cplusplus
}
#endif


