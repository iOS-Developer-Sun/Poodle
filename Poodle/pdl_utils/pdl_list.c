//
//  pdl_list.c
//  Poodle
//
//  Created by Poodle on 2016/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_list.h"
#include <stdlib.h>
#include <stdio.h>

unsigned int pdl_listLength(struct pdl_list *list) {
    return list->count;
}

struct pdl_list *pdl_list_create(void *(*malloc_ptr)(size_t), void(*free_ptr)(void *)) {
    void *(*m_ptr)(size_t) = malloc_ptr ?: &malloc;
    void(*f_ptr)(void *) = free_ptr ?: &free;
    struct pdl_list *ret = m_ptr(sizeof(struct pdl_list));
    if (!ret) {
        return NULL;
    }

    ret->head = NULL;
    ret->tail = NULL;
    ret->count = 0;
    ret->malloc = m_ptr;
    ret->free = f_ptr;
    return ret;
}

struct pdl_list *pdl_list_create_with_array(void **vals, unsigned int count) {
    struct pdl_list *ret = pdl_list_create(NULL, NULL);
    if (!ret) {
        return NULL;
    }

    struct pdl_list_node *head = NULL;
    struct pdl_list_node *tail = NULL;
    for (unsigned int i = 0; i < count; i++) {
        struct pdl_list_node *node = ret->malloc(sizeof(struct pdl_list_node));
        node->val = vals[i];
        if (i == 0) {
            node->prev = NULL;
            node->next = NULL;
            head = node;
        } else {
            node->prev = tail;
            node->next = NULL;
            node->prev->next = node;
        }
        tail = node;
    }
    ret->head = head;
    ret->tail = tail;
    ret->count = count;
    return ret;
}

void pdl_list_destroy(struct pdl_list *list) {
    struct pdl_list_node *node = list->head;
    while (node) {
        struct pdl_list_node *temp = node;
        node = node->next;
        list->free(temp);
    }
    list->free(list);
}

struct pdl_list_node *pdl_list_addToHead(struct pdl_list *list, void *val) {
    struct pdl_list_node *node = list->malloc(sizeof(struct pdl_list_node));
    if (!node) {
        return NULL;
    }

    node->val = val;
    struct pdl_list_node *head = list->head;
    head->prev = node;
    node->prev = NULL;
    node->next = head;
    list->head = node;
    list->count++;

    return node;
}

struct pdl_list_node *pdl_list_addToTail(struct pdl_list *list, void *val) {
    struct pdl_list_node *node = list->malloc(sizeof(struct pdl_list_node));
    if (!node) {
        return NULL;
    }

    node->val = val;
    struct pdl_list_node *tail = list->tail;
    tail->next = node;
    node->prev = tail;
    node->next = NULL;
    list->tail = node;
    list->count++;

    return node;
}

struct pdl_list_node *pdl_list_insertBefore(struct pdl_list *list, struct pdl_list_node *node, void *val) {
    struct pdl_list_node *insert = list->malloc(sizeof(struct pdl_list_node));
    if (!insert) {
        return NULL;
    }

    insert->val = val;
    struct pdl_list_node *prev = node->prev;
    if (prev) {
        prev->next = insert;
    } else {
        list->head = insert;
    }
    node->prev = insert;
    insert->prev = prev;
    insert->next = node;
    list->count++;

    return node;
}

struct pdl_list_node *pdl_list_insertAfter(struct pdl_list *list, struct pdl_list_node *node, void *val) {
    struct pdl_list_node *insert = list->malloc(sizeof(struct pdl_list_node));
    if (!insert) {
        return NULL;
    }

    insert->val = val;
    struct pdl_list_node *next = node->next;
    if (next) {
        next->prev = insert;
    } else {
        list->tail = insert;
    }
    node->next = insert;
    insert->prev = node;
    insert->next = next;
    list->count++;

    return node;
}

void pdl_list_remove(struct pdl_list *list, struct pdl_list_node *node) {
    struct pdl_list_node *prev = node->prev;
    struct pdl_list_node *next = node->next;
    if (prev) {
        prev->next = node->next;
    } else {
        list->head = node->next;
    }
    if (next) {
        next->prev = node->prev;
    } else {
        list->tail = node->prev;
    }
    list->free(node);
    list->count--;
}

void pdl_list_print(struct pdl_list *list) {
    struct pdl_list_node *node = list->head;
    printf("printList: ");
    while (node) {
        printf("%p", node->val);
        node = node->next;
        if (node) {
            printf(" ");
        }
    }
    printf("\n");
}
