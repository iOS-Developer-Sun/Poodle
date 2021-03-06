//
//  pdl_thread-i386.s
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#include "pdl_thread_define.h"

#ifdef __i386__

// void *pdl_thread_fake(void **frames, void *(*start)(void *), void *arg);

.text
.align 4
.private_extern _pdl_thread_fake

_pdl_thread_fake:

    pushl   %ebp                // store fp
    movl    0x8(%esp), %ebp     // fake frames
    subl    $0x8, %esp
    movl    0x18(%esp), %eax
    movl    %eax, (%esp)
    call   *0x14(%esp)
    addl    $0x8, %esp
    popl    %ebp
    retl
    nop

#endif
