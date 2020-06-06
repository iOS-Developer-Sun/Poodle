//
//  pdl_thread-arm.s
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#include "pdl_thread_define.h"

#ifdef __arm__

// void *pdl_thread_fake(void **frames, void *(*start)(void *), void *arg);

.text
.align 4
.private_extern _pdl_thread_fake

_pdl_thread_fake:

push    {r4, r7, lr}        // new space and backup caller registers

mov     r4, r7              // store fp
mov     r7, r0              // fake frames

mov     r0, r2              // set arg
blx     r1                 // start(arg)

mov     r7, r4              // recover fp

pop     {r4, r7, pc}        // restore caller registers and delete space

#endif
