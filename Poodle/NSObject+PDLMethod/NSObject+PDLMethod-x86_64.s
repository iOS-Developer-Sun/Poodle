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
    test    %rax, %rax
    je      L_PDLMethodEntrySuper
    movq    (%rsi), %rsi
    jmp     *%rax
L_PDLMethodEntrySuper:
    movq    0x20(%rsi), %rax
    addq    $0x20, %rax
    movq    %rdi, (%rax)
    movq    0x18(%rsi), %r10
    movq    %r10, 0x8(%rax)
    movq    (%rsi), %rsi
    movq    %rax, %rdi
    jmp     _objc_msgSendSuper2


_PDLMethodEntry_stret:

    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    call    _PDLMethodBefore
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE

    movq    0x10(%rdx), %rax
    test    %rax, %rax
    je      L_PDLMethodEntrySuper_stret
    movq    (%rdx), %rdx
    jmp     *%rax
L_PDLMethodEntrySuper_stret:
    movq    0x20(%rdx), %rax
    addq    $0x20, %rax
    movq    %rsi, (%rax)
    movq    0x18(%rdx), %r10
    movq    %r10, 0x8(%rax)
    movq    (%rdx), %rdx
    movq    %rax, %rsi
    jmp     _objc_msgSendSuper2_stret

_PDLMethodEntryFull:

    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    movq    0x8(%rbp), %rdx     // save lr
    call    _PDLMethodFullBefore
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE

    popq    %rax    // fake sp begin

    movq    0x10(%rsi), %rax    // fetch imp
    test    %rax, %rax
    je      L_PDLMethodEntryFullSuper

    movq    (%rsi), %rsi    //  switch arg
    call    *%rax   // call imp
    jmp     L_PDLMethodEntryFullAfter

L_PDLMethodEntryFullSuper:
    movq    0x20(%rsi), %rax
    addq    $0x20, %rax
    movq    %rdi, (%rax)
    movq    0x18(%rsi), %r10
    movq    %r10, 0x8(%rax)
    movq    (%rsi), %rsi
    movq    %rax, %rdi
    call    _objc_msgSendSuper2

L_PDLMethodEntryFullAfter:
    pushq   %rax    // save ret

    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    call    _PDLMethodFullAfter
    movq    %rax, %r11  // save lr to r11
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE

    popq    %rax        // load ret

    pushq    %r11    // restore lr, fake sp end

    ret

_PDLMethodEntryFull_stret:

    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    movq    0x8(%rbp), %rdx     // save lr
    call    _PDLMethodFullBefore
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE

    popq    %rax    // fake sp begin

    movq    0x10(%rdx), %rax    // fetch imp
    test    %rax, %rax
    je      L_PDLMethodEntryFullSuper_stret

    movq    (%rdx), %rdx    // switch arg
    call    *%rax   // call imp
    jmp     L_PDLMethodEntryFullAfter_stret

L_PDLMethodEntryFullSuper_stret:
    movq    0x20(%rdx), %rax
    addq    $0x20, %rax
    movq    %rsi, (%rax)
    movq    0x18(%rdx), %r10
    movq    %r10, 0x8(%rax)
    movq    (%rdx), %rdx
    movq    %rax, %rsi
    call    _objc_msgSendSuper2_stret

L_PDLMethodEntryFullAfter_stret:
    pushq   %rax    // save ret

    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    call    _PDLMethodFullAfter
    movq    %rax, %r11  // save lr to r11
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE

    popq    %rax        // load ret

    pushq    %r11    // restore lr, fake sp end

    ret

#endif
