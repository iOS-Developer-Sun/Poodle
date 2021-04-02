//
//  pdl_array.h
//  Poodle
//
//  Created by Poodle on 2016/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include <malloc/malloc.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void *pdl_array_t;

extern pdl_array_t pdl_array_create(unsigned int capacity);
extern pdl_array_t pdl_array_create_with_malloc_pointers(unsigned int capacity, void *(*malloc_ptr)(size_t), void(*free_ptr)(void *));

extern void *pdl_array_get(pdl_array_t array, unsigned int index);
extern unsigned int pdl_array_index(pdl_array_t array, void *value);
extern void pdl_array_remove(pdl_array_t array, unsigned int index);
extern void pdl_array_remove_all(pdl_array_t array);
extern void pdl_array_remove_value(pdl_array_t array, void *value);
extern void pdl_array_add(pdl_array_t array, void *value);
extern void pdl_array_insert(pdl_array_t array, void *value, unsigned int index);
extern void pdl_array_destroy(pdl_array_t array);
extern void pdl_array_sort_by_function(pdl_array_t array, int(*sort)(void *value1, void *value2));
extern void pdl_array_sort_by_function_and_data(pdl_array_t array, int(*sort)(void *value1, void *value2, void *data), void *data);
extern unsigned int pdl_array_count(pdl_array_t array);
extern void pdl_array_print(pdl_array_t array);

#ifdef __cplusplus
}
#endif
