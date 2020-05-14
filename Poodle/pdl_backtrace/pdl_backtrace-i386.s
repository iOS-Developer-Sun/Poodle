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

pushq   %rbp                // store fp
movq    %rsi, %rbp          // fake frames
callq   _pdl_backtrace_wait // wait pdl_backtrace_wait(bt);
popq    %rbp                // recover frames
retq

#endif
