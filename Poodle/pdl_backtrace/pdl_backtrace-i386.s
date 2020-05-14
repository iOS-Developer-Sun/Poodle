//
//  pdl_backtrace-i386.s
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#ifdef __i386__

.text
.align 4
.private_extern _pdl_backtrace_fake

_pdl_backtrace_fake:

pushl   %ebp                // store fp
movl    0xc(%esp), %ebp     // fake frames
pushl   %ebp                // align %esp = %esp - (16 - ((argc & 3) << 2))
pushl   0xc(%esp)           // push bt
movl    %eax, (%esp)
calll   _pdl_backtrace_wait // wait pdl_backtrace_wait(bt);
popl    %ebp
popl    %ebp                // restore bt
popl    %ebp                // recover frames
retl

#endif
