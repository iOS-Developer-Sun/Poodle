//
//  pdl_objc_message.h
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//
//

#include <NSObject+PDLPrivate.h>

#ifdef __cplusplus
extern "C" {
#endif

extern void(*pdl_get_objc_msgSend_before_action(void))(__unsafe_unretained id self, SEL _cmd);
extern void pdl_set_objc_msgSend_before_action(void(*pdl_objc_msgSend_before_action)(__unsafe_unretained id self, SEL _cmd));

extern void(*pdl_get_objc_msgSendSuper_before_action(void))(struct objc_super *super, SEL _cmd);
extern void pdl_set_objc_msgSendSuper_before_action(void(*pdl_objc_msgSendSuper_before_action)(struct objc_super *super, SEL _cmd));

#ifdef __cplusplus
}
#endif
