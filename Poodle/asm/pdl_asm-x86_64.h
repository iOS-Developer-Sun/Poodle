//
//  pdl_asm-x86_64.h
//  Poodle
//
//  Created by Poodle on 2019/5/15.
//
//

#ifdef __x86_64__

#define NORMAL 0
#define STRET 1

#define a1  rdi
#define a1d edi
#define a1b dil
#define a2  rsi
#define a2d esi
#define a2b sil
#define a3  rdx
#define a3d edx
#define a4  rcx
#define a4d ecx
#define a5  r8
#define a5d r8d
#define a6  r9
#define a6d r9d

// PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL|STRET
.macro PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    push    %rbp
    mov    %rsp, %rbp
    sub    $$0x80+8, %rsp
    movdqa    %xmm0, -0x80(%rbp)
    push    %rax
    movdqa    %xmm1, -0x70(%rbp)
    push    %a1
    movdqa    %xmm2, -0x60(%rbp)
    push    %a2
    movdqa    %xmm3, -0x50(%rbp)
    push    %a3
    movdqa    %xmm4, -0x40(%rbp)
    push    %a4
    movdqa    %xmm5, -0x30(%rbp)
    push    %a5
    movdqa    %xmm6, -0x20(%rbp)
    push    %a6
    movdqa    %xmm7, -0x10(%rbp)

.if $0 == NORMAL
.else
    movq    %a2, %a1
    movq    %a3, %a2
.endif

.endmacro

.macro PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    movdqa    -0x80(%rbp), %xmm0
    pop    %a6
    movdqa    -0x70(%rbp), %xmm1
    pop    %a5
    movdqa    -0x60(%rbp), %xmm2
    pop    %a4
    movdqa    -0x50(%rbp), %xmm3
    pop    %a3
    movdqa    -0x40(%rbp), %xmm4
    pop    %a2
    movdqa    -0x30(%rbp), %xmm5
    pop    %a1
    movdqa    -0x20(%rbp), %xmm6
    pop    %rax
    movdqa    -0x10(%rbp), %xmm7
    leave
.endmacro

#endif
