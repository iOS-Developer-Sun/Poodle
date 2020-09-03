//
//  NSObject+PDLImplementationInterceptor-i386.s
//  Poodle
//
//  Created by Poodle on 2017/11/4.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifdef __i386__

.text
.align 4
.private_extern _PDLImplementationInterceptorEntry
.private_extern _PDLImplementationInterceptorEntry_stret

_PDLImplementationInterceptorEntry:

    movl    0x4(%esp), %eax     // load arg0(block) to eax
    movl    0x8(%esp), %ecx     // load arg1(self) to ecx
    movl    0x14(%eax), %edx    // load block->interceptorImplementation to edx
    addl    $0x18, %eax         // set eax from block to &(block->method)
    movl    %ecx, 0x4(%esp)     // save self to arg0
    movl    %eax, 0x8(%esp)     // save &(block->method) to arg1
    jmp     *%edx               // call block->interceptorImplementation

_PDLImplementationInterceptorEntry_stret:

    movl    0x8(%esp), %eax     // load arg0(block) to eax
    movl    0xc(%esp), %ecx     // load arg1(self) to ecx
    movl    0x14(%eax), %edx    // load block->interceptorImplementation to edx
    addl    $0x18, %eax         // set eax from block to &(block->method)
    movl    %ecx, 0x8(%esp)     // save self to arg0
    movl    %eax, 0xc(%esp)     // save &(block->method) to arg1
    jmp     *%edx               // call block->interceptorImplementation

#endif
