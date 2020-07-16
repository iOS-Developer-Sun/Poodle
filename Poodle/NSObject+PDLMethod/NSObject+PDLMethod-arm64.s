//
//  NSObject+PDLMethod.m
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

_PDLMethodEntry:

PDL_ASM_OBJC_MESSAGE_STATE_SAVE
mov    x2, lr
bl     _PDLMethodBefore
PDL_ASM_OBJC_MESSAGE_STATE_RESTORE

ldr     x9, [x1, #0x10]
ldr     x1, [x1]
blr     x9

PDL_ASM_OBJC_MESSAGE_STATE_SAVE
bl      _PDLMethodAfter
mov     x9, x0
PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
mov     lr, x9

ret

#endif
