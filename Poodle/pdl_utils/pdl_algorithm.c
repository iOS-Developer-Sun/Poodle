//
//  pdl_algorithm.c
//  Poodle
//
//  Created by Poodle on 2016/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_algorithm.h"
#include <string.h>

static int pdl_compare(int(*compare)(void *item1, void *item2), size_t width, void *item1, void *item2) {
    if (compare) {
        return compare(item1, item2);
    }
    return memcmp(item1, item2, width);
}

static void pdl_mergesort_merge(void *array, size_t count, size_t width, int(*compare)(void *item1, void *item2)) {
    size_t middle = (count + 1) / 2;
    size_t i = 0;
    size_t j = middle;
    size_t k = 0;
    char key[width];
    while (i < j && j < count) {
        if (pdl_compare(compare, width, array + i * width, array + j * width) > 0) { // (array[i] > array[j])
            k = j;
            memcpy(key, array + j * width, width); // key = array[j]
            while (k > i && pdl_compare(compare, width, array + (k - 1) * width, key) > 0) { // array[k - 1] > key
                memcpy(array + k * width, array + (k - 1) * width, width); // array[k] = array[k - 1]
                k--;
            }
            memcpy(array + k * width, key, width); // array[k] = key
            j++;
        }
        i++;
    }
}

static void pdl_mergesort_sort(void *array, size_t count, size_t width, int(*compare)(void *item1, void *item2)) {
    if (count <= 1) {
        return;
    }

    size_t half = (count + 1) / 2;
    pdl_mergesort_sort(array, half, width, compare);
    pdl_mergesort_sort(array + half * width, count - half, width, compare);
    pdl_mergesort_merge(array, count, width, compare);
}

void pdl_mergesort(void *items, size_t items_count, size_t width, int(*compare)(void *item1, void *item2)) {
    pdl_mergesort_sort(items, items_count, width, compare);
}

void *pdl_bsearch(void *item, void *items, size_t items_count, size_t width, int(*compare)(void *item1, void *item2)) {
    size_t from = 0;
    size_t to = items_count - 1;
    while (from <= to) {
        size_t middle = from + (to - from) / 2;
        int result = pdl_compare(compare, width, items + middle * width, item); // items[middle] ? item
        if (result > 0) {
            to = middle - 1;
        } else if (result < 0) {
            from = middle + 1;
        } else {
            return items + middle * width;
        }
    }
    return NULL;
}
