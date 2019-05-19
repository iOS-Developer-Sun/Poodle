//
//  pdl_systemcall.s
//  Poodle
//
//  Created by Poodle on 2019/5/10.
//
//

#ifdef __i386__

.text
.align 4
.private_extern _pdl_systemcall

_pdl_systemcall:

popl   %ecx
popl   %eax
pushl  %ecx
int    $0x80
movl   (%esp), %edx
pushl  %ecx
jae    LReturn
calll  L1
L1:
popl   %edx
jmp    tramp_cerror
LReturn:
retl

#endif

#ifdef __x86_64__

.text
.align 4
.private_extern _pdl_systemcall

_pdl_systemcall:

movl   $0x2000000, %eax
movq   %rcx, %r10
syscall
jae    LReturn
movq   %rax, %rdi
jmp    _cerror
LReturn:
retq

#endif

#ifdef __arm__

.text
.align 4
.private_extern _pdl_systemcall

_pdl_systemcall:

mov    r12, sp
push   {r4, r5, r6, r8}
ldm    r12, {r4, r5, r6}
mov    r12, #0
svc    #0x80
pop    {r4, r5, r6, r8}
blo    LReturn
b     _pdl_systemcall_cerror
LReturn:
bx     lr

#endif

#ifdef __arm64__

.text
.align 4
.private_extern _pdl_systemcall

_pdl_systemcall:

ldp    x1, x2, [sp]
ldp    x3, x4, [sp, #0x10]
ldp    x5, x6, [sp, #0x20]
ldr    x7, [sp, #0x30]
mov    x16, #0x0
svc    #0x80
b.lo   LReturn
stp    x29, x30, [sp, #-0x10]!
mov    x29, sp
bl     _pdl_systemcall_cerror
mov    sp, x29
ldp    x29, x30, [sp], #0x10
LReturn:
ret

#endif
