//
//  pdl_objc_message-x86_64.s
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_asm-universal.h"

#ifdef __x86_64__

.text
.align 4
.private_extern _pdl_objc_msgSend
.private_extern _pdl_objc_msgSend_stret
.private_extern _pdl_objc_msgSendSuper2
.private_extern _pdl_objc_msgSendSuper2_stret

_pdl_objc_msgSend:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    call    _pdl_objc_msgSend_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    movq    _pdl_objc_msgSend_original(%rip), %r11
    jmp     *%r11

_pdl_objc_msgSend_stret:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    movq    %a2, %a1
    movq    %a3, %a2
    call    _pdl_objc_msgSend_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    movq    _pdl_objc_msgSend_stret_original(%rip), %r11
    jmp     *%r11

_pdl_objc_msgSendSuper2:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    call    _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    movq    _pdl_objc_msgSendSuper2_original(%rip), %r11
    jmp     *%r11


_pdl_objc_msgSendSuper2_stret:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    call    _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    movq    _pdl_objc_msgSendSuper2_stret_original(%rip), %r11
    jmp     *%r11

#endif
