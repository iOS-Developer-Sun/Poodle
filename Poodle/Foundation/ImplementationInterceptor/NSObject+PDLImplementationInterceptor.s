//
//  NSObject+PDLImplementationInterceptor.s
//
//  Created by Sun on 2017/11/4.
//  Copyright © 2017 Poodle. All rights reserved.
//

#ifdef __i386__

.text
.align 4
.private_extern _PDLImplementationInterceptorEntry
.private_extern _PDLImplementationInterceptorEntry_stret

_PDLImplementationInterceptorEntry:

// arg0 0x4(%esp)
// arg1 0x8(%esp)
// arg2 0xc(%esp)
// arg3 0x10(%esp)
// ...
// ret %eax

movl    0x4(%esp), %eax     // load arg0(block) to eax
movl    0x8(%esp), %ecx     // load arg1(self) to ecx
movl    0x14(%eax), %edx    // load block->interceptorImplementation to edx
addl    $0x18, %eax         // set eax from block to &(block->method)
movl    %ecx, 0x4(%esp)     // save self to arg0
movl    %eax, 0x8(%esp)     // save &(block->method) to arg1
jmp     *%edx               // call block->interceptorImplementation

_PDLImplementationInterceptorEntry_stret:

// arg0 0x8(%esp)
// arg1 0xc(%esp)
// arg2 0x10(%esp)
// arg3 0x14(%esp)
// ...
// ret %eax / %eax %edx / %esp (+) ...

movl    0x8(%esp), %eax     // load arg0(block) to eax
movl    0xc(%esp), %ecx     // load arg1(self) to ecx
movl    0x14(%eax), %edx    // load block->interceptorImplementation to edx
addl    $0x18, %eax         // set eax from block to &(block->method)
movl    %ecx, 0x8(%esp)     // save self to arg0
movl    %eax, 0xc(%esp)     // save &(block->method) to arg1
jmp     *%edx               // call block->interceptorImplementation

#endif

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

#ifdef __arm__

.text
.align 4
.private_extern _PDLImplementationInterceptorEntry
.private_extern _PDLImplementationInterceptorEntry_stret

_PDLImplementationInterceptorEntry:

// arg0 r0
// arg1 r1
// arg2 r2
// arg3 r3
// arg4 [sp]
// arg5 [sp + 0x4]
// arg6 [sp + 0x8]
// ...
// ret r0

push    {r4, r5}            // backup registers
ldr     r4, [r0, #0x14]     // load block->interceptorImplementation to r4
add     r5, r0, #0x18       // set r5 &(block->method)
mov     r0, r1              // move arg1(self) to arg0
mov     r1, r5              // move &(block->method) to arg1
mov     ip, r4              // move block->interceptorImplementation to ip
pop     {r4, r5}            // restore registers
bx      ip                  // call block->interceptorImplementation

_PDLImplementationInterceptorEntry_stret:

// arg0 r1
// arg1 r2
// arg2 r3
// arg3 [sp]
// arg4 [sp + 0x4]
// arg5 [sp + 0x8]
// ...
// ret [r0] (+) ...

push    {r4, r5}            // backup registers
ldr     r4, [r1, #0x14]     // load block->interceptorImplementation to r4
add     r5, r1, #0x18       // set r5 &(block->method)
mov     r1, r2              // move arg1(self) to arg0
mov     r2, r5              // move &(block->method) to arg1
mov     ip, r4              // move block->interceptorImplementation to ip
pop     {r4, r5}            // restore registers
bx      ip                  // call block->interceptorImplementation

#endif

#ifdef __arm64__

.text
.align 4
.private_extern _PDLImplementationInterceptorEntry
.private_extern _PDLImplementationInterceptorEntry_stret

_PDLImplementationInterceptorEntry:

// arg0 x0
// arg1 x1
// arg2 x2
// arg3 x3
// arg4 x4
// arg5 x5
// arg6 x6
// arg7 x7
// arg8     [sp]
// arg9     [sp + 0x8]
// arg10    [sp + 0x10]
// ...
// ret x0

ldr     x9, [x0, #0x20]     // load block->interceptorImplementation to x9
add     x10, x0, #0x28      // set x10 &(block->method)
mov     x0, x1              // move arg1(self) to arg0
mov     x1, x10             // move &(block->method) to arg1
br      x9                  // call block->interceptorImplementation

_PDLImplementationInterceptorEntry_stret:

b _PDLImplementationInterceptorEntry   // call PDLImplementationInterceptorEntry

#endif
