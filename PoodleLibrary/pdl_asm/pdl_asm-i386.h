//
//  pdl_asm-i386.h
//  Poodle
//
//  Created by Poodle on 2019/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifdef __ASSEMBLER__

#ifdef __i386__

#define NORMAL 0
#define STRET 1

// PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL|STRET
.macro PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    pushl    %ebp
    movl    %esp, %ebp
    subl    $(8+5*16), %esp
.if $0 == NORMAL
    movl    8(%ebp), %eax
    movl    12(%ebp), %ecx
.else
    movl    12(%ebp), %eax
    movl    16(%ebp), %ecx
.endif
    movdqa  %xmm3, 4*16(%esp)
    movdqa  %xmm2, 3*16(%esp)
    movdqa  %xmm1, 2*16(%esp)
    movdqa  %xmm0, 1*16(%esp)
    movl    %ecx, 4(%esp)
    movl    %eax, 0(%esp)
.endmacro

.macro PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    movdqa  4*16(%esp), %xmm3
    movdqa  3*16(%esp), %xmm2
    movdqa  2*16(%esp), %xmm1
    movdqa  1*16(%esp), %xmm0
    leave
.endmacro

#endif

#endif
