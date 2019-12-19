
#include "pdl_lldb_hook.h"

#ifdef __arm64__

static const int branch_instructions_count = 5;
static const int bytes_per_instruction = 4;

#define PDL_LLDB_HOOK_ENTRY_DECL(lldbEntry) \
static uintptr_t lldbEntry##OriginalWithOffset = 0;\
__attribute__((naked)) static void lldbEntry(void) {\
    __asm__ volatile (\
                      "nop\n"\
                      "nop\n"\
                      "nop\n"\
                      "nop\n"\
                      "nop\n"\
                      "adrp x9, _" #lldbEntry "OriginalWithOffset@PAGE\n"\
                      "ldr x9, [x9, _" #lldbEntry "OriginalWithOffset@PAGEOFF]\n"\
                      "br x9"\
                      );\
}

PDL_LLDB_HOOK_ENTRY_DECL(lldbEntry0)
PDL_LLDB_HOOK_ENTRY_DECL(lldbEntry1)
PDL_LLDB_HOOK_ENTRY_DECL(lldbEntry2)
PDL_LLDB_HOOK_ENTRY_DECL(lldbEntry3)
PDL_LLDB_HOOK_ENTRY_DECL(lldbEntry4)
PDL_LLDB_HOOK_ENTRY_DECL(lldbEntry5)
PDL_LLDB_HOOK_ENTRY_DECL(lldbEntry6)
PDL_LLDB_HOOK_ENTRY_DECL(lldbEntry7)
PDL_LLDB_HOOK_ENTRY_DECL(lldbEntry8)
PDL_LLDB_HOOK_ENTRY_DECL(lldbEntry9)

#define PDL_LLDB_HOOK_MAX_COUNT 10

static void(*lldbEntrys[])(void) = {
    &lldbEntry0,
    &lldbEntry1,
    &lldbEntry2,
    &lldbEntry3,
    &lldbEntry4,
    &lldbEntry5,
    &lldbEntry6,
    &lldbEntry7,
    &lldbEntry8,
    &lldbEntry9,
};

static uintptr_t *lldbEntryOriginalWithOffsets[] = {
    &lldbEntry0OriginalWithOffset,
    &lldbEntry1OriginalWithOffset,
    &lldbEntry2OriginalWithOffset,
    &lldbEntry3OriginalWithOffset,
    &lldbEntry4OriginalWithOffset,
    &lldbEntry5OriginalWithOffset,
    &lldbEntry6OriginalWithOffset,
    &lldbEntry7OriginalWithOffset,
    &lldbEntry8OriginalWithOffset,
    &lldbEntry9OriginalWithOffset,
};

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

bool pdl_lldb_hook(uintptr_t hooked_function, uintptr_t custom_function) {
    if (hooked_function == 0 || custom_function == 0) {
        return false;
    }

    int index = index_of_hook_table(custom_function);
    if (index != -1) {
        return false;
    }

    int first_empty_index = first_empty_index_of_hook_table();
    if (first_empty_index == -1) {
        return false;
    }

    hook_table_key[first_empty_index] = custom_function;
    hook_table_value[first_empty_index] = hooked_function;
    uintptr_t *shiftedEntry = lldbEntryOriginalWithOffsets[first_empty_index];
    *shiftedEntry = hooked_function + branch_instructions_count * bytes_per_instruction;

    return true;
}

uintptr_t pdl_lldb_hooked_function_new_entry(uintptr_t custom_function) {
    int index = index_of_hook_table(custom_function);
    if (index != -1) {
        return 0;
    }

    return (uintptr_t)lldbEntrys[index];
}

#endif
