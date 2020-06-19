//
//  pdl_dictionary.c
//  Poodle
//
//  Created by Poodle on 2016/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_dictionary.h"
#include "pdl_hash.h"
#include "pdl_array.h"
#include <stdio.h>
#include <limits.h>

struct pdl_dictionary {
    pdl_hash hashMap;
    unsigned int count;
};

pdl_dictionary_t pdl_dictionary_create(void) {
    return pdl_dictionary_create_with_max_count_malloc_pointers(0, NULL, NULL);
}

pdl_dictionary_t pdl_dictionary_create_with_max_count(unsigned int count) {
    return pdl_dictionary_create_with_max_count_malloc_pointers(count, NULL, NULL);
}

pdl_dictionary_t pdl_dictionary_create_with_malloc_pointers(void *(*malloc_ptr)(size_t), void(*free_ptr)(void *)) {
    return pdl_dictionary_create_with_max_count_malloc_pointers(0, malloc_ptr, free_ptr);
}

pdl_dictionary_t pdl_dictionary_create_with_max_count_malloc_pointers(unsigned int count, void *(*malloc_ptr)(size_t), void(*free_ptr)(void *)) {
    void *(*m_ptr)(size_t) = malloc_ptr ?: &malloc;
    void(*f_ptr)(void *) = free_ptr ?: &free;
    struct pdl_dictionary *dictionary = m_ptr(sizeof(struct pdl_dictionary));
    dictionary->hashMap.map = NULL;
    dictionary->hashMap.malloc = m_ptr;
    dictionary->hashMap.free = f_ptr;
    dictionary->count = (count == 0) ? UINT_MAX : count;
    return dictionary;
}

void **pdl_dictionary_object_for_key(pdl_dictionary_t dictionary, void *key) {
    if (!key) {
        return NULL;
    }

    pdl_hash *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    void **object = pdl_hash_get_value(map, key);
    return object;
}

void pdl_dictionary_remove_object_for_key(pdl_dictionary_t dictionary, void *key) {
    if (!key) {
        return;
    }

    pdl_hash *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    pdl_hash_delete(map, key);
}

void pdl_dictionary_remove_all_objects(pdl_dictionary_t dictionary) {
    pdl_hash *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    pdl_hash_delete_all(map);
}

void pdl_dictionary_set_object_for_key(pdl_dictionary_t dictionary, void *object, void *key) {
    if (!key) {
        return;
    }

    pdl_hash *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    if (object) {
        pdl_hash_set_value(map, key, object);
    } else {
        pdl_hash_delete(map, key);
    }
}

pdl_dictionary_t pdl_dictionary_copy(pdl_dictionary_t dictionary) {
    struct pdl_dictionary *copy = pdl_dictionary_create();
    void **keys = NULL;
    unsigned int count = 0;
    pdl_hash *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    pdl_hash_get_all_keys(map, &keys, &count);
    if (keys) {
        for (unsigned int i = 0; i < count; i++) {
            void *key = keys[i];
            void **object = pdl_hash_get_value(map, key);
            pdl_hash_set_value(&(((struct pdl_dictionary *)copy)->hashMap), key, *object);
        }
        map->free(keys);
    }
    return copy;
}

pdl_array_t pdl_dictionary_all_keys(pdl_dictionary_t dictionary) {
    pdl_hash *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    unsigned int count = 0;
    void **keys = NULL;
    pdl_hash_get_all_keys(map, &keys, &count);
    pdl_array_t array = pdl_array_create(count);
    for (unsigned int i = 0; i < count; i++) {
        pdl_array_add_object(array, keys[i]);
    }
    map->free(keys);
    return array;
}

void pdl_dictionary_get_all_keys(pdl_dictionary_t dictionary, void ***keys, unsigned int *count) {
    pdl_hash *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    pdl_hash_get_all_keys(map, keys, count);
}

void pdl_dictionary_destroy(pdl_dictionary_t dictionary) {
    pdl_hash *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    pdl_hash_destroy(map);
    map->free(dictionary);
}

unsigned int pdl_dictionary_count(pdl_dictionary_t dictionary) {
    pdl_hash *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    return pdl_hash_count(map);
}

void pdl_dictionary_print(pdl_dictionary_t dictionary) {
    pdl_hash *map = &(((struct pdl_dictionary *)dictionary)->hashMap);
    unsigned int count = 0;
    void **keys = NULL;
    pdl_hash_get_all_keys(map, &keys, &count);
    printf("[%d]", count);
    for (unsigned int i = 0; i < count; i++) {
        void *key = keys[i];
        void *object = pdl_dictionary_object_for_key(dictionary, key);
        printf(" <%p : %p>", key, object);
    }
    printf("\n");
    map->free(keys);
}
