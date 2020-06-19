//
//  pdl_array.c
//  Poodle
//
//  Created by Poodle on 2016/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_array.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <limits.h>

struct pdl_array {
    char type[16];
    void **array;
    unsigned int count;
    unsigned int capacity;
    void *(*malloc)(size_t);
    void (*free)(void *);
};

pdl_array_t pdl_array_create(unsigned int capacity) {
    return pdl_array_create_with_malloc_pointers(capacity, NULL, NULL);
}

pdl_array_t pdl_array_create_with_malloc_pointers(unsigned int capacity, void *(*malloc_ptr)(size_t), void(*free_ptr)(void *)) {
    void *(*m_ptr)(size_t) = malloc_ptr ?: &malloc;
    void(*f_ptr)(void *) = free_ptr ?: &free;
    struct pdl_array *array = m_ptr(sizeof(struct pdl_array));
    strcpy(array->type, "array");
    array->count = 0;
    array->array = m_ptr(capacity * sizeof(void *));
    array->capacity = capacity;
    array->malloc = m_ptr;
    array->free = f_ptr;
    return array;
}

void *pdl_array_object_at_index(pdl_array_t array, unsigned int index) {
    return ((struct pdl_array *)array)->array[index];
}

unsigned int pdl_array_index_of_object(pdl_array_t array, void *object) {
    unsigned int index = UINT_MAX;
    int count = ((struct pdl_array *)array)->count;
    void **a = ((struct pdl_array *)array)->array;
    for (int i = 0; i < count; i++) {
        if (a[i] == object) {
            index = i;
            break;
        }
    }
    return index;
}

void pdl_array_remove_object_at_index(pdl_array_t array, unsigned int index) {
    int count = ((struct pdl_array *)array)->count;
    if (index >= count) {
        return;
    }

    void **a = ((struct pdl_array *)array)->array;
    for (int i = index; i < count - 1; i++) {
        a[i] = a[i + 1];
    }
    ((struct pdl_array *)array)->count = count - 1;
}

void pdl_array_remove_object(pdl_array_t array, void *object) {
    int count = ((struct pdl_array *)array)->count;
    void **a = ((struct pdl_array *)array)->array;
    for (int i = count - 1; i >= 0; i--) {
        if (a[i] == object) {
            for (int j = i; j < count - 1; j++) {
                a[j] = a[j + 1];
            }
            count--;
        }
    }
    ((struct pdl_array *)array)->count = count;
}

void pdl_array_add_object(pdl_array_t array, void *object) {
    pdl_array_insert_object_at_index(array, object, ((struct pdl_array *)array)->count);
}

void pdl_array_insert_object_at_index(pdl_array_t array, void *object, unsigned int index) {
    int count = ((struct pdl_array *)array)->count;
    if (index > count) {
        return;
    }
    int capacity = ((struct pdl_array *)array)->capacity;
    if (count >= capacity) {
        int new_capacity = capacity * 2;
        ((struct pdl_array *)array)->capacity = new_capacity;
        void **new_array = ((struct pdl_array *)array)->malloc(new_capacity * sizeof(void *));
        memcpy(new_array, ((struct pdl_array *)array)->array, (capacity * sizeof(void *)));
        ((struct pdl_array *)array)->free(((struct pdl_array *)array)->array);
        ((struct pdl_array *)array)->array = new_array;
    }

    void **a = ((struct pdl_array *)array)->array;
    for (int i = count; i >= index + 1; i--) {
        a[i] = a[i - 1];
    }
    a[index] = object;
    ((struct pdl_array *)array)->count = count + 1;
}

pdl_array_t pdl_array_copy(pdl_array_t array) {
    struct pdl_array *copy = ((struct pdl_array *)array)->malloc(sizeof(struct pdl_array));
    copy->count = ((struct pdl_array *)array)->count;
    copy->array = ((struct pdl_array *)array)->malloc(((struct pdl_array *)array)->capacity * sizeof(void *));
    copy->capacity = ((struct pdl_array *)array)->capacity;
    memcpy(copy->array, ((struct pdl_array *)array)->array, ((struct pdl_array *)array)->count * sizeof(void *));
    return copy;
}

void pdl_array_destroy(pdl_array_t array) {
    ((struct pdl_array *)array)->free(((struct pdl_array *)array)->array);
    ((struct pdl_array *)array)->free(array);
}

void pdl_array_sort_by_function(pdl_array_t array, int(*sort)(void *object1, void *object2)) {
    int count = ((struct pdl_array *)array)->count;
    for (int i = 0; i < count - 1; i++) {
        for (int j = 0; j < count - 1 - i; j++) {
            void *object1 = ((struct pdl_array *)array)->array[j];
            void *object2 = ((struct pdl_array *)array)->array[j + 1];
            int result = sort(object1, object2);
            if (result > 0) {
                void *tmp = object1;
                ((struct pdl_array *)array)->array[j] = object2;
                ((struct pdl_array *)array)->array[j + 1] = tmp;
            }
        }
    }
}

void pdl_array_sort_by_function_and_data(pdl_array_t array, int(*sort)(void *object1, void *object2, void *data), void *data) {
    int count = ((struct pdl_array *)array)->count;
    for (int i = 0; i < count - 1; i++) {
        for (int j = 0; j < count - 1 - i; j++) {
            void *object1 = ((struct pdl_array *)array)->array[j];
            void *object2 = ((struct pdl_array *)array)->array[j + 1];
            int result = sort(object1, object2, data);
            if (result > 0) {
                void *tmp = object1;
                ((struct pdl_array *)array)->array[j] = object2;
                ((struct pdl_array *)array)->array[j + 1] = tmp;
            }
        }
    }
}

unsigned int pdl_array_count(pdl_array_t array) {
    return ((struct pdl_array *)array)->count;
}

void pdl_array_print(pdl_array_t array) {
    printf("[%d]", ((struct pdl_array *)array)->count);
    for (int i = 0; i < ((struct pdl_array *)array)->count; i++) {
        printf(" %p", ((struct pdl_array *)array)->array[i]);
    }
    printf("\n");
}
