//
//  NSObject+PDLImplementationInterceptor-arm.s
//  Poodle
//
//  Created by Poodle on 2017/11/4.
//  Copyright © 2019 Poodle. All rights reserved.
//

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
