//
//  pdl_die-arm64.s
//  Poodle
//
//  Created by Poodle on 2019/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifdef __arm64__

.text
.align 4
.globl _pdl_die

_pdl_die:

    mov    lr, #0
    mov    fp, #0
    mov    sp, fp
    mov    x1, #0
    mov    x2, #0
    mov    x3, #0
    mov    x4, #0
    mov    x5, #0
    mov    x6, #0
    mov    x7, #0
    mov    x8, #0
    mov    x9, #0
    mov    x10, #0
    mov    x11, #0
    mov    x12, #0
    mov    x13, #0
    mov    x14, #0
    mov    x15, #0
    mov    x16, #0
    mov    x17, #0
    mov    x18, #0
    mov    x19, #0
    mov    x20, #0
    mov    x21, #0
    mov    x22, #0
    mov    x23, #0
    mov    x24, #0
    mov    x25, #0
    mov    x26, #0
    mov    x27, #0
    mov    x28, #0
    movi    d0, #0
    movi    d1, #0
    movi    d2, #0
    movi    d3, #0
    movi    d4, #0
    movi    d5, #0
    movi    d6, #0
    movi    d7, #0
    movi    d8, #0
    movi    d9, #0
    movi    d10, #0
    movi    d11, #0
    movi    d12, #0
    movi    d13, #0
    movi    d14, #0
    movi    d15, #0
    movi    d16, #0
    movi    d17, #0
    movi    d18, #0
    movi    d19, #0
    movi    d20, #0
    movi    d21, #0
    movi    d22, #0
    movi    d23, #0
    movi    d24, #0
    movi    d25, #0
    movi    d26, #0
    movi    d27, #0
    movi    d28, #0
    movi    d29, #0
    movi    d30, #0
    movi    d31, #0
    br     x0

#endif
