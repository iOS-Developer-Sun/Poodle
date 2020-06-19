//
//  pdl_hash.h
//  Poodle
//
//  Created by Poodle on 2016/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include <stdio.h>
#include <stdbool.h>
#include "uthash.h"

#ifdef __cplusplus
extern "C" {
#endif
    
typedef struct pdl_hash_item {
    void *key;
    void *value;
    UT_hash_handle hh;
} pdl_hash_item;

typedef struct pdl_hash {
    pdl_hash_item *map;
    void *(*malloc)(size_t);
    void (*free)(void *);
} pdl_hash;

extern void pdl_hash_delete(pdl_hash *map, void *key);
extern void pdl_hash_delete_all(pdl_hash *map);
extern void pdl_hash_set_value(pdl_hash *map, void *key, void *value);
extern void **pdl_hash_get_value(pdl_hash *map, void *key);
extern bool pdl_hash_has_key(pdl_hash *map, void *key);
extern unsigned int pdl_hash_count(pdl_hash *map);
extern void pdl_hash_get_all_keys(pdl_hash *map, void ***keys, unsigned int *count);
extern void pdl_hash_destroy(pdl_hash *map);

#ifdef __cplusplus
}
#endif
