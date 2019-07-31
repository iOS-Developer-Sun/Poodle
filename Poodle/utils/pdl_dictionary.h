//
//  pdl_dictionary.h
//  Poodle
//
//  Created by Poodle on 2016/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_array.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef void *pdl_dictionary_t;

extern pdl_dictionary_t pdl_dictionary_create(void);
extern void **pdl_dictionary_objectForKey(pdl_dictionary_t dictionary, void *key);
extern void pdl_dictionary_removeObjectForKey(pdl_dictionary_t dictionary, void *key);
extern void pdl_dictionary_setObjectForKey(pdl_dictionary_t dictionary, void *object, void *key);
extern pdl_dictionary_t pdl_dictionary_copy(pdl_dictionary_t dictionary);
extern pdl_array_t pdl_dictionary_allKeys(pdl_dictionary_t dictionary);
extern void pdl_dictionary_getAllKeys(pdl_dictionary_t dictionary, void ***keys, unsigned int *count);
extern void pdl_dictionary_destroy(pdl_dictionary_t dictionary);
extern unsigned int pdl_dictionary_count(pdl_dictionary_t dictionary);
extern void pdl_dictionary_print(pdl_dictionary_t dictionary);

#ifdef __cplusplus
}
#endif
