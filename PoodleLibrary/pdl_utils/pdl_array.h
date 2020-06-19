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

extern void *pdl_array_object_at_index(pdl_array_t array, unsigned int index);
extern unsigned int pdl_array_index_of_object(pdl_array_t array, void *object);
extern void pdl_array_remove_object_at_index(pdl_array_t array, unsigned int index);
extern void pdl_array_remove_object(pdl_array_t array, void *object);
extern void pdl_array_add_object(pdl_array_t array, void *object);
extern void pdl_array_insert_object_at_index(pdl_array_t array, void *object, unsigned int index);
extern pdl_array_t pdl_array_copy(pdl_array_t array);
extern void pdl_array_destroy(pdl_array_t array);
extern void pdl_array_sort_by_function(pdl_array_t array, int(*sort)(void *object1, void *object2));
extern void pdl_array_sort_by_function_and_data(pdl_array_t array, int(*sort)(void *object1, void *object2, void *data), void *data);
extern unsigned int pdl_array_count(pdl_array_t array);
extern void pdl_array_print(pdl_array_t array);

#ifdef __cplusplus
}
#endif
