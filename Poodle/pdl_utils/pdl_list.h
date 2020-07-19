//
//  pdl_list.h
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
    
typedef struct pdl_list_node {
    struct pdl_list_node *prev;
    struct pdl_list_node *next;
    union {
        char c[0];
        int i[0];
        long l[0];
        float f[0];
        double d[0];
        void *v[0];
    } data;
} pdl_list_node;

typedef struct pdl_list {
    struct pdl_list_node *head;
    struct pdl_list_node *tail;
    unsigned int count;
    void *(*malloc)(size_t);
    void (*free)(void *);
} pdl_list;

extern unsigned int pdl_list_length(pdl_list *list);

extern pdl_list *pdl_list_create(void *(*malloc_ptr)(size_t), void(*free_ptr)(void *));
extern void pdl_list_destroy(pdl_list *list);

extern pdl_list_node *pdl_list_create_node(pdl_list *list, size_t extra_size);
extern void pdl_list_destroy_node(pdl_list *list, pdl_list_node *node);

extern pdl_list_node *pdl_list_add_head(pdl_list *list, pdl_list_node *node);
extern pdl_list_node *pdl_list_add_tail(pdl_list *list, pdl_list_node *node);
extern pdl_list_node *pdl_list_insert_before(pdl_list *list, pdl_list_node *before, pdl_list_node *node);
extern pdl_list_node *pdl_list_insert_after(pdl_list *list, pdl_list_node *after, pdl_list_node *node);
extern void pdl_list_remove(pdl_list *list, pdl_list_node *node);
extern void pdl_list_remove_and_destroy_all(pdl_list *list);

extern void pdl_list_print(pdl_list *list);

#ifdef __cplusplus
}
#endif
