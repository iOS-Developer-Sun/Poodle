//
//  pdl_backtrace-arm64.s
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#ifdef __arm64__

.text
.align 4
.private_extern _pdl_backtrace_fake

_pdl_backtrace_fake:

sub     sp, sp, #0x20           // new space
stp     x19, x20, [sp, #0x10]   // backup caller registers
mov     x19, fp                 // store fp
mov     x20, lr                 // store lr
mov     fp, x1                  // fake frames

bl      _pdl_backtrace_wait     // wait pdl_backtrace_wait(bt);

mov     fp, x19                 // recover fp
mov     lr, x20                 // recover lr

ldp     x19, x20, [sp, #0x10]   // restore caller registers
add     sp, sp, #0x20           // delete space
ret

#endif
