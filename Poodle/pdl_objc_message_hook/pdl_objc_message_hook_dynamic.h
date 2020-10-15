//
//  pdl_objc_message_hook_dynamic.h
//  Poodle
//
//  Created by Poodle on 2020/10/10.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <objc/message.h>

#ifdef __cplusplus
extern "C" {
#endif

struct pdl_objc_message_functions {
    void(*objc_msgSend)(void);
    void(*objc_msgSendSuper)(void);
    void(*objc_msgSendSuper2)(void);
    void(*objc_msgSend_stret)(void);
    void(*objc_msgSendSuper_stret)(void);
    void(*objc_msgSendSuper2_stret)(void);
};

extern struct pdl_objc_message_functions pdl_objc_message_hook_dynamic_init(BOOL full);

#ifdef __cplusplus
}
#endif
