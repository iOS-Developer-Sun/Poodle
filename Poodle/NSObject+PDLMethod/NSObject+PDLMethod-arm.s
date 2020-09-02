//
//  NSObject+PDLMethod-arm.s
//  Poodle
//
//  Created by Poodle on 2020/7/15.
//  Copyright © 2020 Poodle. All rights reserved.
//

#include "pdl_asm-universal.h"

#ifdef __arm__

.text
.align 4
.private_extern _PDLMethodEntry
.private_extern _PDLMethodEntry_stret
.private_extern _PDLMethodEntryFull
.private_extern _PDLMethodEntryFull_stret

_PDLMethodEntry:

    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    bl      _PDLMethodBefore
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE

    ldr     ip, [r1, #0x8]
    ldr     r1, [r1]
    bx      ip

_PDLMethodEntry_stret:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    bl      _PDLMethodBefore
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE

    ldr     ip, [r2, #0x8]
    ldr     r2, [r2]
    bx      ip

_PDLMethodEntryFull:

    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    mov     r2, lr
    bl      _PDLMethodFullBefore
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE

    ldr     ip, [r1, #0x8]
    ldr     r1, [r1]
    blx     ip

    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    bl      _PDLMethodFullAfter
    mov     ip, r0
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     lr, ip
    mov     pc, lr

_PDLMethodEntryFull_stret:

    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    mov     r2, lr
    bl      _PDLMethodFullBefore
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE

    ldr     ip, [r2, #0x8]
    ldr     r2, [r2]
    blx     ip

    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    bl      _PDLMethodFullAfter
    mov     ip, r0
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     lr, ip
    mov     pc, lr

#endif
