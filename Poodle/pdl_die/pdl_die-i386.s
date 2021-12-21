//
//  pdl_die-i386.s
//  Poodle
//
//  Created by Poodle on 2019/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifdef __i386__

.text
.align 4
.globl _pdl_die

_pdl_die:

    movl    0x4(%esp), %eax
    movl    $0, %esp
    movl    $0, %ebp
    jmp     *%eax

#endif
