//
//  pdl_thread-arm64.s
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#ifdef __arm64__

// void *pdl_thread_fake(void **frames, void *(*start)(void *), void *arg);

.text
.align 4
.private_extern _pdl_thread_fake

_pdl_thread_fake:

sub     sp, sp, #0x20           // new space
stp     x19, x20, [sp, #0x10]   // backup caller registers
mov     x19, fp                 // store fp
mov     x20, lr                 // store lr
mov     fp, x0                  // fake frames

mov     x0, x2                  // set arg
blr     x1                      // start(arg)

mov     fp, x19                 // recover fp
mov     lr, x20                 // recover lr

ldp     x19, x20, [sp, #0x10]   // restore caller registers
add     sp, sp, #0x20           // delete space
ret

#endif
