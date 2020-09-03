//
//  NSObject+PDLImplementationInterceptor-x86_64.s
//  Poodle
//
//  Created by Poodle on 2017/11/4.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifdef __x86_64__

.text
.align 4
.private_extern _PDLImplementationInterceptorEntry
.private_extern _PDLImplementationInterceptorEntry_stret

_PDLImplementationInterceptorEntry:

    pushq   %rbx                // backup register
    movq    0x20(%rdi), %rax    // load block->interceptorImplementation to rax
    movq    %rdi, %rbx          // set block to rbx
    addq    $0x28, %rbx         // set rbx from block to &(block->method)
    movq    %rsi, %rdi          // move arg1(self) to arg0
    movq    %rbx, %rsi          // move &(block->method) to arg1
    popq    %rbx                // restore registers
    jmp     *%rax               // call block->interceptorImplementation

_PDLImplementationInterceptorEntry_stret:

    pushq   %rbx                // backup register
    movq    0x20(%rsi), %rax    // load block->interceptorImplementation to rax
    movq    %rsi, %rbx          // set block to rbx
    addq    $0x28, %rbx         // set rbx from block to &(block->method)
    movq    %rdx, %rsi          // move arg1(self) to arg0
    movq    %rbx, %rdx          // move &(block->method) to arg1
    popq    %rbx                // restore register
    jmp     *%rax               // call block->interceptorImplementation

#endif
