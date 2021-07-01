//
//  pdl_malloc.h
//  Poodle
//
//  Created by Poodle on 2019/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include <stdlib.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

extern bool pdl_malloc_find(void *address, size_t *size, void **header);
extern void pdl_malloc_find_print(uintptr_t address);
extern bool pdl_malloc_frames(uintptr_t address, uintptr_t *frames, unsigned int *count);
extern void pdl_malloc_frames_print(uintptr_t address);

#ifdef __cplusplus
}
#endif

