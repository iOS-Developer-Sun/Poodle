//
//  pdl_die-arm.s
//  Poodle
//
//  Created by Poodle on 2019/5/15.
//
//

#ifdef __arm__

.text
.align 4
.private_extern _pdl_die

_pdl_die:

mov    sp, #0
mov    lr, #0
bx     r0

#endif
