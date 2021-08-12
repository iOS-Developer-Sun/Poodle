//
//  pdl_lldb_hook.h
//  Poodle
//
//  Created by Poodle on 2019/12/19.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include <stdlib.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

extern char *pdl_lldb_command(void);
extern int pdl_lldb_hook(void *hooked_function, void *custom_function);
extern void *pdl_lldb_hooked_new_entry(void **hooked_function);

#ifdef __cplusplus
}
#endif
