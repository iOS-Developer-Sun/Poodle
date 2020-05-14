//
//  pdl_backtrace-arm.s
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#ifdef __arm__

.text
.align 4
.private_extern _pdl_backtrace_fake

_pdl_backtrace_fake:

push    {r4, r7, lr}        // new space and backup caller registers

mov     r4, r7              // store fp
mov     r7, r1              // fake frames

bl      _pdl_backtrace_wait // wait pdl_backtrace_wait(bt);

mov     r7, r4              // recover frames

pop     {r4, r7, pc}        // restore caller registers and delete space

#endif
