//
//  pdl_asm-arm64.h
//  Poodle
//
//  Created by Poodle on 2019/5/15.
//
//

#ifdef __arm64__

.macro PDL_ASM_OBJC_MESSAGE_STATE_SAVE
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
.endmacro

.macro PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
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
.endmacro

#endif
