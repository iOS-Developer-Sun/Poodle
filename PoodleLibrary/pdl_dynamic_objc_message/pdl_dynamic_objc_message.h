//
//  pdl_dynamic_objc_message.h
//  Poodle
//
//  Created by Poodle on 2020/10/10.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <objc/message.h>

#ifdef __cplusplus
extern "C" {
#endif

extern void pdl_dynamic_objc_msgSend(void);
extern void pdl_dynamic_objc_msgSendSuper2(void);
#ifndef __arm64__
extern void pdl_dynamic_objc_msgSend_stret(void);
extern void pdl_dynamic_objc_msgSendSuper2_stret(void);
#endif

extern void pdl_dynamic_objc_msgSend_initialize(BOOL full);

#ifdef __cplusplus
}
#endif
