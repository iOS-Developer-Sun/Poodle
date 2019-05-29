//
//  pdl_systemcall-i386.s
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
