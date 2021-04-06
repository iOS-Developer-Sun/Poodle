//
//  pdl_system_leak.h
//  Poodle
//
//  Created by Poodle on 2021/2/3.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

extern void pdl_system_leak_list_add(void *ptr, size_t size, int class_createInstance_frame_index);
extern CFDictionaryRef pdl_CNCopyCurrentNetworkInfo(CFStringRef interfaceName);

extern BOOL pdl_system_leak_enable_NEHotspotNetwork(void);

#ifdef __cplusplus
}
#endif
