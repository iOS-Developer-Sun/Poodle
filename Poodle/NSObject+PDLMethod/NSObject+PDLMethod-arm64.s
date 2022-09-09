//
//  NSObject+PDLMethod-arm64.s
//  Poodle
//
//  Created by Poodle on 2020/7/15.
//  Copyright © 2020 Poodle. All rights reserved.
//

#include "pdl_asm-universal.h"

#ifdef __arm64__

.text
.align 4
.private_extern _PDLMethodEntry
.private_extern _PDLMethodEntry_stret
.private_extern _PDLMethodEntryFull
.private_extern _PDLMethodEntryFull_stret

_PDLMethodEntry:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    bl      _PDLMethodBefore
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    ldr     x9, [x1, #0x10]
    ldr     x1, [x1]
#ifdef __arm64e__
    braaz  x9
#else
    br     x9
#endif

_PDLMethodEntry_stret:
    b   _PDLMethodEntry

_PDLMethodEntryFull:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    mov     x2, lr
    bl      _PDLMethodFullBefore
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    ldr     x9, [x1, #0x10]
    ldr     x1, [x1]
#ifdef __arm64e__
    blraaz  x9
#else
    blr     x9
#endif
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    bl      _PDLMethodFullAfter
    mov     x9, x0
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     lr, x9
    ret

_PDLMethodEntryFull_stret:
    b   _PDLMethodEntryFull

#endif
