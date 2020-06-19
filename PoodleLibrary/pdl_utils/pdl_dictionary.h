//
//  pdl_dictionary.h
//  Poodle
//
//  Created by Poodle on 2016/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_array.h"
#include <malloc/malloc.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void *pdl_dictionary_t;

extern pdl_dictionary_t pdl_dictionary_create(void);
extern pdl_dictionary_t pdl_dictionary_create_with_count_limit(unsigned int count_limit);
extern pdl_dictionary_t pdl_dictionary_create_with_malloc_pointers(void *(*malloc_ptr)(size_t), void(*free_ptr)(void *));
extern pdl_dictionary_t pdl_dictionary_create_with_count_limit_and_malloc_pointers(unsigned int count_limit, void *(*malloc_ptr)(size_t), void(*free_ptr)(void *));

extern void **pdl_dictionary_get(pdl_dictionary_t dictionary, void *key);
extern void pdl_dictionary_remove(pdl_dictionary_t dictionary, void *key);
extern void pdl_dictionary_remove_all(pdl_dictionary_t dictionary);
extern void pdl_dictionary_set(pdl_dictionary_t dictionary, void *object, void *key);
extern void pdl_dictionary_get_all_keys(pdl_dictionary_t dictionary, void ***keys, unsigned int *count);
extern void pdl_dictionary_destroy_keys(pdl_dictionary_t dictionary, void **keys);
extern void pdl_dictionary_destroy(pdl_dictionary_t dictionary);
extern unsigned int pdl_dictionary_count(pdl_dictionary_t dictionary);
extern void pdl_dictionary_print(pdl_dictionary_t dictionary);

#ifdef __cplusplus
}
#endif
