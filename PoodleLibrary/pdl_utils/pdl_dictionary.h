//
//  pdl_dictionary.h
//  Poodle
//
//  Created by Poodle on 2016/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include <malloc/malloc.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void *pdl_dictionary_t;

typedef struct pdl_callbacks {
    void (*retain)(void *);
    void (*release)(void *);
} pdl_callbacks;

typedef struct pdl_dictionary_attr {
    unsigned int count_limit;
    void *(*malloc)(size_t);
    void (*free)(void *);
    pdl_callbacks key_callbacks;
    pdl_callbacks value_callbacks;
} pdl_dictionary_attr;

#define PDL_DICTIONARY_ATTR_INIT {0}

extern pdl_dictionary_t pdl_dictionary_create(pdl_dictionary_attr *attr);

extern void **pdl_dictionary_get(pdl_dictionary_t dictionary, void *key);
extern void pdl_dictionary_remove(pdl_dictionary_t dictionary, void *key);
extern void pdl_dictionary_remove_all(pdl_dictionary_t dictionary);
extern void pdl_dictionary_set(pdl_dictionary_t dictionary, void *key, void *value);
extern void pdl_dictionary_get_all_keys(pdl_dictionary_t dictionary, void ***keys, unsigned int *count);
extern void pdl_dictionary_destroy_keys(pdl_dictionary_t dictionary, void **keys);
extern void pdl_dictionary_destroy(pdl_dictionary_t dictionary);
extern unsigned int pdl_dictionary_count(pdl_dictionary_t dictionary);
extern void pdl_dictionary_print(pdl_dictionary_t dictionary);

#ifdef __cplusplus
}
#endif
