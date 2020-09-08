//
//  pdl_objc_message-arm.s
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_asm-universal.h"

#ifdef __arm__

.text
.align 4
.private_extern _pdl_objc_msgSend
.private_extern _pdl_objc_msgSendFull
.private_extern _pdl_objc_msgSend_stret
.private_extern _pdl_objc_msgSend_stretFull
.private_extern _pdl_objc_msgSendSuper2
.private_extern _pdl_objc_msgSendSuper2Full
.private_extern _pdl_objc_msgSendSuper2_stret
.private_extern _pdl_objc_msgSendSuper2_stretFull

_pdl_objc_msgSend:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    bl      _pdl_objc_msgSend_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    ldr     ip, =_pdl_objc_msgSend_original
    ldr     ip, [ip]
    bx      ip

_pdl_objc_msgSendFull:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    mov     r2, lr
    bl      _pdl_objc_msgSend_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    ldr     ip, =_pdl_objc_msgSend_original
    ldr     ip, [ip]
    blx     ip
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    bl      _pdl_objc_msgSendFull_after
    mov     ip, r0
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     lr, ip
    mov     pc, lr

_pdl_objc_msgSend_stret:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    bl      _pdl_objc_msgSend_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    ldr     ip, =_pdl_objc_msgSend_stret_original
    ldr     ip, [ip]
    bx      ip

_pdl_objc_msgSend_stretFull:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    mov     r2, lr
    bl      _pdl_objc_msgSend_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    ldr     ip, =_pdl_objc_msgSend_stret_original
    ldr     ip, [ip]
    blx     ip
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    bl      _pdl_objc_msgSendFull_after
    mov     ip, r0
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     lr, ip
    mov     pc, lr


_pdl_objc_msgSendSuper2:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    bl      _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    ldr     ip, =_pdl_objc_msgSendSuper2_original
    ldr     ip, [ip]
    bx      ip

_pdl_objc_msgSendSuper2Full:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    mov     r2, lr
    bl      _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    ldr     ip, =_pdl_objc_msgSendSuper2_original
    ldr     ip, [ip]
    blx     ip
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    bl      _pdl_objc_msgSendSuperFull_after
    mov     ip, r0
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     lr, ip
    mov     pc, lr

_pdl_objc_msgSendSuper2_stret:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    bl      _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    ldr     ip, =_pdl_objc_msgSendSuper2_stret_original
    ldr     ip, [ip]
    bx      ip

_pdl_objc_msgSendSuper2_stretFull:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    mov     r2, lr
    bl      _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    ldr     ip, =_pdl_objc_msgSendSuper2_stret_original
    ldr     ip, [ip]
    blx     ip
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    bl      _pdl_objc_msgSendSuperFull_after
    mov     ip, r0
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     lr, ip
    mov     pc, lr

#endif
