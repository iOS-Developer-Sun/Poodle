//
//  pdl_objc_message_hook.h
//  Poodle
//
//  Created by Poodle on 2020/10/10.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <objc/message.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifndef __i386__

extern void pdl_objc_message_hook(void(*before)(__unsafe_unretained id self, SEL _cmd), void(*after)(__unsafe_unretained id self, SEL _cmd), void(*super_before)(struct objc_super *super, SEL _cmd), void(*super_after)(struct objc_super *super, SEL _cmd));

#endif

#ifdef __cplusplus
}
#endif
