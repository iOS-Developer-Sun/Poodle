//
//  pdl_trampoline.c
//  Poodle
//
//  Created by Poodle on 11-8-23.
//  Copyright © 2021 Poodle. All rights reserved.
//

#include "pdl_trampoline.h"
#include <stdio.h>
#include <mach/mach_init.h>
#include <assert.h>
#include <stdlib.h>
#include <pthread.h>
#include "pdl_list.h"
#include "pdl_vm.h"
#include "pdl_thread_storage.h"
#include "pdl_pac.h"
#include "pdl_asm.h"

extern char pdl_trampoline_page_begin;
extern char pdl_trampoline_page_stubs;
extern char pdl_trampoline_page_end;
extern char pdl_trampoline_entry;

static pdl_list *pdl_page_list = NULL;
static void *_pdl_storage_key = &_pdl_storage_key;

typedef struct {
    void *entry; // pdl_trampoline_entry
    void *original;
    void(*before)(void *original, void *sp, void *data);
    void(*after)(void *original, void *sp, void *data);
    void *data;
} pdl_trampoline_object;

typedef struct {
    pdl_trampoline_object *trampoline;
} pdl_trampoline_stub;

typedef struct {
    pdl_list_node node;
    void *page_pair;
    pdl_trampoline_stub *stubs;
    int total_count;
    int current_index;
} pdl_trampoline_page;

typedef struct {
    pdl_list_node node;
    void *lr;
    pdl_trampoline_object *trampoline;
} pdl_trampoline_thread_storage_node;

static void pdl_trampoline_thread_storage_list_destroy(void *arg) {
    pdl_list *list = (typeof(list))arg;
    assert(list->count == 0);
    pdl_list_destroy(list);
}

static void pdl_trampoline_initialize(void) {
    static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_lock(&lock);
    static bool init = false;
    if (!init) {
        pdl_page_list = pdl_list_create(NULL, NULL);
        pdl_thread_storage_register(_pdl_storage_key, &pdl_trampoline_thread_storage_list_destroy);
        init = true;
    }
    pthread_mutex_unlock(&lock);
}

static pdl_trampoline_page *pdl_trampoline_available_page(void) {
    pdl_trampoline_initialize();
    if (!pdl_page_list) {
        return NULL;
    }

    pdl_trampoline_page *page = (pdl_trampoline_page *)(pdl_page_list->tail);
    if (!page || page->current_index == page->total_count) {
        page = (pdl_trampoline_page *)pdl_list_create_node(pdl_page_list, sizeof(pdl_trampoline_page) - sizeof(pdl_list_node));
        if (page) {
            void *page_pair = (void *)pdl_vm_allocate_page_pair(&pdl_trampoline_page_begin);
            if (!page_pair) {
                pdl_list_destroy_node(pdl_page_list, (pdl_list_node *)page);
                return NULL;
            }

            uintptr_t stubs_offset = (&pdl_trampoline_page_stubs - &pdl_trampoline_page_begin);
            page->page_pair = page_pair;
            page->stubs = (pdl_trampoline_stub *)(page_pair + stubs_offset);
            page->total_count = (int)((PAGE_MAX_SIZE - stubs_offset) / 8);
            page->current_index = 0;
            pdl_list_add_tail(pdl_page_list, (pdl_list_node *)page);

            assert(stubs_offset == 16);
            assert((&pdl_trampoline_page_end - &pdl_trampoline_entry) == 0);
            assert((&pdl_trampoline_page_end - &pdl_trampoline_page_begin) == PAGE_MAX_SIZE);
        }
    }

    return page;
}

static pdl_list *pdl_thread_list(void) {
    pdl_list *list = NULL;
    void **value = pdl_thread_storage_get(_pdl_storage_key);
    if (!value) {
        list = pdl_list_create(NULL, NULL);
        pdl_thread_storage_set(_pdl_storage_key, (void **)&list);
    } else {
        list = *value;
    }
    return list;
}

__attribute__((visibility("hidden")))
void *pdl_trampoline_before(pdl_trampoline_object *object, void *lr, void *sp) {
    void(*before)(void *, void *, void *) = object->before;
    void *original = object->original;
    if (before) {
        before(original, sp + PDL_ARG_BASE_OFFSET, object->data);
    }

    pdl_list *list = pdl_thread_list();
    pdl_list_node *node = pdl_list_create_node(list, sizeof(pdl_trampoline_thread_storage_node) - sizeof(pdl_list_node));
    pdl_trampoline_thread_storage_node *data = (pdl_trampoline_thread_storage_node *)node;
    data->lr = lr;
    data->trampoline = object;
    pdl_list_add_tail(list, node);

    return original;
}

__attribute__((visibility("hidden")))
void *pdl_trampoline_after(void *sp) {
    pdl_list *list = pdl_thread_list();
    pdl_list_node *node = list->tail;
    pdl_list_remove(list, node);
    pdl_trampoline_thread_storage_node *data = (pdl_trampoline_thread_storage_node *)node;
    void *lr = data->lr;
    pdl_trampoline_object *object = data->trampoline;
    void(*after)(void *, void *, void *) = object->after;
    void *original = object->original;
    if (after) {
        after(original, sp + PDL_ARG_BASE_OFFSET, object->data);
    }
    pdl_list_destroy_node(list, node);
    return lr;
}

void *pdl_trampoline(void *original, void(*before)(void *original, void *sp, void *data), void(*after)(void *original, void *sp, void *data), void *data) {
#ifdef __LP64__
    static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_lock(&lock);
    pdl_trampoline_page *page = pdl_trampoline_available_page();
    if (!page) {
        pthread_mutex_unlock(&lock);
        return NULL;
    }

    pdl_trampoline_object *object = malloc(sizeof(pdl_trampoline_object));
    if (!object) {
        pthread_mutex_unlock(&lock);
        return NULL;
    }

    pdl_trampoline_stub *stub = page->stubs + page->current_index;
    page->current_index++;
    pthread_mutex_unlock(&lock);

    object->entry = &pdl_trampoline_entry;
    object->original = original;
    object->before = before;
    object->after = after;
    object->data = data;

    assert(stub->trampoline == NULL);
    stub->trampoline = object;

    void *ret = ((void *)stub) + PAGE_MAX_SIZE;
    ret = pdl_ptrauth_sign_unauthenticated_function(ret, NULL);
    return ret;
#else
    return NULL;
#endif
}
