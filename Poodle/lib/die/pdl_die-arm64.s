//
//  pdl_die-arm64.s
//  Poodle
//
//  Created by Poodle on 2019/5/15.
//
//

#ifdef __arm64__

.text
.align 4
.private_extern _pdl_die

_pdl_die:

mov    fp, #0
mov    lr, #0
mov    x31, #0 // sp
br     x0

#endif
