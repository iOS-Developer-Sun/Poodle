
typedef void *pdl_array_t;

extern pdl_array_t pdl_createArrayWithCapacity(unsigned int capacity);
extern void *pdl_objectAtIndex(pdl_array_t array, unsigned int index);
extern void pdl_removeObjectAtIndex(pdl_array_t array, unsigned int index);
extern void pdl_removeObject(pdl_array_t array, void *object);
extern void pdl_addObject(pdl_array_t array, void *object);
extern void pdl_insertObjectAtIndex(pdl_array_t array, void *object, unsigned int index);
extern pdl_array_t pdl_copyArray(pdl_array_t array);
extern void pdl_destroyArray(pdl_array_t array);
extern void pdl_sortByFunction(pdl_array_t array, int(*sort)(void *object1, void *object2));
extern void pdl_sortByFunctionAndData(pdl_array_t array, int(*sort)(void *object1, void *object2, void *data), void *data);
extern unsigned int pdl_countOfArray(pdl_array_t array);
extern void pdl_printArray(pdl_array_t array);
