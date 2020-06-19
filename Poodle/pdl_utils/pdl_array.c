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
    if (!array) {
        return NULL;
    }

    strcpy(array->type, "array");
    array->count = 0;
    array->array = m_ptr(capacity * sizeof(void *));
    array->capacity = capacity;
    array->malloc = m_ptr;
    array->free = f_ptr;
    return array;
}

void *pdl_array_get(pdl_array_t array, unsigned int index) {
    return ((struct pdl_array *)array)->array[index];
}

unsigned int pdl_array_index(pdl_array_t array, void *value) {
    unsigned int index = UINT_MAX;
    int count = ((struct pdl_array *)array)->count;
    void **a = ((struct pdl_array *)array)->array;
    for (int i = 0; i < count; i++) {
        if (a[i] == value) {
            index = i;
            break;
        }
    }
    return index;
}

void pdl_array_remove(pdl_array_t array, unsigned int index) {
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

void pdl_array_remove_value(pdl_array_t array, void *value) {
    int count = ((struct pdl_array *)array)->count;
    void **a = ((struct pdl_array *)array)->array;
    for (int i = count - 1; i >= 0; i--) {
        if (a[i] == value) {
            for (int j = i; j < count - 1; j++) {
                a[j] = a[j + 1];
            }
            count--;
        }
    }
    ((struct pdl_array *)array)->count = count;
}

void pdl_array_add(pdl_array_t array, void *value) {
    pdl_array_insert(array, value, ((struct pdl_array *)array)->count);
}

void pdl_array_insert(pdl_array_t array, void *value, unsigned int index) {
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
    a[index] = value;
    ((struct pdl_array *)array)->count = count + 1;
}

void pdl_array_destroy(pdl_array_t array) {
    ((struct pdl_array *)array)->free(((struct pdl_array *)array)->array);
    ((struct pdl_array *)array)->free(array);
}

void pdl_array_sort_by_function(pdl_array_t array, int(*sort)(void *value1, void *value2)) {
    int count = ((struct pdl_array *)array)->count;
    for (int i = 0; i < count - 1; i++) {
        for (int j = 0; j < count - 1 - i; j++) {
            void *value1 = ((struct pdl_array *)array)->array[j];
            void *value2 = ((struct pdl_array *)array)->array[j + 1];
            int result = sort(value1, value2);
            if (result > 0) {
                void *tmp = value1;
                ((struct pdl_array *)array)->array[j] = value2;
                ((struct pdl_array *)array)->array[j + 1] = tmp;
            }
        }
    }
}

void pdl_array_sort_by_function_and_data(pdl_array_t array, int(*sort)(void *value1, void *value2, void *data), void *data) {
    int count = ((struct pdl_array *)array)->count;
    for (int i = 0; i < count - 1; i++) {
        for (int j = 0; j < count - 1 - i; j++) {
            void *value1 = ((struct pdl_array *)array)->array[j];
            void *value2 = ((struct pdl_array *)array)->array[j + 1];
            int result = sort(value1, value2, data);
            if (result > 0) {
                void *tmp = value1;
                ((struct pdl_array *)array)->array[j] = value2;
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
