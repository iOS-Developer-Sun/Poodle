//
//  NSObject+PDLImplementationInterceptor-x86_64.s
//
//  Created by Sun on 2017/11/4.
//  Copyright © 2017 Poodle. All rights reserved.
//

#ifdef __x86_64__

.text
.align 4
.private_extern _PDLImplementationInterceptorEntry
.private_extern _PDLImplementationInterceptorEntry_stret

_PDLImplementationInterceptorEntry:

// arg0 %rdi
// arg1 %rsi
// arg2 %rdx
// arg3 %rcx
// arg4 %r8
// arg5 %r9
// arg6 0x8(%esp)
// arg7 0x10(%esp)
// ...
// ret  %rax

pushq   %rbx                // backup register
movq    0x20(%rdi), %rax    // load block->interceptorImplementation to rax
movq    %rdi, %rbx          // set block to rbx
addq    $0x28, %rbx         // set rbx from block to &(block->method)
movq    %rsi, %rdi          // move arg1(self) to arg0
movq    %rbx, %rsi          // move &(block->method) to arg1
popq    %rbx                // restore registers
jmp     *%rax               // call block->interceptorImplementation

_PDLImplementationInterceptorEntry_stret:

// arg0 %rsi
// arg1 %rdx
// arg2 %rcx
// arg3 %r8
// arg4 %r9
// arg5 0x8(%esp)
// arg6 0x10(%esp)
// ...
// ret  %rax / %rax %rdx / %rsp (+) ...

pushq   %rbx                // backup register
movq    0x20(%rsi), %rax    // load block->interceptorImplementation to rax
movq    %rsi, %rbx          // set block to rbx
addq    $0x28, %rbx         // set rbx from block to &(block->method)
movq    %rdx, %rsi          // move arg1(self) to arg0
movq    %rbx, %rdx          // move &(block->method) to arg1
popq    %rbx                // restore register
jmp     *%rax               // call block->interceptorImplementation

#endif
