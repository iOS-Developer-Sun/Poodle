//
//  NSObject+PDLImplementationInterceptor-arm64.s
//
//  Created by Sun on 2017/11/4.
//  Copyright © 2017 Poodle. All rights reserved.
//

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
