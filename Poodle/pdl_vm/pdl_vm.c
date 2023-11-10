//
//  pdl_vm.c
//  Poodle
//
//  Created by Poodle on 21-4-28.
//  Copyright © 2021 Poodle. All rights reserved.
//

#include "pdl_vm.h"
#include <mach/vm_region.h>
#include <mach/mach.h>
#include <mach/vm_map.h>

vm_prot_t pdl_vm_get_protection(void *address) {
    mach_port_t task = mach_task_self();
    vm_size_t size = 0;
    vm_address_t *addr = (vm_address_t *)&address;
    memory_object_name_t object;
#if __LP64__
    mach_msg_type_number_t count = VM_REGION_BASIC_INFO_COUNT_64;
    vm_region_basic_info_data_64_t info;
    kern_return_t info_ret = vm_region_64(task, addr, &size, VM_REGION_BASIC_INFO_64, (vm_region_info_64_t)&info, &count, &object);
#else
    mach_msg_type_number_t count = VM_REGION_BASIC_INFO_COUNT;
    vm_region_basic_info_data_t info;
    kern_return_t info_ret = vm_region(task, addr, &size, VM_REGION_BASIC_INFO, (vm_region_info_t)&info, &count, &object);
#endif
    if (info_ret == KERN_SUCCESS) {
        return info.protection;
    } else {
        return VM_PROT_READ;
    }
}

bool pdl_vm_write(void **address, void *value, void **original) {
    bool changed = false;
    vm_prot_t prot = pdl_vm_get_protection(address);
    if (original && (prot & VM_PROT_READ)) {
        *original = *address;
    }
    if ((prot & VM_PROT_WRITE) == 0) {
        changed = true;
        kern_return_t success = vm_protect(mach_task_self(), (vm_address_t)address, sizeof(void *), false, prot | VM_PROT_WRITE);
        if (success != KERN_SUCCESS) {
            return false;
        }
    }
    *address = value;
    if (changed) {
        vm_protect(mach_task_self(), (vm_address_t)address, sizeof(void *), false, prot);
    }
    return true;
}

vm_address_t pdl_vm_allocate_page_pair(void *code) {
    vm_address_t dataAddress = 0;
    mach_port_t task = mach_task_self();
    kern_return_t result = vm_allocate(task, &dataAddress, PAGE_MAX_SIZE * 2, VM_FLAGS_ANYWHERE | VM_MAKE_TAG(VM_MEMORY_FOUNDATION));
    if (result != KERN_SUCCESS) {
        return 0;
    }

    vm_address_t codeAddress = dataAddress + PAGE_MAX_SIZE;
    vm_address_t codePage = (vm_address_t)code;
    vm_prot_t currentProtection = 0;
    vm_prot_t maxProtection = 0;
    result = vm_remap(task, &codeAddress, PAGE_MAX_SIZE, 0, VM_FLAGS_FIXED | VM_FLAGS_OVERWRITE, task, codePage, true, &currentProtection, &maxProtection, VM_INHERIT_SHARE);
    if (result != KERN_SUCCESS) {
        return 0;
    }

    return dataAddress;
}
