//
//  pdl_lldb_hook.h
//  Poodle
//
//  Created by Poodle on 2019/12/19.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include <stdlib.h>
#include <stdbool.h>
#include <objc/objc.h>

#ifdef __cplusplus
extern "C" {
#endif

extern bool pdl_lldb_hook(IMP hooked_function, IMP custom_function);
extern char *pdl_lldb_command(void);

extern IMP pdl_lldb_hooked_function_new_entry(IMP custom_function);

#ifdef __cplusplus
}
#endif
