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

extern bool pdl_malloc_check(void *address, size_t *size, void **header);
extern void pdl_malloc_check_print(void *address);

#ifdef __cplusplus
}
#endif

