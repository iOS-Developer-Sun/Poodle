//
//  NSObject+PDLSelectorProxy-x86_64.s
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_asm-universal.h"

#ifdef __x86_64__

.text
.align 4
.private_extern _NSObjectSelectorProxyEntry
.private_extern _NSObjectSelectorProxyEntry_stret

_NSObjectSelectorProxyEntry:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    call    _NSObjectSelectorProxyForwarding
    movq    %rax, %r11
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    jmp    *%r11

_NSObjectSelectorProxyEntry_stret:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    call    _NSObjectSelectorProxyForwarding
    movq    %rax, %r11
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    jmp    *%r11

#endif
