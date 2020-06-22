//
//  pdl_objc_message.h
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "NSObject+PDLPrivate.h"
#include <objc/message.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __LP64__

extern void(*pdl_objc_message_msgSend_before_action(void))(__unsafe_unretained id self, SEL _cmd);
extern void pdl_objc_message_set_msgSend_before_action(void(*pdl_objc_msgSend_before_action)(__unsafe_unretained id self, SEL _cmd));

extern void(*pdl_objc_message_msgSendSuper_before_action(void))(struct objc_super *super, SEL _cmd);
extern void pdl_objc_message_set_msgSendSuper_before_action(void(*pdl_objc_msgSendSuper_before_action)(struct objc_super *super, SEL _cmd));

extern void(*pdl_objc_msgSend_original)(void);
extern void pdl_objc_msgSend(void);

extern void(*pdl_objc_msgSendSuper2_original)(void);
extern void pdl_objc_msgSendSuper2(void);

#ifndef __arm64__

extern void(*pdl_objc_msgSend_stret_original)(void);
extern void pdl_objc_msgSend_stret(void);

extern void(*pdl_objc_msgSendSuper2_stret_original)(void);
extern void pdl_objc_msgSendSuper2_stret(void);

#endif

#endif

#ifdef __cplusplus
}
#endif
