//
//  pdl_die-arm.s
//  Poodle
//
//  Created by Poodle on 2019/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifdef __arm__

.text
.align 4
.private_extern _pdl_die

_pdl_die:

    mov    sp, #0
    mov    lr, #0
    mov    r12, #0
    mov    r1, #0
    mov    r2, #0
    mov    r3, #0
    mov    r4, #0
    mov    r5, #0
    mov    r6, #0
    mov    r7, #0
    mov    r8, #0
    mov    r9, #0
    mov    r10, #0
    mov    r11, #0
    vmov.i64 d0, #0
    vmov.i64 d1, #0
    vmov.i64 d2, #0
    vmov.i64 d3, #0
    vmov.i64 d4, #0
    vmov.i64 d5, #0
    vmov.i64 d6, #0
    vmov.i64 d7, #0
    vmov.i64 d8, #0
    vmov.i64 d9, #0
    vmov.i64 d10, #0
    vmov.i64 d11, #0
    vmov.i64 d12, #0
    vmov.i64 d13, #0
    vmov.i64 d14, #0
    vmov.i64 d15, #0
    vmov.i64 d16, #0
    vmov.i64 d16, #0
    vmov.i64 d17, #0
    vmov.i64 d18, #0
    vmov.i64 d19, #0
    vmov.i64 d20, #0
    vmov.i64 d21, #0
    vmov.i64 d22, #0
    vmov.i64 d23, #0
    vmov.i64 d24, #0
    vmov.i64 d25, #0
    vmov.i64 d26, #0
    vmov.i64 d27, #0
    vmov.i64 d28, #0
    vmov.i64 d29, #0
    vmov.i64 d30, #0
    vmov.i64 d31, #0
    bx     r0

#endif
