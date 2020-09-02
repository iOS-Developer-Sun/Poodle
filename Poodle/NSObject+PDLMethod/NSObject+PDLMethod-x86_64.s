//
//  NSObject+PDLMethod-x86_64.s
//  Poodle
//
//  Created by Poodle on 2020/7/15.
//  Copyright © 2020 Poodle. All rights reserved.
//

#include "pdl_asm-universal.h"

#ifdef __x86_64__

.text
.align 4
.private_extern _PDLMethodEntry
.private_extern _PDLMethodEntry_stret
.private_extern _PDLMethodEntryFull
.private_extern _PDLMethodEntryFull_stret

_PDLMethodEntry:

    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    call    _PDLMethodBefore
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE

    movq    0x10(%rsi), %rax
    movq    (%rsi), %rsi
    jmp     *%rax

_PDLMethodEntry_stret:

    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    call    _PDLMethodBefore
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE

    movq    0x10(%rdx), %rax
    movq    (%rdx), %rdx
    jmp     *%rax

_PDLMethodEntryFull:

    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    movq    0x8(%rbp), %rdx     // save lr
    call    _PDLMethodFullBefore
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE

    popq    %rax    // fake sp begin

    movq    0x10(%rsi), %rax    // fetch imp
    movq    (%rsi), %rsi    //  switch arg

    call    *%rax   // call imp

    pushq   %rax    // save ret

    call    _PDLMethodFullAfter
    movq    %rax, %r11  // save lr to r11
    popq    %rax        // load ret

    movq    %r11, 0x8(%rsp)    // restore lr
    popq    %r11    // fake sp end

    ret

_PDLMethodEntryFull_stret:

    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    movq    0x8(%rbp), %rdx
    call    _PDLMethodFullBefore
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE

    movq    0x10(%rdx), %rax
    movq    (%rdx), %rdx
    call    *%rax

    pushq   %rax
    call    _PDLMethodFullAfter
    popq   %rax

    ret

#endif
