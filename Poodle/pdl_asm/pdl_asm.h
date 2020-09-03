//
//  pdl_asm.h
//  Poodle
//
//  Created by Poodle on 2019/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifndef PDL_ASM_NOP
#define PDL_ASM_NOP __asm__ volatile ("nop")
#endif

#ifndef PDL_ASM_GOTO
#if defined(__i386__) || defined(__x86_64__)
#define PDL_ASM_GOTO(function) __asm__ volatile ("jmp _" #function)
#elif defined(__arm__) || defined(__arm64__)
#define PDL_ASM_GOTO(function) __asm__ volatile ("b _" #function)
#else
#error
#endif
#endif
