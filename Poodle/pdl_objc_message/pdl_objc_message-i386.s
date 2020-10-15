//
//  pdl_objc_message-i386.s
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_asm-universal.h"

#ifdef __i386__

.text
.align 4
.private_extern _pdl_objc_msgSend
.private_extern _pdl_objc_msgSendFull
.private_extern _pdl_objc_msgSend_stret
.private_extern _pdl_objc_msgSend_stretFull
.private_extern _pdl_objc_msgSendSuper
.private_extern _pdl_objc_msgSendSuperFull
.private_extern _pdl_objc_msgSendSuper_stret
.private_extern _pdl_objc_msgSendSuper_stretFull
.private_extern _pdl_objc_msgSendSuper2
.private_extern _pdl_objc_msgSendSuper2Full
.private_extern _pdl_objc_msgSendSuper2_stret
.private_extern _pdl_objc_msgSendSuper2_stretFull

_pdl_objc_msgSend:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    call    _pdl_objc_msgSend_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     _pdl_objc_msgSend_original, %eax
    jmp     *%eax

_pdl_objc_msgSendFull:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    call    _pdl_objc_msgSend_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     _pdl_objc_msgSend_original, %eax
    jmp     *%eax

_pdl_objc_msgSend_stret:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    call    _pdl_objc_msgSend_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     _pdl_objc_msgSend_stret_original, %eax
    jmp     *%eax

_pdl_objc_msgSend_stretFull:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    call    _pdl_objc_msgSend_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     _pdl_objc_msgSend_stret_original, %eax
    jmp     *%eax

_pdl_objc_msgSendSuper:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    call    _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     _pdl_objc_msgSendSuper_original, %eax
    jmp     *%eax

_pdl_objc_msgSendSuperFull:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    call    _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     _pdl_objc_msgSendSuper_original, %eax
    jmp     *%eax

_pdl_objc_msgSendSuper_stret:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    call    _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     _pdl_objc_msgSendSuper_stret_original, %eax
    jmp     *%eax

_pdl_objc_msgSendSuper_stretFull:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    call    _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     _pdl_objc_msgSendSuper_stret_original, %eax
    jmp     *%eax

_pdl_objc_msgSendSuper2:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    call    _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     _pdl_objc_msgSendSuper2_original, %eax
    jmp     *%eax

_pdl_objc_msgSendSuper2Full:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    call    _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     _pdl_objc_msgSendSuper2_original, %eax
    jmp     *%eax

_pdl_objc_msgSendSuper2_stret:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    call    _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     _pdl_objc_msgSendSuper2_stret_original, %eax
    jmp     *%eax


_pdl_objc_msgSendSuper2_stretFull:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    call    _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     _pdl_objc_msgSendSuper2_stret_original, %eax
    jmp     *%eax

#endif
