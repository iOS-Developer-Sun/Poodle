//
//  NSObject+PDLImplementationInterceptor-arm64.s
//  Poodle
//
//  Created by Poodle on 2017/11/4.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifdef __arm64__

.text
.align 4
.private_extern _PDLImplementationInterceptorEntry
.private_extern _PDLImplementationInterceptorEntry_stret

_PDLImplementationInterceptorEntry:

    ldr     x9, [x0, #0x20]     // load block->interceptorImplementation to x9
    add     x10, x0, #0x28      // set x10 &(block->method)
    mov     x0, x1              // move arg1(self) to arg0
    mov     x1, x10             // move &(block->method) to arg1
    br      x9                  // call block->interceptorImplementation

_PDLImplementationInterceptorEntry_stret:

    b _PDLImplementationInterceptorEntry   // call PDLImplementationInterceptorEntry

#endif
