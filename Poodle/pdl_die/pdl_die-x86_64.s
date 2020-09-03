//
//  pdl_die-x86_64.s
//  Poodle
//
//  Created by Poodle on 2019/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifdef __x86_64__

.text
.align 4
.private_extern _pdl_die

_pdl_die:

    movq    $0, %rbp
    movq    $0, %rsp
    jmp     *%rdi

#endif
