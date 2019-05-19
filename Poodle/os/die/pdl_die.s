//
//  pdl_die.s
//  Poodle
//
//  Created by Poodle on 2019/5/15.
//
//

#ifdef __i386__

.text
.align 4
.private_extern _pdl_die

_pdl_die:

movl    0x4(%esp), %eax
movl    $0, %esp
movl    $0, %ebp
jmp     *%eax

#endif

#ifdef __x86_64__

.text
.align 4
.private_extern _pdl_die

_pdl_die:

movq    $0, %rbp
movq    $0, %rsp
jmp     *%rdi

#endif

#ifdef __arm__

.text
.align 4
.private_extern _pdl_die

_pdl_die:

mov    sp, #0
mov    lr, #0
bx     r0

#endif

#ifdef __arm64__

.text
.align 4
.private_extern _pdl_die

_pdl_die:

mov    fp, #0
mov    lr, #0
mov    x31, #0 // sp
br     x0

#endif
