//
//  pdl_malloc.m
//  Poodle
//
//  Created by Poodle on 2019/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_malloc.h"
#include <malloc/malloc.h>

struct pdl_malloc_recorder_context {
    void *address;
    size_t size;
    void *header;
};

static void recorder(task_t task, void *context, unsigned type, vm_range_t *ranges, unsigned rangeCount) {
    struct pdl_malloc_recorder_context *recorder_context = context;
    for (unsigned int i = 0; i < rangeCount; i++) {
        vm_range_t range = ranges[i];
        vm_address_t address = range.address;
        vm_size_t size = range.size;

        vm_address_t addr = (vm_address_t)recorder_context->address;
        if ((addr >= address) && (addr < address + size)) {
            recorder_context->header = (void *)address;
            recorder_context->size = size;
        }
    }
}

static kern_return_t reader(__unused task_t remote_task, vm_address_t remote_address, __unused vm_size_t size, void **local_memory) {
    *local_memory = (void *)remote_address;
    return KERN_SUCCESS;
}

bool pdl_malloc_check(void *address, size_t *size, void **header) {
    vm_address_t *zones = NULL;
    unsigned int zoneCount = 0;
    kern_return_t result = malloc_get_all_zones(TASK_NULL, NULL, &zones, &zoneCount);
    if (result != KERN_SUCCESS) {
        return false;
    }

    size_t malloc_size = 0;
    void *malloc_header = NULL;
    for (unsigned int i = 0; i < zoneCount; i++) {
        malloc_zone_t *zone = (malloc_zone_t *)zones[i];
        if (zone->size) {
            malloc_size = zone->size(zone, address);
            if (malloc_size > 0) {
                malloc_header = address;
                break;
            }
        }

        if (zone->introspect && zone->introspect->enumerator) {
            struct pdl_malloc_recorder_context context = {address, 0, NULL};
            zone->introspect->enumerator(TASK_NULL, &context, MALLOC_PTR_IN_USE_RANGE_TYPE, (vm_address_t)zone, reader, recorder);
            if (context.size > 0) {
                malloc_size = context.size;
                malloc_header = context.header;
                break;
            }
        }
    }

    if (size) {
        *size = malloc_size;
    }
    if (header) {
        *header = malloc_header;
    }

    return true;
}
