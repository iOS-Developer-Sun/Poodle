#import "pdl_dictionary.h"
#import "pdl_hashMap.h"
#import "pdl_array.h"
#import <stdio.h>

struct pdl_dictionary {
    pdl_hashMap hashMap;
};

pdl_dictionary_t pdl_dictionary_create(void) {
    return pdl_dictionary_create_with_malloc_pointers(NULL, NULL);
}

pdl_dictionary_t pdl_dictionary_create_with_malloc_pointers(void *(*malloc_ptr)(size_t), void(*free_ptr)(void *)) {
    void *(*m_ptr)(size_t) = malloc_ptr ?: &malloc;
    void(*f_ptr)(void *) = free_ptr ?: &free;
    struct pdl_dictionary *dictionary = m_ptr(sizeof(struct pdl_dictionary));
    dictionary->hashMap.map = NULL;
    dictionary->hashMap.malloc = m_ptr;
    dictionary->hashMap.free = f_ptr;
    return dictionary;
}

void **pdl_dictionary_objectForKey(pdl_dictionary_t dictionary, void *key) {
    pdl_hashMap *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    void **object = pdl_hashMapGetValue(map, key);
    return object;
}

void pdl_dictionary_removeObjectForKey(pdl_dictionary_t dictionary, void *key) {
    pdl_hashMap *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    pdl_hashMapDelete(map, key);
}

void pdl_dictionary_removeAllObjects(pdl_dictionary_t dictionary) {
    pdl_hashMap *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    pdl_hashMapDeleteAll(map);
}

void pdl_dictionary_setObjectForKey(pdl_dictionary_t dictionary, void *object, void *key) {
    pdl_hashMap *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    pdl_hashMapSetValue(map, key, object);
}

pdl_dictionary_t pdl_dictionary_copy(pdl_dictionary_t dictionary) {
    struct pdl_dictionary *copy = pdl_dictionary_create();
    void **keys = NULL;
    unsigned int count = 0;
    pdl_hashMap *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    pdl_hashMapGetAllKeys(map, &keys, &count);
    if (keys) {
        for (unsigned int i = 0; i < count; i++) {
            void *key = keys[i];
            void **object = pdl_hashMapGetValue(map, key);
            pdl_hashMapSetValue(&(((struct pdl_dictionary *)copy)->hashMap), key, *object);
        }
        map->free(keys);
    }
    return copy;
}

pdl_array_t pdl_dictionary_allKeys(pdl_dictionary_t dictionary) {
    pdl_hashMap *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    unsigned int count = 0;
    void **keys = NULL;
    pdl_hashMapGetAllKeys(map, &keys, &count);
    pdl_array_t array = pdl_array_createWithCapacity(count);
    for (unsigned int i = 0; i < count; i++) {
        pdl_array_addObject(array, keys[i]);
    }
    map->free(keys);
    return array;
}

void pdl_dictionary_getAllKeys(pdl_dictionary_t dictionary, void ***keys, unsigned int *count) {
    pdl_hashMap *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    pdl_hashMapGetAllKeys(map, keys, count);
}

void pdl_dictionary_destroy(pdl_dictionary_t dictionary) {
    pdl_hashMap *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    pdl_hashMapDestroy(map);
    map->free(dictionary);
}

unsigned int pdl_dictionary_count(pdl_dictionary_t dictionary) {
    pdl_hashMap *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    return pdl_hashMapCount(map);
}

void pdl_dictionary_print(pdl_dictionary_t dictionary) {
    pdl_hashMap *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    unsigned int count = 0;
    void **keys = NULL;
    pdl_hashMapGetAllKeys(map, &keys, &count);
    printf("[%d]", count);
    for (unsigned int i = 0; i < count; i++) {
        void *key = keys[i];
        void *object = pdl_dictionary_objectForKey(dictionary, key);
        printf(" <%p : %p>", key, object);
    }
    printf("\n");
    map->free(keys);
}
