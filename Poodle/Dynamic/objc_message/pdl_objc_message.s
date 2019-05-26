//
//  pdl_objc_message.s
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//
//

#ifdef __i386__

.text
.align 4
.private_extern _NSObjectSelectorProxyEntry
.private_extern _NSObjectSelectorProxyEntry_stret

_NSObjectSelectorProxyEntry:

pushl    %ebp
movl    %esp, %ebp

subl    $(8+5*16), %esp

movl    8(%ebp), %eax
movl    12(%ebp), %ecx

movdqa  %xmm3, 4*16(%esp)
movdqa  %xmm2, 3*16(%esp)
movdqa  %xmm1, 2*16(%esp)
movdqa  %xmm0, 1*16(%esp)

movl    %ecx, 4(%esp)
movl    %eax, 0(%esp)
call    _NSObjectSelectorProxyForwarding

movdqa  4*16(%esp), %xmm3
movdqa  3*16(%esp), %xmm2
movdqa  2*16(%esp), %xmm1
movdqa  1*16(%esp), %xmm0

leave

jmp     *%eax

_NSObjectSelectorProxyEntry_stret:

pushl    %ebp
movl    %esp, %ebp

subl    $(8+5*16), %esp

movl    12(%ebp), %eax
movl    16(%ebp), %ecx

movdqa  %xmm3, 4*16(%esp)
movdqa  %xmm2, 3*16(%esp)
movdqa  %xmm1, 2*16(%esp)
movdqa  %xmm0, 1*16(%esp)

movl    %ecx, 4(%esp)
movl    %eax, 0(%esp)
call    _NSObjectSelectorProxyForwarding

movdqa  4*16(%esp), %xmm3
movdqa  3*16(%esp), %xmm2
movdqa  2*16(%esp), %xmm1
movdqa  1*16(%esp), %xmm0

leave

jmp     *%eax

#endif

#ifdef __x86_64__

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

.text
.align 4
.private_extern _pdl_objc_msgSend
.private_extern _pdl_objc_msgSend_stret

_pdl_objc_msgSend:

push    %rbp
mov    %rsp, %rbp

sub    $0x80+8, %rsp

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

call    _pdl_objc_msgSend_before

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

call _objc_msgSend
leave

push    %rbp
mov    %rsp, %rbp

sub    $0x80+8, %rsp

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

call    _pdl_objc_msgSend_after

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

_pdl_objc_msgSend_stret:

push    %rbp
mov    %rsp, %rbp

sub    $0x80+8, %rsp

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

movq    %a2, %a1
movq    %a3, %a2

call    _pdl_objc_msgSend_before

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

call    _objc_msgSend_stret
leave

push    %rbp
mov    %rsp, %rbp

sub    $0x80+8, %rsp

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

movq    %a2, %a1
movq    %a3, %a2

call    _pdl_objc_msgSend_after

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

#undef a1
#undef a1d
#undef a1b
#undef a2
#undef a2d
#undef a2b
#undef a3
#undef a3d
#undef a4
#undef a4d
#undef a5
#undef a5d
#undef a6
#undef a6d

#endif

#ifdef __arm__

.text
.align 4
.private_extern _NSObjectSelectorProxyEntry
.private_extern _NSObjectSelectorProxyEntry_stret

_NSObjectSelectorProxyEntry:

push.w {r0, r1, r2, r3, r7, lr}
sub    sp, #0x8
bl     _NSObjectSelectorProxyForwarding
mov    r12, r0
add    sp, #0x8
pop.w  {r0, r1, r2, r3, r7, lr}
bx     r12

_NSObjectSelectorProxyEntry_stret:

push.w {r0, r1, r2, r3, r7, lr}
sub    sp, #0x8
mov     r0, r1
mov     r1, r2
bl     _NSObjectSelectorProxyForwarding
mov    r12, r0
add    sp, #0x8
pop.w  {r0, r1, r2, r3, r7, lr}
bx     r12

#endif

#ifdef __arm64__

.text
.align 4
.private_extern _pdl_objc_msgSend
.private_extern _pdl_objc_msgSend_stret

_pdl_objc_msgSend:

stp    x29, x30, [sp, #-0x10]!
mov    x29, sp
sub    sp, sp, #0xd0
stp    q0, q1, [sp]
stp    q2, q3, [sp, #0x20]
stp    q4, q5, [sp, #0x40]
stp    q6, q7, [sp, #0x60]
stp    x0, x1, [sp, #0x80]
stp    x2, x3, [sp, #0x90]
stp    x4, x5, [sp, #0xa0]
stp    x6, x7, [sp, #0xb0]
str    x8, [sp, #0xc0]
bl     _pdl_objc_msgSend_before
ldp    q0, q1, [sp]
ldp    q2, q3, [sp, #0x20]
ldp    q4, q5, [sp, #0x40]
ldp    q6, q7, [sp, #0x60]
ldp    x0, x1, [sp, #0x80]
ldp    x2, x3, [sp, #0x90]
ldp    x4, x5, [sp, #0xa0]
ldp    x6, x7, [sp, #0xb0]
ldr    x8, [sp, #0xc0]
mov    sp, x29
ldp    x29, x30, [sp], #0x10

b     _objc_msgSend

stp    x29, x30, [sp, #-0x10]!
mov    x29, sp
sub    sp, sp, #0xd0
stp    q0, q1, [sp]
stp    q2, q3, [sp, #0x20]
stp    q4, q5, [sp, #0x40]
stp    q6, q7, [sp, #0x60]
stp    x0, x1, [sp, #0x80]
stp    x2, x3, [sp, #0x90]
stp    x4, x5, [sp, #0xa0]
stp    x6, x7, [sp, #0xb0]
str    x8, [sp, #0xc0]
bl     _pdl_objc_msgSend_after
ldp    q0, q1, [sp]
ldp    q2, q3, [sp, #0x20]
ldp    q4, q5, [sp, #0x40]
ldp    q6, q7, [sp, #0x60]
ldp    x0, x1, [sp, #0x80]
ldp    x2, x3, [sp, #0x90]
ldp    x4, x5, [sp, #0xa0]
ldp    x6, x7, [sp, #0xb0]
ldr    x8, [sp, #0xc0]
mov    sp, x29
ldp    x29, x30, [sp], #0x10
ret

_pdl_objc_msgSend_stret:

b _pdl_objc_msgSend

#endif
