//
//  pdl_algorithm.h
//  Poodle
//
//  Created by Poodle on 2016/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include <stdio.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

extern void pdl_mergesort(void *items, size_t items_count, size_t width, int(*compare)(void *item1, void *item2));

extern void *pdl_bsearch(void *item, void *items, size_t items_count, size_t width, int(*compare)(void *item1, void *item2));

#ifdef __cplusplus
}
#endif
