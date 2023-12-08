//
//  pdl_trampoline-x86_64.s
//  Poodle
//
//  Created by Poodle on 11-8-23.
//  Copyright © 2021 Poodle. All rights reserved.
//

#include "pdl_asm-universal.h"

#ifdef __x86_64__

#include <mach/vm_param.h>

.text

.private_extern _pdl_trampoline_page_begin
.private_extern _pdl_trampoline_page_stubs
.private_extern _pdl_trampoline_page_end
.private_extern _pdl_trampoline_entry

.macro PDL_TRAMPOLINE_STUB
.align 3
    callq _pdl_trampoline_page_begin + 1 // 5 bytes
    jmp *(%r11) // 3 bytes
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
    movq    (%rsp), %r11
    addq    $-PAGE_MAX_SIZE - 5, %r11
    movq    (%r11), %r11
    ret

.align 4
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
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    movq    %rsp, %rdx
    movq    0x8(%rbp), %rsi
    movq    %r11, %rdi
    call    _pdl_trampoline_before
    movq    %rax, %r11
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE NORMAL
    popq    %r10
    call     *%r11
    pushq   %rax
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    movq    %rsp, %rdi
    call    _pdl_trampoline_after
    mov     %rax, %r11
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE NORMAL
    popq    %rax
    pushq   %r11
    ret

#endif
