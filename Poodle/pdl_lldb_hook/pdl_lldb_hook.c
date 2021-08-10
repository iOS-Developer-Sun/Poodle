//
//  pdl_lldb_hook.c
//  Poodle
//
//  Created by Poodle on 2019/12/19.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include "pdl_lldb_hook.h"

#ifdef __arm64__

static const int branch_instructions_max_count = 3;
static const int bytes_per_instruction = 4;
static char lldb_command[1024] = {0};

#define PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry) \
static uintptr_t lldb_entry##_original_with_offset = 0;\
__attribute__((naked, aligned(4))) static void lldb_entry(void) {\
    __asm__ volatile (\
                      "nop\n"\
                      "nop\n"\
                      "nop\n"\
                      "adrp x9, _" #lldb_entry "_original_with_offset@PAGE\n"\
                      "ldr x9, [x9, _" #lldb_entry "_original_with_offset@PAGEOFF]\n"\
                      "br x9"\
                      );\
}

#pragma mark -

#define PDL_LLDB_HOOK_MAX_COUNT 32

PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_0)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_1)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_2)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_3)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_4)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_5)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_6)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_7)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_8)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_9)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_10)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_11)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_12)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_13)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_14)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_15)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_16)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_17)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_18)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_19)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_20)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_21)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_22)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_23)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_24)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_25)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_26)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_27)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_28)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_29)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_30)
PDL_LLDB_HOOK_ENTRY_DECL(lldb_entry_31)

static void(*lldb_entrys[PDL_LLDB_HOOK_MAX_COUNT])(void) = {
    &lldb_entry_0,
    &lldb_entry_1,
    &lldb_entry_2,
    &lldb_entry_3,
    &lldb_entry_4,
    &lldb_entry_5,
    &lldb_entry_6,
    &lldb_entry_7,
    &lldb_entry_8,
    &lldb_entry_9,
    &lldb_entry_10,
    &lldb_entry_11,
    &lldb_entry_12,
    &lldb_entry_13,
    &lldb_entry_14,
    &lldb_entry_15,
    &lldb_entry_16,
    &lldb_entry_17,
    &lldb_entry_18,
    &lldb_entry_19,
    &lldb_entry_20,
    &lldb_entry_21,
    &lldb_entry_22,
    &lldb_entry_23,
    &lldb_entry_24,
    &lldb_entry_25,
    &lldb_entry_26,
    &lldb_entry_27,
    &lldb_entry_28,
    &lldb_entry_29,
    &lldb_entry_30,
    &lldb_entry_31,
};

static uintptr_t *lldb_entry_original_with_offsets[PDL_LLDB_HOOK_MAX_COUNT] = {
    &lldb_entry_0_original_with_offset,
    &lldb_entry_1_original_with_offset,
    &lldb_entry_2_original_with_offset,
    &lldb_entry_3_original_with_offset,
    &lldb_entry_4_original_with_offset,
    &lldb_entry_5_original_with_offset,
    &lldb_entry_6_original_with_offset,
    &lldb_entry_7_original_with_offset,
    &lldb_entry_8_original_with_offset,
    &lldb_entry_9_original_with_offset,
    &lldb_entry_10_original_with_offset,
    &lldb_entry_11_original_with_offset,
    &lldb_entry_12_original_with_offset,
    &lldb_entry_13_original_with_offset,
    &lldb_entry_14_original_with_offset,
    &lldb_entry_15_original_with_offset,
    &lldb_entry_16_original_with_offset,
    &lldb_entry_17_original_with_offset,
    &lldb_entry_18_original_with_offset,
    &lldb_entry_19_original_with_offset,
    &lldb_entry_20_original_with_offset,
    &lldb_entry_21_original_with_offset,
    &lldb_entry_22_original_with_offset,
    &lldb_entry_23_original_with_offset,
    &lldb_entry_24_original_with_offset,
    &lldb_entry_25_original_with_offset,
    &lldb_entry_26_original_with_offset,
    &lldb_entry_27_original_with_offset,
    &lldb_entry_28_original_with_offset,
    &lldb_entry_29_original_with_offset,
    &lldb_entry_30_original_with_offset,
    &lldb_entry_31_original_with_offset,
};

#pragma mark -

// b:       0 0 0 1 0 1 imm26 (+/-128MB)
// adr:     0 immlo2 1 0 0 0 0 immhi19 Rd5 (+/-1MB)
// adrp:    1 immlo2 1 0 0 0 0 immhi19 Rd5 (+/-4GB)
// br:      1 1 0 1 0 1 1 0 0 0 0 1 1 1 1 1 0 0 0 0 0 0 Rn5 0 0 0 0 0

static int get_branch_instructions_count(uintptr_t from, uintptr_t to) {
    intptr_t diff = to - from;
    if ((diff < (1 << 27) && diff >= -(1 << 27)) && ((diff & ((1 << 2) - 1)) == 0)) {
        return 1;
    }

    if (diff < (1 << 20) && diff >= -(1 << 20)) {
        return 2;
    }

    uintptr_t to_page = to & ~((1 << 12) - 1);
    if (to_page == to) {
        return 2;
    }

    return 3;
}

