//
//  pdl_vm.h
//  Poodle
//
//  Created by Poodle on 21-4-28.
//  Copyright © 2021 Poodle. All rights reserved.
//

#include <stdbool.h>
#include <mach/vm_prot.h>

#ifdef __cplusplus
extern "C" {
#endif

extern vm_prot_t pdl_vm_get_protection(void *address);
extern bool pdl_vm_write(void **address, void *value, void **original);

#ifdef __cplusplus
}
#endif
