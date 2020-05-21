//
//  pdl_malloc_zone.h
//  Poodle
//
//  Created by Poodle on 2020/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include <malloc/malloc.h>
#include <stdbool.h>

extern malloc_zone_t *pdl_malloc_zone(void);
extern void *pdl_malloc_zone_malloc(size_t size);
extern void *pdl_malloc_zone_realloc(void *ptr, size_t size);
extern void pdl_malloc_zone_free(void *ptr);

extern bool pdl_malloc_trace(void);
extern void pdl_malloc_check_pointer(void *pointer);
extern void pdl_malloc_zone_enumerate(malloc_zone_t *zone, void *data, void(*function)(void *data, vm_range_t range, unsigned int type, unsigned int count, unsigned int index, bool *stops));

