//
//  pdl_dictionary.c
//  Poodle
//
//  Created by Poodle on 2016/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_dictionary.h"
#include <stdio.h>
#include <limits.h>
#include "pdl_hash.h"
#include "pdl_list.h"

typedef struct {
    pdl_list_node node;
    void *key;
} pdl_dictionary_node;

typedef struct {
    pdl_dictionary_attr attr;
    pdl_hash hash;
    pdl_list *limit_list;
    pdl_hash limit_hash;
} pdl_dictionary;

pdl_dictionary_t pdl_dictionary_create(pdl_dictionary_attr *attr) {
    pdl_dictionary_attr attr_default = PDL_DICTIONARY_ATTR_INIT;
    if (attr) {
        attr_default = *attr;
    }

    void *(*malloc_ptr)(size_t) = attr_default.malloc ?: &malloc;
    attr_default.malloc = malloc_ptr;
    void(*free_ptr)(void *) = attr_default.free ?: &free;
    attr_default.free = free_ptr;

    pdl_dictionary *dict = malloc_ptr(sizeof(pdl_dictionary));
    if (!dict) {
        return NULL;
    }

    dict->attr = attr_default;
    dict->hash.map = NULL;
    dict->hash.malloc = malloc_ptr;
    dict->hash.free = free_ptr;
    memcpy(&(dict->hash.key_callbacks), &(attr_default.key_callbacks), sizeof(dict->hash.key_callbacks));
    memcpy(&(dict->hash.value_callbacks), &(attr_default.value_callbacks), sizeof(dict->hash.value_callbacks));

    if (attr_default.count_limit > 0) {
        pdl_list *limit_list = pdl_list_create(malloc_ptr, free_ptr);
        if (!limit_list) {
            free_ptr(dict);
            return NULL;
        }

        dict->limit_list = limit_list;
        dict->limit_hash.map = NULL;
        dict->limit_hash.malloc = malloc_ptr;
        dict->limit_hash.free = free_ptr;
        memcpy(&(dict->limit_hash.key_callbacks), &(attr_default.key_callbacks), sizeof(dict->hash.key_callbacks));
        memset(&(dict->limit_hash.value_callbacks), 0, sizeof(dict->hash.value_callbacks));
    }

    return dict;
}

void **pdl_dictionary_get(pdl_dictionary_t dictionary, void *key) {
    pdl_dictionary *dict = dictionary;
    pdl_hash *hash = &(dict->hash);
    void **value = pdl_hash_get_value(hash, key);

    if (dict->attr.count_limit > 0) {
        pdl_hash *limit_hash = &(dict->limit_hash);
        pdl_list_node **node_value = (pdl_list_node **)pdl_hash_get_value(limit_hash, key);
        if (node_value) {
            pdl_list_node *node = *node_value;
            pdl_list *limit_list = dict->limit_list;
            pdl_list_remove(limit_list, node);
            pdl_list_add_head(limit_list, node);
        }
    }

    return value;
}

void *pdl_dictionary_remove(pdl_dictionary_t dictionary, void *key) {
    pdl_dictionary *dict = dictionary;
    pdl_hash *hash = &(dict->hash);
    void **value = pdl_hash_get_value(hash, key);

    if (!value) {
        return NULL;
    }

    void *removed = *value;

    pdl_hash_delete(hash, key);

    if (dict->attr.count_limit > 0) {
        pdl_hash *limit_hash = &(dict->limit_hash);
        pdl_list_node *node = *(pdl_list_node **)pdl_hash_get_value(limit_hash, key);
        pdl_list *limit_list = dict->limit_list;
        pdl_list_remove(limit_list, node);
        pdl_list_destroy_node(limit_list, node);
        pdl_hash_delete(limit_hash, key);
    }

    return removed;
}

void pdl_dictionary_remove_all(pdl_dictionary_t dictionary) {
    pdl_dictionary *dict = dictionary;
    pdl_hash *hash = &(dict->hash);
    pdl_hash_delete_all(hash);

    if (dict->attr.count_limit > 0) {
        pdl_hash *limit_hash = &(dict->limit_hash);
        pdl_hash_delete_all(limit_hash);
        pdl_list *limit_list = dict->limit_list;
        pdl_list_remove_and_destroy_all(limit_list);
    }
}

