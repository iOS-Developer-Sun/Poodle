//
//  pdl_mach.h
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>

#ifdef __cplusplus
extern "C" {
#endif

// You must free() the return value
extern thread_array_t pdl_mach_threads(mach_msg_type_number_t *count);

extern NSArray *pdl_mach_threadsArray(void);

#ifdef __cplusplus
}
#endif
