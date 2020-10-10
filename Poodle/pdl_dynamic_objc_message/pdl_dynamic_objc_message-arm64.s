//
//  pdl_dynamic_objc_message-arm64.s
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifdef __arm64__

.text
.align 4
.private_extern __pdl_dynamic_objc_msgSend
.private_extern __pdl_dynamic_objc_msgSendSuper

__pdl_dynamic_objc_msgSend:
    adrp x9, _pdl_dynamic_objc_message_pointer_objc_msgSend@PAGE
    ldr x9, [x9, _pdl_dynamic_objc_message_pointer_objc_msgSend@PAGEOFF]
    cbz x9, LOriginal
    br x9
LOriginal:
    b _objc_msgSend

__pdl_dynamic_objc_msgSendSuper:
    adrp x9, _pdl_dynamic_objc_message_pointer_objc_msgSendSuper2@PAGE
    ldr x9, [x9, _pdl_dynamic_objc_message_pointer_objc_msgSendSuper2@PAGEOFF]
    cbz x9, LOriginalSuper
    br x9
LOriginalSuper:
    b _objc_msgSendSuper2

#endif
