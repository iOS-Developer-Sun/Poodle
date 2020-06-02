//
//  pdl_thread-x86_64.s
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#ifdef __x86_64__

// void *pdl_thread_fake(void **frames, void *(*start)(void *), void *arg);

.text
.align 4
.private_extern _pdl_thread_fake

_pdl_thread_fake:

pushq   %rbp                // store fp
movq    %rdi, %rbp          // fake frames
movq    %rdx, %rdi          // set arg
callq   *%rsi               // start(arg)
popq    %rbp                // recover fp
retq

#endif
