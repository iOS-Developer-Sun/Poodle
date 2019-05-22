#import "pdl_hashMap.h"

void pdl_hashMapDelete(pdl_hashMap *map, void *key) {
    pdl_hashItem *item = NULL;
    HASH_FIND_PTR(map->map, &key, item);
    if (item != NULL) {
        HASH_DEL(map->map, item);
    }
}

void pdl_hashMapDeleteAll(pdl_hashMap *map) {
    pdl_hashItem *current, *tmp;
    HASH_ITER(hh, map->map, current, tmp) {
        HASH_DEL(map->map, current);
        free(current);
    }
}

void pdl_hashMapSetValue(pdl_hashMap *map, void *key, void *value) {
    pdl_hashItem *item = malloc(sizeof(pdl_hashItem));
    item->key = key;
    item->value = value;
    HASH_ADD_PTR(map->map, key, item);
}

void **pdl_hashMapGetValue(pdl_hashMap *map, void *key) {
    pdl_hashItem *item;
    HASH_FIND_PTR(map->map, &key, item);
    if (item != NULL) {
        return &(item->value);
    }
    return NULL;
}

bool pdl_hashMapHasKey(pdl_hashMap *map, void *key) {
    pdl_hashItem *item;
    HASH_FIND_PTR(map->map, &key, item);
    if (item != NULL) {
        return true;
    }
    return false;
}

unsigned int pdl_hashMapCount(pdl_hashMap *map) {
    return HASH_COUNT(map->map);
}

void pdl_hashMapGetAllKeys(pdl_hashMap *map, void ***keys, unsigned int *count) {
    if (count) {
        *count = HASH_COUNT(map->map);
    }
    if (keys == NULL) {
        return;
    }
    *keys = malloc(sizeof(void *) * (HASH_COUNT(map->map)));
    unsigned int i = 0;
    pdl_hashItem *current, *tmp;
    HASH_ITER(hh, map->map, current, tmp) {
        (*keys)[i++] = current->key;
    }
}

void pdl_hashMapDestroy(pdl_hashMap *map) {
    pdl_hashMapDeleteAll(map);
    HASH_CLEAR(hh, map->map);
}
