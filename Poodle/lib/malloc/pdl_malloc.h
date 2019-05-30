//
//  pdl_malloc.h
//  Poodle
//
//  Created by Poodle on 2019/5/15.
//
//

#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

extern bool pdl_malloc_check(void *address, size_t *size, void **header);

#ifdef __cplusplus
}
#endif