static void generate_branch_instructions(uintptr_t from, uintptr_t to, unsigned int branch_to_custom_function[branch_instructions_max_count], int branch_instructions_count) {
    unsigned int reg = 9;

    intptr_t diff = to - from;
    if ((diff < (1 << 27) && diff >= -(1 << 27)) && ((diff & ((1 << 2) - 1)) == 0)) {
        unsigned int b = 0b00010100000000000000000000000000;
        unsigned int imm = (diff >> 2) & ((1 << 26) - 1);
        b |= imm;
        branch_to_custom_function[0] = b;
        return;
    }

    if (diff < (1 << 20) && diff >= -(1 << 20)) {
        unsigned int adr = 0b00010000000000000000000000000000;
        const int immloshift = 29;
        const int immhishift = 5;
        unsigned int immlo = diff & ((1 << 2) - 1);
        unsigned int immhi = ((diff & ~((1 << 2) - 1)) >> 2) & ((1 << 19) - 1);
        adr |= immlo << immloshift;
        adr |= immhi << immhishift;
        adr |= reg;
        branch_to_custom_function[0] = adr;
    } else {
        uintptr_t from_page = from & ~((1 << 12) - 1);
        uintptr_t to_page = to & ~((1 << 12) - 1);
        diff = ((intptr_t)(to_page - from_page)) >> 12;
        unsigned int adrp = 0b10010000000000000000000000000000;
        const int immloshift = 29;
        const int immhishift = 5;
        unsigned int immlo = diff & ((1 << 2) - 1);
        unsigned int immhi = ((diff & ~((1 << 2) - 1)) >> 2) & ((1 << 19) - 1);
        adrp |= immlo << immloshift;
        adrp |= immhi << immhishift;
        adrp |= reg;
        branch_to_custom_function[0] = adrp;

        unsigned int offset = (unsigned int)(to - to_page);
        if (offset > 0) {
            unsigned int add = 0b10010001000000000000000000000000;
            const int immshift = 10;
            unsigned int imm = offset & ((1 << 12) - 1);
            add |= imm << immshift;
            add |= (reg << 5) | reg;
            branch_to_custom_function[1] = add;
        }
    }

    {
        unsigned int br = 0b11010110000111110000000000000000;
        br |= (reg << 5);
        branch_to_custom_function[branch_instructions_count - 1] = br;
    }
}

static void print_lldb_memory_write_command(uintptr_t dst, uintptr_t src, int size) {
    unsigned int *memory = (unsigned int *)src;
    char buffer[128] = {0};
    for (int i = 0; i < size; i++) {
        sprintf(buffer, "memory write -s %d 0x%lx 0x%x\n", bytes_per_instruction, dst + i * bytes_per_instruction, memory[i]);
        strcat(lldb_command, buffer);
    }
}

static void print_lldb_command(uintptr_t hooked_function, uintptr_t custom_function, uintptr_t entry, int branch_instructions_count) {
    unsigned int branch_to_custom_function[branch_instructions_max_count];
    lldb_command[0] = '\0';
    generate_branch_instructions(hooked_function, custom_function, branch_to_custom_function, branch_instructions_count);
    print_lldb_memory_write_command(entry, hooked_function, branch_instructions_count);
    strcat(lldb_command, "\n");
    print_lldb_memory_write_command(hooked_function, (uintptr_t)branch_to_custom_function, branch_instructions_count);
    strcat(lldb_command, "\n");
}

static uintptr_t hook_table_key[PDL_LLDB_HOOK_MAX_COUNT] = {0};
static uintptr_t hook_table_value[PDL_LLDB_HOOK_MAX_COUNT] = {0};

static int index_of_hook_table(uintptr_t custom_function) {
    for (int i = 0; i < PDL_LLDB_HOOK_MAX_COUNT; i++) {
        uintptr_t key = hook_table_key[i];
        if (key == custom_function) {
            return i;
        }
    }
    return -1;
}

static int first_empty_index_of_hook_table(void) {
    for (int i = 0; i < PDL_LLDB_HOOK_MAX_COUNT; i++) {
        uintptr_t key = hook_table_key[i];
        if (key == 0) {
            return i;
        }
    }
    return -1;
}

static int lldb_hook(uintptr_t hooked_function, uintptr_t custom_function) {
    int index = index_of_hook_table(custom_function);
    if (index != -1) {
        return -1;
    }

    int first_empty_index = first_empty_index_of_hook_table();
    if (first_empty_index == -1) {
        return -2;
    }

    int branch_instructions_count = get_branch_instructions_count(hooked_function, custom_function);

    hook_table_key[first_empty_index] = custom_function;
    hook_table_value[first_empty_index] = hooked_function;
    uintptr_t *shiftedEntry = lldb_entry_original_with_offsets[first_empty_index];
    *shiftedEntry = hooked_function + branch_instructions_count * bytes_per_instruction;
    uintptr_t entry = (uintptr_t)lldb_entrys[first_empty_index];
    print_lldb_command(hooked_function, custom_function, entry, branch_instructions_count);

    return branch_instructions_count;
}

int pdl_lldb_hook(IMP hooked_function, IMP custom_function) {
    if (hooked_function == NULL || custom_function == NULL || hooked_function == custom_function) {
        return 0;
    }

    return lldb_hook((uintptr_t)hooked_function, (uintptr_t)custom_function);
}

char *pdl_lldb_command(void) {
    return lldb_command;
}

IMP pdl_lldb_hooked_function_new_entry(IMP custom_function) {
    int index = index_of_hook_table((uintptr_t)custom_function);
    if (index == -1) {
        return 0;
    }

    return lldb_entrys[index];
}

#else

int pdl_lldb_hook(IMP hooked_function, IMP custom_function) {
    return 0;
}

char *pdl_lldb_command(void) {
    return NULL;
}

IMP pdl_lldb_hooked_function_new_entry(IMP custom_function) {
    return NULL;
}

#endif
