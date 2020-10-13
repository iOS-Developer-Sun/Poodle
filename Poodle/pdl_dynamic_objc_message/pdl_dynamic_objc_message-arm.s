//
//  pdl_dynamic_objc_message-arm.s
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifdef __arm__

.data
.p2align 4

L_data_pdl_dynamic_objc_message_pointer_objc_msgSend:
.long _pdl_dynamic_objc_message_pointer_objc_msgSend

L_data_pdl_dynamic_objc_message_pointer_objc_msgSendSuper2:
.long _pdl_dynamic_objc_message_pointer_objc_msgSendSuper2

L_data_pdl_dynamic_objc_message_pointer_objc_msgSend_stret:
.long _pdl_dynamic_objc_message_pointer_objc_msgSend_stret

L_data_pdl_dynamic_objc_message_pointer_objc_msgSendSuper2_stret:
.long _pdl_dynamic_objc_message_pointer_objc_msgSendSuper2_stret

.text
.align 4
.private_extern _pdl_dynamic_dyld_objc_msgSend
.private_extern _pdl_dynamic_dyld_objc_msgSendSuper
.private_extern _pdl_dynamic_dyld_objc_msgSend_stret
.private_extern _pdl_dynamic_dyld_objc_msgSendSuper_stret

_pdl_dynamic_dyld_objc_msgSend:
//    ldr     ip, =_pdl_dynamic_objc_message_pointer_objc_msgSend
    movw    ip, :lower16:(L_data_pdl_dynamic_objc_message_pointer_objc_msgSend - (L_text_pdl_dynamic_objc_message_pointer_objc_msgSend - 0x30))
    movt    ip, :upper16:(L_data_pdl_dynamic_objc_message_pointer_objc_msgSend - (L_text_pdl_dynamic_objc_message_pointer_objc_msgSend - 0x30))
L_text_pdl_dynamic_objc_message_pointer_objc_msgSend:
    add     ip, pc
    ldr     ip, [ip]
    cmp     ip, #0x0
    beq     LOriginal
    bx      ip
LOriginal:
    b       _objc_msgSend

_pdl_dynamic_dyld_objc_msgSendSuper:
//    ldr     ip, =_pdl_dynamic_objc_message_pointer_objc_msgSendSuper2
    movw    ip, :lower16:(L_data_pdl_dynamic_objc_message_pointer_objc_msgSendSuper2 - (L_text_pdl_dynamic_objc_message_pointer_objc_msgSendSuper2 - 0x30))
    movt    ip, :upper16:(L_data_pdl_dynamic_objc_message_pointer_objc_msgSendSuper2 - (L_text_pdl_dynamic_objc_message_pointer_objc_msgSendSuper2 - 0x30))
L_text_pdl_dynamic_objc_message_pointer_objc_msgSendSuper2:
    add     ip, pc
    ldr     ip, [ip]
    cmp     ip, #0x0
    beq     LOriginalSuper
    bx      ip
LOriginalSuper:
    b       _objc_msgSendSuper2

_pdl_dynamic_dyld_objc_msgSend_stret:
//    ldr     ip, =_pdl_dynamic_objc_message_pointer_objc_msgSend_stret
    movw    ip, :lower16:(L_data_pdl_dynamic_objc_message_pointer_objc_msgSend_stret - (L_text_pdl_dynamic_objc_message_pointer_objc_msgSend_stret - 0x30))
    movt    ip, :upper16:(L_data_pdl_dynamic_objc_message_pointer_objc_msgSend_stret - (L_text_pdl_dynamic_objc_message_pointer_objc_msgSend_stret - 0x30))
L_text_pdl_dynamic_objc_message_pointer_objc_msgSend_stret:
    add     ip, pc
    ldr     ip, [ip]
    cmp     ip, #0x0
    beq     LOriginal_stret
    bx      ip
LOriginal_stret:
    b       _objc_msgSend_stret

_pdl_dynamic_dyld_objc_msgSendSuper_stret:
//    ldr     ip, =_pdl_dynamic_objc_message_pointer_objc_msgSendSuper2_stret
    movw    ip, :lower16:(L_data_pdl_dynamic_objc_message_pointer_objc_msgSendSuper2_stret - (L_text_pdl_dynamic_objc_message_pointer_objc_msgSendSuper2_stret - 0x30))
    movt    ip, :upper16:(L_data_pdl_dynamic_objc_message_pointer_objc_msgSendSuper2_stret - (L_text_pdl_dynamic_objc_message_pointer_objc_msgSendSuper2_stret - 0x30))
L_text_pdl_dynamic_objc_message_pointer_objc_msgSendSuper2_stret:
    add     ip, pc
    ldr     ip, [ip]
    cmp     ip, #0x0
    beq     LOriginalSuper_stret
    bx      ip
LOriginalSuper_stret:
    b       _objc_msgSendSuper2_stret

#endif
