//
//  pdl_hash.c
//  Poodle
//
//  Created by Poodle on 2016/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_hash.h"

void pdl_hash_delete(pdl_hash *map, void *key) {
    pdl_hash_item *item = NULL;
    HASH_FIND_PTR(map->map, &key, item);
    if (item != NULL) {
        HASH_DEL(map->map, item);
        free(item);
    }
}

void pdl_hash_delete_all(pdl_hash *map) {
    pdl_hash_item *current, *tmp;
    HASH_ITER(hh, map->map, current, tmp) {
        HASH_DEL(map->map, current);
        free(current);
    }
}

void pdl_hash_set_value(pdl_hash *map, void *key, void *value) {
    pdl_hash_item *item = map->malloc(sizeof(pdl_hash_item));
    item->hh.malloc = map->malloc;
    item->hh.free = (typeof(item->hh.free))map->free;
    item->key = key;
    item->value = value;
    HASH_ADD_PTR(map->map, key, item);
}

void **pdl_hash_get_value(pdl_hash *map, void *key) {
    pdl_hash_item *item;
    HASH_FIND_PTR(map->map, &key, item);
    if (item != NULL) {
        return &(item->value);
    }
    return NULL;
}

bool pdl_hash_has_key(pdl_hash *map, void *key) {
    pdl_hash_item *item;
    HASH_FIND_PTR(map->map, &key, item);
    if (item != NULL) {
        return true;
    }
    return false;
}

unsigned int pdl_hash_count(pdl_hash *map) {
    return HASH_COUNT(map->map);
}

void pdl_hash_get_all_keys(pdl_hash *map, void ***keys, unsigned int *count) {
    if (count) {
        *count = HASH_COUNT(map->map);
    }
    if (keys == NULL) {
        return;
    }
    *keys = map->malloc(sizeof(void *) * (HASH_COUNT(map->map)));
    unsigned int i = 0;
    pdl_hash_item *current, *tmp;
    HASH_ITER(hh, map->map, current, tmp) {
        (*keys)[i++] = current->key;
    }
}

void pdl_hash_destroy(pdl_hash *map) {
    pdl_hash_delete_all(map);
    HASH_CLEAR(hh, map->map);
}