void *pdl_dictionary_set(pdl_dictionary_t dictionary, void *key, void **value) {
    pdl_dictionary *dict = dictionary;
    pdl_hash *hash = &(dict->hash);

    void *removed = NULL;
    void **original_value = pdl_hash_get_value(hash, key);
    if (original_value) {
        removed = *original_value;
        pdl_hash_delete(hash, key);
    }

    if (value) {
        pdl_hash_set_value(hash, key, *value);
    }

    if (dict->attr.count_limit > 0) {
        pdl_hash *limit_hash = &(dict->limit_hash);
        pdl_list_node **node_value = (pdl_list_node **)pdl_hash_get_value(limit_hash, key);
        pdl_list *limit_list = dict->limit_list;
        if (node_value) {
            pdl_list_node *node = *node_value;
            pdl_list_remove(limit_list, node);
            if (value) {
                pdl_list_add_head(limit_list, node);
            } else {
                pdl_list_destroy_node(limit_list, node);
                pdl_hash_delete(limit_hash, key);
            }
        } else {
            if (value) {
                pdl_list_node *node = pdl_list_create_node(limit_list, sizeof(pdl_dictionary_node) - sizeof(pdl_list_node));
                ((pdl_dictionary_node *)node)->key = key;
                pdl_list_add_head(limit_list, node);
                pdl_hash_set_value(limit_hash, key, node);
            }
        }

        if (pdl_list_length(limit_list) > dict->attr.count_limit) {
            pdl_list_node *last = limit_list->tail;
            void *last_key = ((pdl_dictionary_node *)last)->key;
            removed = pdl_dictionary_remove(dict, last_key);
        }
    }

    return removed;
}

void pdl_dictionary_get_all_keys(pdl_dictionary_t dictionary, void ***keys, unsigned int *count) {
    pdl_dictionary *dict = dictionary;
    pdl_hash *hash = &(dict->hash);
    pdl_hash_get_all_keys(hash, keys, count);
}

void pdl_dictionary_destroy_keys(pdl_dictionary_t dictionary, void **keys) {
    pdl_dictionary *dict = dictionary;
    pdl_hash *hash = &(dict->hash);
    hash->free(keys);
}

void pdl_dictionary_destroy(pdl_dictionary_t dictionary) {
    pdl_dictionary *dict = dictionary;
    pdl_hash *hash = &(dict->hash);
    pdl_hash_destroy(hash);
    if (dict->attr.count_limit > 0) {
        pdl_hash *limit_hash = &(dict->limit_hash);
        pdl_hash_destroy(limit_hash);
        pdl_list *limit_list = dict->limit_list;
        pdl_list_destroy(limit_list);
    }
    hash->free(dictionary);
}

unsigned int pdl_dictionary_count(pdl_dictionary_t dictionary) {
    pdl_dictionary *dict = dictionary;
    pdl_hash *hash = &(dict->hash);
    unsigned int count = pdl_hash_count(hash);
    return count;
}

void pdl_dictionary_print(pdl_dictionary_t dictionary) {
    pdl_dictionary *dict = dictionary;
    pdl_hash *hash = &(dict->hash);
    unsigned int count = 0;
    void **keys = NULL;
    pdl_hash_get_all_keys(hash, &keys, &count);
    printf("[%d]", count);
    pdl_list_node *node = NULL;
    for (unsigned int i = 0; i < count; i++) {
        void *key = keys[i];
        if (dict->attr.count_limit > 0) {
            if (i == 0) {
                node = dict->limit_list->head;
            }
            key = ((pdl_dictionary_node *)node)->key;
            node = node->next;
        }
        void *value = pdl_dictionary_get(dictionary, key);
        printf(" <%p : %p>", key, value);
    }
    printf("\n");
    hash->free(keys);
}
