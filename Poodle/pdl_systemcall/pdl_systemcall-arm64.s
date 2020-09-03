//
//  pdl_systemcall-arm64.s
//  Poodle
//
//  Created by Poodle on 2019/5/10.
//  Copyright © 2019 Poodle. All rights reserved.
//

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
