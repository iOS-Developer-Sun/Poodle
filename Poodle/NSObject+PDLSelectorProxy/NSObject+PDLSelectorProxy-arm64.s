//
//  NSObject+PDLSelectorProxy-arm64.s
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_asm-universal.h"

#ifdef __arm64__

.text
.align 4
.private_extern _NSObjectSelectorProxyEntry
.private_extern _NSObjectSelectorProxyEntry_stret

_NSObjectSelectorProxyEntry:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    bl     _NSObjectSelectorProxyForwarding
    mov    x9, x0
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
#ifdef __arm64e__
    braaz  x9
#else
    br     x9
#endif

_NSObjectSelectorProxyEntry_stret:
    b _NSObjectSelectorProxyEntry

#endif
