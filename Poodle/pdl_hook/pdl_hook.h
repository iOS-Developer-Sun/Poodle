//
//  pdl_hook.h
//  Poodle
//
//  Created by Poodle on 21-4-28.
//  Copyright © 2021 Poodle. All rights reserved.
//

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    const char *name;
    void *external;
    void *custom;
    void **original;
} pdl_hook_item;

extern int pdl_hook(pdl_hook_item *items, size_t count);

#ifdef __cplusplus
}
#endif
