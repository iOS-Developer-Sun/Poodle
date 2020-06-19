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

unsigned int pdl_list_length(pdl_list *list) {
    return list->count;
}

pdl_list *pdl_list_create(void *(*malloc_ptr)(size_t), void(*free_ptr)(void *)) {
    void *(*m_ptr)(size_t) = malloc_ptr ?: &malloc;
    void(*f_ptr)(void *) = free_ptr ?: &free;
    pdl_list *ret = m_ptr(sizeof(pdl_list));
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

void pdl_list_destroy(pdl_list *list) {
    pdl_list_node *node = list->head;
    while (node) {
        pdl_list_node *temp = node;
        node = node->next;
        list->free(temp);
    }
    list->free(list);
}

pdl_list_node *pdl_list_create_node(pdl_list *list, void *val) {
    pdl_list_node *node = list->malloc(sizeof(struct pdl_list_node));
    if (!node) {
        return NULL;
    }

    node->val = val;
    node->prev = NULL;
    node->next = NULL;

    return node;
}

void pdl_list_destroy_node(pdl_list *list, pdl_list_node *node) {
    list->free(node);
}

pdl_list_node *pdl_list_add_head(pdl_list *list, pdl_list_node *node) {
    pdl_list_node *head = list->head;
    if (head) {
        head->prev = node;
    } else {
        list->tail = node;
    }
    node->prev = NULL;
    node->next = head;
    list->head = node;
    list->count++;

    return node;
}

pdl_list_node *pdl_list_add_tail(pdl_list *list, pdl_list_node *node) {
    pdl_list_node *tail = list->tail;
    if (tail) {
        tail->next = node;
    } else {
        list->head = node;
    }
    node->prev = tail;
    node->next = NULL;
    list->tail = node;
    list->count++;

    return node;
}

pdl_list_node *pdl_list_insert_before(pdl_list *list, pdl_list_node *before, pdl_list_node *node) {
    pdl_list_node *prev = before->prev;
    if (prev) {
        prev->next = node;
    } else {
        list->head = node;
    }
    before->prev = node;
    node->prev = prev;
    node->next = before;
    list->count++;

    return before;
}

pdl_list_node *pdl_list_insert_after(pdl_list *list, pdl_list_node *after, pdl_list_node *node) {
    pdl_list_node *next = after->next;
    if (next) {
        next->prev = node;
    } else {
        list->tail = node;
    }
    after->next = node;
    node->prev = after;
    node->next = next;
    list->count++;

    return after;
}

void pdl_list_remove(pdl_list *list, pdl_list_node *node) {
    pdl_list_node *prev = node->prev;
    pdl_list_node *next = node->next;
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
    node->prev = NULL;
    node->next = NULL;
    list->count--;
}

void pdl_list_remove_and_destroy_all(pdl_list *list) {
    pdl_list_node *current = list->head;
    while (current) {
        pdl_list_node *node = current;
        current = current->next;
        list->free(node);
    }
    list->head = NULL;
    list->tail = NULL;
    list->count = 0;
}

void pdl_list_print(pdl_list *list) {
    pdl_list_node *node = list->head;
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
