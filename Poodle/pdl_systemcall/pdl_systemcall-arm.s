//
//  pdl_systemcall-arm.s
//  Poodle
//
//  Created by Poodle on 2019/5/10.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifdef __arm__

.text
.align 4
.globl _pdl_systemcall

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
