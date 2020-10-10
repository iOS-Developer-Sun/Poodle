//
//  pdl_dynamic_objc_message-x86_64.s
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifdef __x86_64__

.text
.align 4
.private_extern __pdl_dynamic_objc_msgSend
.private_extern __pdl_dynamic_objc_msgSend_stret
.private_extern __pdl_dynamic_objc_msgSendSuper
.private_extern __pdl_dynamic_objc_msgSendSuper_stret

__pdl_dynamic_objc_msgSend:
    movq    _pdl_dynamic_objc_message_pointer_objc_msgSend(%rip), %r11
    cmpq    $0, %r11
    je      LOriginal
    jmpq    *%r11
LOriginal:
    jmp     _objc_msgSend

__pdl_dynamic_objc_msgSend_stret:
    movq    _pdl_dynamic_objc_message_pointer_objc_msgSend_stret(%rip), %r11
    cmpq    $0, %r11
    je      LOriginal_stret
    jmpq    *%r11
LOriginal_stret:
    jmp     _objc_msgSend_stret

__pdl_dynamic_objc_msgSendSuper:
    movq    _pdl_dynamic_objc_message_pointer_objc_msgSendSuper2(%rip), %r11
    cmpq    $0, %r11
    je      LOriginalSuper
    jmpq    *%r11
LOriginalSuper:
    jmp     _objc_msgSendSuper2

__pdl_dynamic_objc_msgSendSuper_stret:
    movq    _pdl_dynamic_objc_message_pointer_objc_msgSendSuper2_stret(%rip), %r11
    cmpq    $0, %r11
    je      LOriginalSuper_stret
    jmpq    *%r11
LOriginalSuper_stret:
    jmp     _objc_msgSendSuper2_stret

#endif
