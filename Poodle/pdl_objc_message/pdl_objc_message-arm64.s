//
//  pdl_objc_message-arm64.s
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_asm-universal.h"

#ifdef __arm64__

.text
.align 4
.private_extern _pdl_objc_msgSend
.private_extern _pdl_objc_msgSendFull
.private_extern _pdl_objc_msgSendSuper
.private_extern _pdl_objc_msgSendSuperFull
.private_extern _pdl_objc_msgSendSuper2
.private_extern _pdl_objc_msgSendSuper2Full

_pdl_objc_msgSend:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    bl      _pdl_objc_msgSend_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    adrp    x9, _pdl_objc_msgSend_original@PAGE
    ldr     x9, [x9, _pdl_objc_msgSend_original@PAGEOFF]
#ifdef __arm64e__
    braaz   x9
#else
    br      x9
#endif

_pdl_objc_msgSendFull:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    mov     x2, lr
    bl      _pdl_objc_msgSendFull_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    adrp    x9, _pdl_objc_msgSend_original@PAGE
    ldr     x9, [x9, _pdl_objc_msgSend_original@PAGEOFF]
#ifdef __arm64e__
    blraaz  x9
#else
    blr     x9
#endif
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    bl      _pdl_objc_msgSendFull_after
    mov     x9, x0
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     lr, x9
    ret

_pdl_objc_msgSendSuper:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    bl      _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    adrp    x9, _pdl_objc_msgSendSuper_original@PAGE
    ldr     x9, [x9, _pdl_objc_msgSendSuper_original@PAGEOFF]
#ifdef __arm64e__
    braaz   x9
#else
    br      x9
#endif

_pdl_objc_msgSendSuperFull:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    mov     x2, lr
    bl      _pdl_objc_msgSendSuperFull_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    adrp    x9, _pdl_objc_msgSendSuper_original@PAGE
    ldr     x9, [x9, _pdl_objc_msgSendSuper_original@PAGEOFF]
#ifdef __arm64e__
    blraaz  x9
#else
    blr     x9
#endif
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    bl      _pdl_objc_msgSendSuperFull_after
    mov     x9, x0
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     lr, x9
    ret

_pdl_objc_msgSendSuper2:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    bl      _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    adrp    x9, _pdl_objc_msgSendSuper2_original@PAGE
    ldr     x9, [x9, _pdl_objc_msgSendSuper2_original@PAGEOFF]
#ifdef __arm64e__
    braaz   x9
#else
    br      x9
#endif

_pdl_objc_msgSendSuper2Full:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    mov     x2, lr
    bl      _pdl_objc_msgSendSuperFull_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    adrp    x9, _pdl_objc_msgSendSuper2_original@PAGE
    ldr     x9, [x9, _pdl_objc_msgSendSuper2_original@PAGEOFF]
#ifdef __arm64e__
    blraaz  x9
#else
    blr     x9
#endif
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    bl      _pdl_objc_msgSendSuperFull_after
    mov     x9, x0
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     lr, x9
    ret

#endif
