//
//  NSObject+PDLSelectorProxy-arm.s
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_asm-universal.h"

#ifdef __arm__

.text
.align 4
.private_extern _NSObjectSelectorProxyEntry
.private_extern _NSObjectSelectorProxyEntry_stret

_NSObjectSelectorProxyEntry:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    bl     _NSObjectSelectorProxyForwarding
    mov    r12, r0
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    bx     r12

_NSObjectSelectorProxyEntry_stret:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    bl     _NSObjectSelectorProxyForwarding
    mov    r12, r0
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    bx     r12

#endif
