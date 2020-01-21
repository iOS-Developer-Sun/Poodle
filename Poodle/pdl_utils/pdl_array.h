//
//  pdl_array.h
//  Poodle
//
//  Created by Poodle on 2016/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif

typedef void *pdl_array_t;

extern pdl_array_t pdl_array_createWithCapacity(unsigned int capacity);
extern void *pdl_array_objectAtIndex(pdl_array_t array, unsigned int index);
extern unsigned int pdl_array_indexOfObject(pdl_array_t array, void *object);
extern void pdl_array_removeObjectAtIndex(pdl_array_t array, unsigned int index);
extern void pdl_array_removeObject(pdl_array_t array, void *object);
extern void pdl_array_addObject(pdl_array_t array, void *object);
extern void pdl_array_insertObjectAtIndex(pdl_array_t array, void *object, unsigned int index);
extern pdl_array_t pdl_array_copy(pdl_array_t array);
extern void pdl_array_destroy(pdl_array_t array);
extern void pdl_array_sortByFunction(pdl_array_t array, int(*sort)(void *object1, void *object2));
extern void pdl_array_sortByFunctionAndData(pdl_array_t array, int(*sort)(void *object1, void *object2, void *data), void *data);
extern unsigned int pdl_array_count(pdl_array_t array);
extern void pdl_array_print(pdl_array_t array);

#ifdef __cplusplus
}
#endif
