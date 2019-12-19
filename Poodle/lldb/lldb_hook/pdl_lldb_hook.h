
#include <stdlib.h>
#include <stdbool.h>

extern bool pdl_lldb_hook(uintptr_t hooked_function, uintptr_t custom_function);
extern uintptr_t pdl_lldb_hooked_function_new_entry(uintptr_t custom_function);
