#import "pdl_dictionary.h"
#import "pdl_hashMap.h"
#import "pdl_array.h"

struct pdl_dictionary {
    pdl_hashMap hashMap;
};

pdl_dictionary_t pdl_createDictionary(void) {
    struct pdl_dictionary *dictionary = malloc(sizeof(struct pdl_dictionary));
    dictionary->hashMap.map = NULL;
    return dictionary;
}

void **pdl_objectForKey(pdl_dictionary_t dictionary, void *key) {
    void **object = pdl_hashMapGetValue(&(((struct pdl_dictionary *)dictionary)->hashMap), key);
    return object;
}

void pdl_removeObjectForKey(pdl_dictionary_t dictionary, void *key) {
    pdl_hashMapDelete(&(((struct pdl_dictionary *)dictionary)->hashMap), key);
}

void pdl_setObjectForKey(pdl_dictionary_t dictionary, void *object, void *key) {
    pdl_hashMapSetValue(&(((struct pdl_dictionary *)dictionary)->hashMap), key, object);
}

pdl_dictionary_t pdl_copyDictionary(pdl_dictionary_t dictionary) {
    struct pdl_dictionary *copy = pdl_createDictionary();
    void **keys = NULL;
    unsigned int count = 0;
    pdl_hashMapGetAllKeys(&(((struct pdl_dictionary *)dictionary)->hashMap), &keys, &count);
    if (keys) {
        for (unsigned int i = 0; i < count; i++) {
            void *key = keys[i];
            void **object = pdl_hashMapGetValue(&(((struct pdl_dictionary *)dictionary)->hashMap), key);
            pdl_hashMapSetValue(&(((struct pdl_dictionary *)copy)->hashMap), key, *object);
        }
        free(keys);
    }
    return copy;
}

pdl_array_t pdl_allKeys(pdl_dictionary_t dictionary) {
    unsigned int count = 0;
    void **keys = NULL;
    pdl_getAllKeys(dictionary, &keys, &count);
    pdl_array_t array = pdl_createArrayWithCapacity(count);
    for (unsigned int i = 0; i < count; i++) {
        pdl_addObject(array, keys[i]);
    }
    free(keys);
    return array;
}


void pdl_getAllKeys(pdl_dictionary_t dictionary, void ***keys, unsigned int *count) {
    pdl_hashMapGetAllKeys(&(((struct pdl_dictionary *)dictionary)->hashMap), keys, count);
}

void pdl_destroyDictionary(pdl_dictionary_t dictionary) {
    pdl_hashMapDeleteAll(&(((struct pdl_dictionary *)dictionary)->hashMap));
    pdl_hashMapDestroy(&(((struct pdl_dictionary *)dictionary)->hashMap));
    free(dictionary);
}

void pdl_destroyDictionaryWithFunctions(pdl_dictionary_t dictionary, void (*keyFunction)(void *), void (*objectFunction)(void *)) {
    if (keyFunction || objectFunction) {
        unsigned int count = 0;
        void **keys = NULL;
        pdl_getAllKeys(dictionary, &keys, &count);
        for (unsigned int i = 0; i < count; i++) {
            void *key = keys[i];
            void **object = pdl_hashMapGetValue(&(((struct pdl_dictionary *)dictionary)->hashMap), key);
            if (keyFunction) {
                keyFunction(key);
            }
            if (object && objectFunction) {
                objectFunction(*object);
            }
        }
        free(keys);
    }
    pdl_destroyDictionary(dictionary);
}

unsigned int pdl_countOfDictionary(pdl_dictionary_t dictionary) {
    return pdl_hashMapCount(&(((struct pdl_dictionary *)dictionary)->hashMap));
}

