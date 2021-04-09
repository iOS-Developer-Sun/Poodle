//
//  pdl_malloc.c
//  Poodle
//
//  Created by Poodle on 2019/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_malloc.h"
#include <malloc/malloc.h>
#include "pdl_malloc_zone.h"

typedef struct {
    void *address;
    size_t size;
    void *header;
} pdl_malloc_recorder_context;

static void recorder(void *data, vm_range_t range, unsigned int type, unsigned int count, unsigned int index, bool *stops) {
    pdl_malloc_recorder_context *recorder_context = data;
    vm_address_t address = range.address;
    vm_size_t size = range.size;

    vm_address_t addr = (vm_address_t)recorder_context->address;
    if ((addr >= address) && (addr < address + size)) {
        recorder_context->header = (void *)address;
        recorder_context->size = size;
        *stops = true;
    }
}

bool pdl_malloc_find(void *address, size_t *size, void **header) {
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

        pdl_malloc_recorder_context context = {address, 0, NULL};
        pdl_malloc_zone_enumerate(zone, &context, &recorder);
        if (context.size > 0) {
            malloc_size = context.size;
            malloc_header = context.header;
            break;
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

void pdl_malloc_find_print(uintptr_t address) {
    size_t size = 0;
    void *header = NULL;
    pdl_malloc_find((void *)address, &size, &header);
    malloc_printf("%p:\nsize:%ld, header:%p\n", address, size, header);
}
