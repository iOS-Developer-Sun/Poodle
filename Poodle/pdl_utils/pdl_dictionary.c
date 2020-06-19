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

typedef struct pdl_dictionary {
    pdl_hash hash;
    unsigned int count_limit;
    pdl_list *limit_list;
    pdl_hash limit_hash;
} pdl_dictionary;

pdl_dictionary_t pdl_dictionary_create(void) {
    return pdl_dictionary_create_with_count_limit_and_malloc_pointers(0, NULL, NULL);
}

pdl_dictionary_t pdl_dictionary_create_with_count_limit(unsigned int count_limit) {
    return pdl_dictionary_create_with_count_limit_and_malloc_pointers(count_limit, NULL, NULL);
}

pdl_dictionary_t pdl_dictionary_create_with_malloc_pointers(void *(*malloc_ptr)(size_t), void(*free_ptr)(void *)) {
    return pdl_dictionary_create_with_count_limit_and_malloc_pointers(0, malloc_ptr, free_ptr);
}

pdl_dictionary_t pdl_dictionary_create_with_count_limit_and_malloc_pointers(unsigned int count_limit, void *(*malloc_ptr)(size_t), void(*free_ptr)(void *)) {
    void *(*m_ptr)(size_t) = malloc_ptr ?: &malloc;
    void(*f_ptr)(void *) = free_ptr ?: &free;
    pdl_dictionary *dict = m_ptr(sizeof(pdl_dictionary));
    if (!dict) {
        return NULL;
    }

    dict->hash.map = NULL;
    dict->hash.malloc = m_ptr;
    dict->hash.free = f_ptr;
    dict->count_limit = count_limit;
    if (count_limit > 0) {
        pdl_list *cache_list = pdl_list_create(m_ptr, f_ptr);
        if (!cache_list) {
            f_ptr(dict);
            return NULL;
        }
        dict->limit_list = cache_list;
        dict->limit_hash.map = NULL;
        dict->limit_hash.malloc = m_ptr;
        dict->limit_hash.free = f_ptr;
    }

    return dict;
}

void **pdl_dictionary_get(pdl_dictionary_t dictionary, void *key) {
    if (!key) {
        return NULL;
    }

    pdl_dictionary *dict = dictionary;
    pdl_hash *hash = &(dict->hash);
    void **value = pdl_hash_get_value(hash, key);

    if (dict->count_limit > 0) {
        pdl_hash *cache_hash = &(dict->limit_hash);
        pdl_list_node **node_value = (pdl_list_node **)pdl_hash_get_value(cache_hash, key);
        if (node_value) {
            pdl_list_node *node = *node_value;
            pdl_list *cache_list = dict->limit_list;
            pdl_list_remove(cache_list, node);
            pdl_list_add_head(cache_list, node);
        }
    }

    return value;
}

void pdl_dictionary_remove(pdl_dictionary_t dictionary, void *key) {
    if (!key) {
        return;
    }

    pdl_dictionary *dict = dictionary;
    pdl_hash *hash = &(dict->hash);
    void **value = pdl_hash_get_value(hash, key);

    if (!value) {
        return;
    }

    pdl_hash_delete(hash, key);

    if (dict->count_limit > 0) {
        pdl_hash *cache_hash = &(dict->limit_hash);
        pdl_list_node *node = *(pdl_list_node **)pdl_hash_get_value(cache_hash, key);
        pdl_list *cache_list = dict->limit_list;
        pdl_list_remove(cache_list, node);
        pdl_list_destroy_node(cache_list, node);
        pdl_hash_delete(cache_hash, key);
    }
}

void pdl_dictionary_remove_all(pdl_dictionary_t dictionary) {
    pdl_dictionary *dict = dictionary;
    pdl_hash *hash = &(dict->hash);
    pdl_hash_delete_all(hash);

    if (dict->count_limit > 0) {
        pdl_hash *cache_hash = &(dict->limit_hash);
        pdl_hash_delete_all(cache_hash);
        pdl_list *cache_list = dict->limit_list;
        pdl_list_remove_and_destroy_all(cache_list);
    }
}

void pdl_dictionary_set(pdl_dictionary_t dictionary, void *key, void *value) {
    if (!key) {
        return;
    }

    pdl_dictionary *dict = dictionary;
    pdl_hash *hash = &(dict->hash);

    void **original_value = pdl_hash_get_value(hash, key);
    if (original_value) {
        pdl_hash_delete(hash, key);
    }

    if (value) {
        pdl_hash_set_value(hash, key, value);
    }

    if (dict->count_limit > 0) {
        pdl_hash *cache_hash = &(dict->limit_hash);
        pdl_list_node **node_value = (pdl_list_node **)pdl_hash_get_value(cache_hash, key);
        pdl_list *cache_list = dict->limit_list;
        if (node_value) {
            pdl_list_node *node = *node_value;
            pdl_list_remove(cache_list, node);
            if (value) {
                pdl_list_add_head(cache_list, node);
            } else {
                pdl_list_destroy_node(cache_list, node);
                pdl_hash_delete(cache_hash, key);
            }
        } else {
            if (value) {
                pdl_list_node *node = pdl_list_create_node(cache_list, key);
                pdl_list_add_head(cache_list, node);
                pdl_hash_set_value(cache_hash, key, node);
            }
        }

        if (pdl_list_length(cache_list) > dict->count_limit) {
            pdl_list_node *last = cache_list->tail;
            void *last_key = last->val;
            pdl_dictionary_remove(dict, last_key);
        }
    }
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
    if (dict->count_limit > 0) {
        pdl_hash *cache_hash = &(dict->limit_hash);
        pdl_hash_destroy(cache_hash);
        pdl_list *cache_list = dict->limit_list;
        pdl_list_destroy(cache_list);
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
        if (dict->count_limit > 0) {
            if (i == 0) {
                node = dict->limit_list->head;
            }
            key = node->val;
            node = node->next;
        }
        void *value = pdl_dictionary_get(dictionary, key);
        printf(" <%p : %p>", key, value);
    }
    printf("\n");
    hash->free(keys);
}
