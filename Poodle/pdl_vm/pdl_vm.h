//
//  pdl_vm.h
//  Poodle
//
//  Created by Poodle on 21-4-28.
//  Copyright © 2021 Poodle. All rights reserved.
//

#include <stdbool.h>
#include <mach/vm_prot.h>
#include <mach/vm_types.h>

#ifdef __cplusplus
extern "C" {
#endif

extern bool pdl_vm_get_protection(void *address, vm_prot_t *prot);
extern bool pdl_vm_read(void *source, void *destination, size_t size);
extern bool pdl_vm_write(void *source, void *destination, size_t size);
extern vm_address_t pdl_vm_allocate_page_pair(void *code);


#ifdef __cplusplus
}
#endif
