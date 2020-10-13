//
//  pdl_dynamic_bridge_objc_message.h
//  Poodle
//
//  Created by Poodle on 2020/10/10.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <objc/message.h>

#ifdef __cplusplus
extern "C" {
#endif

extern void pdl_dynamic_bridge_objc_msgSend(void);
extern void pdl_dynamic_bridge_objc_msgSendFull(void);
extern void pdl_dynamic_bridge_objc_msgSendSuper2(void);
extern void pdl_dynamic_bridge_objc_msgSendSuper2Full(void);

#ifndef __arm64__

extern void pdl_dynamic_bridge_objc_msgSend_stret(void);
extern void pdl_dynamic_bridge_objc_msgSend_stretFull(void);
extern void pdl_dynamic_bridge_objc_msgSendSuper2_stret(void);
extern void pdl_dynamic_bridge_objc_msgSendSuper2_stretFull(void);

#endif

#ifdef __cplusplus
}
#endif
