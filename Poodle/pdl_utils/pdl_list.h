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
    
struct pdl_list_node {
    void *val;
    struct pdl_list_node *prev;
    struct pdl_list_node *next;
};

struct pdl_list {
    struct pdl_list_node *head;
    struct pdl_list_node *tail;
    unsigned int count;
    void *(*malloc)(size_t);
    void (*free)(void *);
};

extern unsigned int pdl_listLength(struct pdl_list *list);

extern struct pdl_list *pdl_list_create(void *(*malloc_ptr)(size_t), void(*free_ptr)(void *));
extern struct pdl_list *pdl_list_create_with_array(void **vals, unsigned int count);
extern void pdl_list_destroy(struct pdl_list *list);

extern struct pdl_list_node *pdl_list_addToHead(struct pdl_list *list, void *val);
extern struct pdl_list_node *pdl_list_addToTail(struct pdl_list *list, void *val);
extern struct pdl_list_node *pdl_list_insertBefore(struct pdl_list *list, struct pdl_list_node *node, void *val);
extern struct pdl_list_node *pdl_list_insertAfter(struct pdl_list *list, struct pdl_list_node *node, void *val);
extern void pdl_list_remove(struct pdl_list *list, struct pdl_list_node *node);

extern void pdl_list_print(struct pdl_list *list);

#ifdef __cplusplus
}
#endif
