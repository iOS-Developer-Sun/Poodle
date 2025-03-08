//
//  pdl_asm-arm.h
//  Poodle
//
//  Created by Poodle on 2019/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifdef __ASSEMBLER__

#ifdef __arm__

#define NORMAL 0
#define STRET 1

// PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL|STRET
.macro PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    push.w {r0, r1, r2, r3, r7, lr}
    sub    sp, #0x8
.if $0 == NORMAL
.else
    mov     r0, r1
    mov     r1, r2
.endif

.endmacro

.macro PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    add    sp, #0x8
    pop.w  {r0, r1, r2, r3, r7, lr}
.endmacro

#endif

#endif
