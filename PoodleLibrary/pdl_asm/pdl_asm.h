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


#ifndef PDL_ASM_PERFORM

#define PDL_ASM_PERFORM(instruction) __asm__ volatile (instruction)

#define PDL_ASM_PERFORM_2(instruction) \
PDL_ASM_PERFORM(instruction);\
PDL_ASM_PERFORM(instruction)

#define PDL_ASM_PERFORM_4(instruction) \
PDL_ASM_PERFORM_2(instruction);\
PDL_ASM_PERFORM_2(instruction)

#define PDL_ASM_PERFORM_8(instruction) \
PDL_ASM_PERFORM_4(instruction);\
PDL_ASM_PERFORM_4(instruction)

#define PDL_ASM_PERFORM_16(instruction) \
PDL_ASM_PERFORM_8(instruction);\
PDL_ASM_PERFORM_8(instruction)

#define PDL_ASM_PERFORM_32(instruction) \
PDL_ASM_PERFORM_16(instruction);\
PDL_ASM_PERFORM_16(instruction)

#define PDL_ASM_PERFORM_64(instruction) \
PDL_ASM_PERFORM_32(instruction);\
PDL_ASM_PERFORM_32(instruction)

#define PDL_ASM_PERFORM_128(instruction) \
PDL_ASM_PERFORM_64(instruction);\
PDL_ASM_PERFORM_64(instruction)

#define PDL_ASM_PERFORM_256(instruction) \
PDL_ASM_PERFORM_128(instruction);\
PDL_ASM_PERFORM_128(instruction)

#define PDL_ASM_PERFORM_512(instruction) \
PDL_ASM_PERFORM_256(instruction);\
PDL_ASM_PERFORM_256(instruction)

#define PDL_ASM_PERFORM_1024(instruction) \
PDL_ASM_PERFORM_512(instruction);\
PDL_ASM_PERFORM_512(instruction)

#define PDL_ASM_PERFORM_2048(instruction) \
PDL_ASM_PERFORM_1024(instruction);\
PDL_ASM_PERFORM_1024(instruction)

#define PDL_ASM_PERFORM_4096(instruction) \
PDL_ASM_PERFORM_2048(instruction);\
PDL_ASM_PERFORM_2048(instruction)

#define PDL_ASM_PERFORM_8192(instruction) \
PDL_ASM_PERFORM_4096(instruction);\
PDL_ASM_PERFORM_4096(instruction)

#define PDL_ASM_PERFORM_16384(instruction) \
PDL_ASM_PERFORM_8192(instruction);\
PDL_ASM_PERFORM_8192(instruction)

#define PDL_ASM_PERFORM_32768(instruction) \
PDL_ASM_PERFORM_16384(instruction);\
PDL_ASM_PERFORM_16384(instruction)

#define PDL_ASM_PERFORM_65536(instruction) \
PDL_ASM_PERFORM_32768(instruction);\
PDL_ASM_PERFORM_32768(instruction)

#endif
