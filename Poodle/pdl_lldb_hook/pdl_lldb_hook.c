//
//  pdl_lldb_hook.c
//  Poodle
//
//  Created by Poodle on 2019/12/19.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <mach/vm_map.h>
#include <mach/mach_init.h>
#include <assert.h>
#include "pdl_lldb_hook.h"
#include "pdl_list.h"

#ifdef __arm64__

extern void *pdl_lldb_hook_page_begin;
extern void *pdl_lldb_hook_page_end;
extern void *pdl_lldb_hook_current_entry(void);

#pragma pack (push, 4)
typedef struct {
    void *custom; // adr
    uint32_t reserved[2];
    uint32_t nop; // to text
    void *hooked; // data
    void *hooked_shifted; // adr
    uint32_t instructions_count; // data
} pdl_entry;
#pragma pack (pop)

typedef struct {
    pdl_list_node node;
    pdl_entry *entries;
    int total_count;
    int current_index;
} pdl_page;

static const int pdl_branch_instructions_max_count = 3;
static const int pdl_bytes_per_instruction = 4;
static const int pdl_instructions_count = 10;
static char _pdl_lldb_command[1024] = {0};
static pdl_list *pdl_page_list = NULL;

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

static void generate_branch_instructions(uintptr_t from, uintptr_t to, unsigned int branch_to_custom_function[pdl_branch_instructions_max_count], int branch_instructions_count) {
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
        sprintf(buffer, "memory write -s %d 0x%lx 0x%x\n", pdl_bytes_per_instruction, dst + i * pdl_bytes_per_instruction, memory[i]);
        strcat(_pdl_lldb_command, buffer);
    }
}

static void print_lldb_command(uintptr_t hooked_function, uintptr_t custom_function, uintptr_t entry, int branch_instructions_count) {
    unsigned int branch_to_custom_function[pdl_branch_instructions_max_count];
    _pdl_lldb_command[0] = '\0';
    generate_branch_instructions(hooked_function, custom_function, branch_to_custom_function, branch_instructions_count);
    print_lldb_memory_write_command(entry, hooked_function, branch_instructions_count);
    strcat(_pdl_lldb_command, "\n");
    print_lldb_memory_write_command(hooked_function, (uintptr_t)branch_to_custom_function, branch_instructions_count);
    strcat(_pdl_lldb_command, "\n");
}

static uintptr_t lldb_page(void) {
    vm_address_t dataAddress = 0;
    mach_port_t task = mach_task_self();
    kern_return_t result = vm_allocate(task, &dataAddress, PAGE_MAX_SIZE * 2, VM_FLAGS_ANYWHERE | VM_MAKE_TAG(VM_MEMORY_FOUNDATION));
    if (result != KERN_SUCCESS) {
        return 0;
    }

    vm_address_t codeAddress = dataAddress + PAGE_MAX_SIZE;
    vm_address_t codePage = (vm_address_t)&pdl_lldb_hook_page_begin;
    vm_prot_t currentProtection = 0;
    vm_prot_t maxProtection = 0;
    result = vm_remap(task, &codeAddress, PAGE_MAX_SIZE, 0, VM_FLAGS_FIXED | VM_FLAGS_OVERWRITE, task, codePage, true, &currentProtection, &maxProtection, VM_INHERIT_SHARE);
    if (result != KERN_SUCCESS) {
        return 0;
    }

    return dataAddress;
}

static pdl_page *lldb_hook_available_page(void) {
    if (!pdl_page_list) {
        pdl_page_list = pdl_list_create(NULL, NULL);
    }
    if (!pdl_page_list) {
        return NULL;
    }

    pdl_page *page = (pdl_page *)(pdl_page_list->tail);
    if (!page || page->current_index == page->total_count) {
        page = (pdl_page *)pdl_list_create_node(pdl_page_list, sizeof(pdl_page) - sizeof(pdl_list_node));
        if (page) {
            page->entries = (pdl_entry *)lldb_page();
            page->total_count = PAGE_MAX_SIZE / (pdl_instructions_count * pdl_bytes_per_instruction);
            page->current_index = 0;
            pdl_list_add_tail(pdl_page_list, (pdl_list_node *)page);
        }
    }

    return page;
}

static uintptr_t page_entry(pdl_page *page) {
    pdl_entry *entry = page->entries + page->current_index;
    return ((uintptr_t)entry) + PAGE_MAX_SIZE;
}

static uintptr_t commit_page(pdl_page *page, uintptr_t hooked_function, uintptr_t custom_function, int instructions_count) {
    pdl_entry *entry = page->entries + page->current_index;
    entry->custom = (void *)custom_function;
    entry->hooked = (void *)hooked_function;
    entry->hooked_shifted = (void *)hooked_function + instructions_count * pdl_bytes_per_instruction;
    entry->instructions_count = instructions_count;
    page->current_index++;
    return (uintptr_t)&entry->nop + PAGE_MAX_SIZE;
}

static int lldb_hook(uintptr_t hooked_function, uintptr_t custom_function) {
    assert((uintptr_t)(PAGE_MAX_SIZE - (((uintptr_t)&pdl_lldb_hook_page_end - (uintptr_t)&pdl_lldb_hook_page_begin))) < pdl_instructions_count * pdl_bytes_per_instruction);

    pdl_page *page = lldb_hook_available_page();
    if (!page) {
        return -2;
    }

    uintptr_t hooked_function_entry = page_entry(page);
    int branch_instructions_count = get_branch_instructions_count(hooked_function, hooked_function_entry);

    uintptr_t nop = commit_page(page, hooked_function, custom_function, branch_instructions_count);

    print_lldb_command(hooked_function, hooked_function_entry, nop, branch_instructions_count);

    return branch_instructions_count;
}

int pdl_lldb_hook(void *hooked_function, void *custom_function) {
    if (hooked_function == NULL || custom_function == NULL || hooked_function == custom_function) {
        return 0;
    }

    return lldb_hook((uintptr_t)hooked_function, (uintptr_t)custom_function);
}

char *pdl_lldb_command(void) {
    return _pdl_lldb_command;
}

void *pdl_lldb_hooked_new_entry(void **hooked_function) {
    pdl_entry *entry = pdl_lldb_hook_current_entry();
    if (hooked_function) {
        *hooked_function = entry->hooked;
    }
    return ((void *)&entry->nop) + PAGE_MAX_SIZE;
}

#else

#pragma mark -

int pdl_lldb_hook(void *hooked_function, void *custom_function) {
    return 0;
}

char *pdl_lldb_command(void) {
    return NULL;
}

void *pdl_lldb_hooked_new_entry(void **hooked_function) {
    return NULL;
}

#endif
