#include <stdio.h>
#include <stdbool.h>
#include "uthash.h"

typedef struct pdl_structHashItem {
    void *key;
    void *value;
    UT_hash_handle hh;
} pdl_hashItem;

typedef struct structHashMap {
    pdl_hashItem *map;
} pdl_hashMap;

extern void pdl_hashMapDelete(pdl_hashMap *map, void *key);
extern void pdl_hashMapDeleteAll(pdl_hashMap *map);
extern void pdl_hashMapSetValue(pdl_hashMap *map, void *key, void *value);
extern void **pdl_hashMapGetValue(pdl_hashMap *map, void *key);
extern bool pdl_hashMapHasKey(pdl_hashMap *map, void *key);
extern unsigned int pdl_hashMapCount(pdl_hashMap *map);
extern void pdl_hashMapGetAllKeys(pdl_hashMap *map, void ***keys, unsigned int *count);
extern void pdl_hashMapDestroy(pdl_hashMap *map);
