//
//  NSObject+PDLSelectorProxy-i386.s
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_asm-universal.h"

#ifdef __i386__

.text
.align 4
.private_extern _NSObjectSelectorProxyEntry
.private_extern _NSObjectSelectorProxyEntry_stret

_NSObjectSelectorProxyEntry:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    call    _NSObjectSelectorProxyForwarding
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    jmp     *%eax

_NSObjectSelectorProxyEntry_stret:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    call    _NSObjectSelectorProxyForwarding
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    jmp     *%eax

#endif
