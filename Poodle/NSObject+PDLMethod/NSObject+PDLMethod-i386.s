//
//  NSObject+PDLMethod-i386.s
//  Poodle
//
//  Created by Poodle on 2020/7/15.
//  Copyright © 2020 Poodle. All rights reserved.
//

#include "pdl_asm-universal.h"

#ifdef __i386__

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
    movl    0x8(%esp), %ecx
    movl    0x8(%ecx), %eax
    movl    (%ecx), %ecx
    movl    %ecx, 0x8(%esp)
    jmp     *%eax

_PDLMethodEntry_stret:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    call    _PDLMethodBefore
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    movl    0xc(%esp), %ecx
    movl    0x8(%ecx), %eax
    movl    (%ecx), %ecx
    movl    %ecx, 0xc(%esp)
    jmp     *%eax

_PDLMethodEntryFull:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    movl    0x4(%ebp), %eax     // save lr
    movl    %eax, 0x8(%esp)
    call    _PDLMethodFullBefore
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    movl    %esp, %ebx
    popl    %eax    // fake sp begin
    movl    0x8(%ebx), %ecx // load arg2 to ecx
    movl    0x8(%ecx), %eax // fetch imp
    movl    (%ecx), %ecx    // switch arg
    movl    %ecx, 0x8(%ebx)
    call    *%eax  // call imp
    push    %eax    // save ret
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    call    _PDLMethodFullAfter
    movl    %eax, %ebx  // save lr to ebx
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    pop     %eax        // load ret
    push    %ebx       // restore lr, fake sp end
    ret

_PDLMethodEntryFull_stret:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    movl    0x4(%ebp), %eax     // save lr
    movl    %eax, 0x8(%esp)
    call    _PDLMethodFullBefore
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    movl    %esp, %ebx
    popl    %eax    // fake sp begin
    movl    0xc(%ebx), %ecx // load arg2 to ecx
    movl    0x8(%ecx), %eax // fetch imp
    movl    (%ecx), %ecx    // switch arg
    movl    %ecx, 0xc(%ebx)
    call    *%eax  // call imp
    push    %eax    // save ret
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    call    _PDLMethodFullAfter
    movl    %eax, %ebx  // save lr to ebx
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    pop     %eax        // load ret
    push    %ebx       // restore lr, fake sp end
    ret

#endif
