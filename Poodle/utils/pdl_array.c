#import "pdl_array.h"
#import <stdlib.h>
#import <string.h>
#import <stdio.h>

struct pdl_array {
    void **array;
    int count;
    int capacity;
};

pdl_array_t pdl_createArrayWithCapacity(unsigned int capacity) {
    int arrayCapacity = capacity;
    if (arrayCapacity == 0) {
        arrayCapacity = 16;
    }
    struct pdl_array *array = malloc(sizeof(struct pdl_array));
    array->count = 0;
    array->array = malloc(capacity * sizeof(void *));
    array->capacity = arrayCapacity;
    return array;
}

void *pdl_objectAtIndex(pdl_array_t array, unsigned int index) {
    return ((struct pdl_array *)array)->array[index];
}

void pdl_removeObjectAtIndex(pdl_array_t array, unsigned int index) {
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

void pdl_removeObject(pdl_array_t array, void *object) {
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

void pdl_addObject(pdl_array_t array, void *object) {
    pdl_insertObjectAtIndex(array, object, ((struct pdl_array *)array)->count);
}

void pdl_insertObjectAtIndex(pdl_array_t array, void *object, unsigned int index) {
    int count = ((struct pdl_array *)array)->count;
    if (index > count) {
        return;
    }
    int capacity = ((struct pdl_array *)array)->capacity;
    if (count >= capacity) {
        int newCapacity = capacity * 2;
        ((struct pdl_array *)array)->capacity = newCapacity;
        void **newArray = malloc(newCapacity * sizeof(void *));
        memcpy(newArray, ((struct pdl_array *)array)->array, (capacity * sizeof(void *)));
        free(((struct pdl_array *)array)->array);
        ((struct pdl_array *)array)->array = newArray;
    }

    void **a = ((struct pdl_array *)array)->array;
    for (int i = count; i >= index + 1; i--) {
        a[i] = a[i - 1];
    }
    a[index] = object;
    ((struct pdl_array *)array)->count = count + 1;
}

pdl_array_t pdl_copyArray(pdl_array_t array) {
    struct pdl_array *copy = malloc(sizeof(struct pdl_array));
    copy->count = ((struct pdl_array *)array)->count;
    copy->array = malloc(((struct pdl_array *)array)->capacity * sizeof(void *));
    copy->capacity = ((struct pdl_array *)array)->capacity;
    memcpy(copy->array, ((struct pdl_array *)array)->array, ((struct pdl_array *)array)->count * sizeof(void *));
    return copy;
}

void pdl_destroyArray(pdl_array_t array) {
    free(((struct pdl_array *)array)->array);
    free(array);
}

void pdl_destroyArrayWithFunction(pdl_array_t array, void (*objectFunction)(void *)) {
    if (objectFunction) {
        for (int i = 0; i < ((struct pdl_array *)array)->count; i++) {
            void *object = ((struct pdl_array *)array)->array[i];
            objectFunction(object);
        }
    }
    pdl_destroyArray(array);
}

void pdl_sortByFunction(pdl_array_t array, int(*sort)(void *object1, void *object2)) {
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

void pdl_sortByFunctionAndData(pdl_array_t array, int(*sort)(void *object1, void *object2, void *data), void *data) {
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

unsigned int pdl_countOfArray(pdl_array_t array) {
    return ((struct pdl_array *)array)->count;
}

void pdl_printArray(pdl_array_t array) {
    printf("[%d]", ((struct pdl_array *)array)->count);
    for (int i = 0; i < ((struct pdl_array *)array)->count; i++) {
        printf(" %p", ((struct pdl_array *)array)->array[i]);
    }
    printf("\n");
}
