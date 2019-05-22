
#include "pdl_array.h"

typedef void *pdl_dictionary_t;

extern pdl_dictionary_t pdl_createDictionary(void);
extern void **pdl_objectForKey(pdl_dictionary_t dictionary, void *key);
extern void pdl_removeObjectForKey(pdl_dictionary_t dictionary, void *key);
extern void pdl_setObjectForKey(pdl_dictionary_t dictionary, void *object, void *key);
extern pdl_dictionary_t pdl_copyDictionary(pdl_dictionary_t dictionary);
extern pdl_array_t pdl_allKeys(pdl_dictionary_t dictionary);
extern void pdl_getAllKeys(pdl_dictionary_t dictionary, void ***keys, unsigned int *count);
extern void pdl_destroyDictionary(pdl_dictionary_t dictionary);
extern void pdl_destroyDictionaryWithFunctions(pdl_dictionary_t dictionary, void (*keyFunction)(void *), void (*objectFunction)(void *));
extern unsigned int pdl_countOfDictionary(pdl_dictionary_t dictionary);
