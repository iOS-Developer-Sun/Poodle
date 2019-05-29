//
//  pdl_systemcall-x86_64.s
//  Poodle
//
//  Created by Poodle on 2019/5/10.
//
//

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
