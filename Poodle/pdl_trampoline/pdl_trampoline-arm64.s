//
//  pdl_trampoline-arm64.s
//  Poodle
//
//  Created by Poodle on 11-8-23.
//  Copyright © 2021 Poodle. All rights reserved.
//

#include "pdl_asm-universal.h"

#ifdef __arm64__

#include <mach/vm_param.h>

.text

.private_extern _pdl_trampoline_page_begin
.private_extern _pdl_trampoline_page_stubs
.private_extern _pdl_trampoline_page_end
.private_extern _pdl_trampoline_entry

.macro PDL_TRAMPOLINE_STUB
.align 3
    adr x9, -PAGE_MAX_SIZE
    b   _pdl_trampoline_page_begin + 4
.endmacro

.macro PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB

    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB

    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB

    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB
.endmacro

.macro PDL_TRAMPOLINE_STUB_256
    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16

    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16

    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16

    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16
.endmacro

.align PAGE_MAX_SHIFT

_pdl_trampoline_page_begin:
    nop
    ldr     x9, [x9]
    ldr     x10, [x9]
    br     x10

.align 3
_pdl_trampoline_page_stubs:
    // 2046
    PDL_TRAMPOLINE_STUB_256
    PDL_TRAMPOLINE_STUB_256
    PDL_TRAMPOLINE_STUB_256
    PDL_TRAMPOLINE_STUB_256

    PDL_TRAMPOLINE_STUB_256
    PDL_TRAMPOLINE_STUB_256
    PDL_TRAMPOLINE_STUB_256

    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16

    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16

    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16

    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16
    PDL_TRAMPOLINE_STUB_16

    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB

    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB

    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB

    PDL_TRAMPOLINE_STUB
    PDL_TRAMPOLINE_STUB

_pdl_trampoline_page_end:

.align PAGE_MAX_SHIFT

_pdl_trampoline_entry:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    mov     x1, lr
    mov     x0, x9
    bl      _pdl_trampoline_before
    mov     x9, x0
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
#ifdef __arm64e__
    blraaz  x9
#else
    blr     x9
#endif
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    bl      _pdl_trampoline_after
    mov     x9, x0
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    mov     lr, x9
    ret

#endif
