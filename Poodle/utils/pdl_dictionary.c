#import "pdl_dictionary.h"
#import "pdl_hashMap.h"
#import "pdl_array.h"
#import <stdio.h>

struct pdl_dictionary {
    pdl_hashMap hashMap;
};

pdl_dictionary_t pdl_dictionary_create(void) {
    struct pdl_dictionary *dictionary = malloc(sizeof(struct pdl_dictionary));
    dictionary->hashMap.map = NULL;
    return dictionary;
}

void **pdl_dictionary_objectForKey(pdl_dictionary_t dictionary, void *key) {
    void **object = pdl_hashMapGetValue(&(((struct pdl_dictionary *)dictionary)->hashMap), key);
    return object;
}

void pdl_dictionary_removeObjectForKey(pdl_dictionary_t dictionary, void *key) {
    pdl_hashMapDelete(&(((struct pdl_dictionary *)dictionary)->hashMap), key);
}

void pdl_dictionary_setObjectForKey(pdl_dictionary_t dictionary, void *object, void *key) {
    pdl_hashMapSetValue(&(((struct pdl_dictionary *)dictionary)->hashMap), key, object);
}

pdl_dictionary_t pdl_dictionary_copy(pdl_dictionary_t dictionary) {
    struct pdl_dictionary *copy = pdl_dictionary_create();
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

pdl_array_t pdl_dictionary_allKeys(pdl_dictionary_t dictionary) {
    unsigned int count = 0;
    void **keys = NULL;
    pdl_dictionary_getAllKeys(dictionary, &keys, &count);
    pdl_array_t array = pdl_array_createWithCapacity(count);
    for (unsigned int i = 0; i < count; i++) {
        pdl_array_addObject(array, keys[i]);
    }
    free(keys);
    return array;
}

void pdl_dictionary_getAllKeys(pdl_dictionary_t dictionary, void ***keys, unsigned int *count) {
    pdl_hashMapGetAllKeys(&(((struct pdl_dictionary *)dictionary)->hashMap), keys, count);
}

void pdl_dictionary_destroy(pdl_dictionary_t dictionary) {
    pdl_hashMapDeleteAll(&(((struct pdl_dictionary *)dictionary)->hashMap));
    pdl_hashMapDestroy(&(((struct pdl_dictionary *)dictionary)->hashMap));
    free(dictionary);
}

unsigned int pdl_dictionary_count(pdl_dictionary_t dictionary) {
    return pdl_hashMapCount(&(((struct pdl_dictionary *)dictionary)->hashMap));
}

void pdl_dictionary_print(pdl_dictionary_t dictionary) {
    unsigned int count = 0;
    void **keys = NULL;
    pdl_dictionary_getAllKeys(dictionary, &keys, &count);
    printf("[%d]", count);
    for (unsigned int i = 0; i < count; i++) {
        void *key = keys[i];
        void *object = pdl_dictionary_objectForKey(dictionary, key);
        printf(" <%p : %p>", key, object);
    }
    printf("\n");
    free(keys);
}
