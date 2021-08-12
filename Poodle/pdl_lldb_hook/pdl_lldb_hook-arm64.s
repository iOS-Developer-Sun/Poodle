//
//  pdl_lldb_hook-arm64.s
//  Poodle
//
//  Created by Poodle on 2019/12/19.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifdef __arm64__

#include <mach/vm_param.h>

.text

.private_extern _pdl_lldb_hook_page_begin
.private_extern _pdl_lldb_hook_page_end
.private_extern _pdl_lldb_hook_current_entry

.align PAGE_MAX_SHIFT

.macro PDL_LLDB_HOOK_ENTRY
    adr x9, -PAGE_MAX_SIZE
    fmov d31, x9
    ldr x9, [x9]
    br x9
    nop
    nop
    nop
    adr x9, -PAGE_MAX_SIZE
    ldr x9, [x9]
    br x9
.endmacro

.macro PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY

    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY

    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY

    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY
.endmacro

.macro PDL_LLDB_HOOK_ENTRY_256
    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16

    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16

    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16

    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16
.endmacro

_pdl_lldb_hook_page_begin:
    PDL_LLDB_HOOK_ENTRY_256

    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16

    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16
    PDL_LLDB_HOOK_ENTRY_16

    PDL_LLDB_HOOK_ENTRY_16

    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY

    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY
    PDL_LLDB_HOOK_ENTRY

    PDL_LLDB_HOOK_ENTRY

_pdl_lldb_hook_page_end:
//  nop
//  nop
//  nop
//  nop
//  nop
//  nop

_pdl_lldb_hook_current_entry:
    fmov x0, d31
    ret

#endif
