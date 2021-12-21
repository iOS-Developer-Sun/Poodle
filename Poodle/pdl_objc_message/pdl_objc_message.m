//
//  pdl_objc_message.m
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_objc_message.h"
#include <pthread.h>
#include "pdl_list.h"
#include "pdl_thread_storage.h"

#ifndef __i386__

#pragma mark -

typedef struct {
    union {
        __unsafe_unretained id self;
        struct objc_super *super;
    } obj;
    SEL _cmd;
    void *lr;
} pdl_objc_message_data;

typedef struct {
    pdl_list_node node;
    pdl_objc_message_data data;
} pdl_objc_message_data_list_node;

#pragma mark - thread

static void *_pdl_storage_key = &_pdl_storage_key;

static void pdl_objc_message_list_destroy(void *arg) {
    pdl_list *list = (typeof(list))arg;
    assert(list->count == 0);
    pdl_list_destroy(list);
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

__unused
static void pdl_objc_message_initialize(void) {
    static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_lock(&lock);
    static bool init = false;
    if (!init) {
        pdl_thread_storage_register(_pdl_storage_key, &pdl_objc_message_list_destroy);
        init = true;
    }
    pthread_mutex_unlock(&lock);
}

#pragma mark - getter && setter

static void(*_pdl_objc_msgSend_before_action)(__unsafe_unretained id self, SEL _cmd) = NULL;
void(*pdl_objc_message_msgSend_before_action(void))(__unsafe_unretained id self, SEL _cmd) {
    return _pdl_objc_msgSend_before_action;
}
void pdl_objc_message_set_msgSend_before_action(void(*pdl_objc_msgSend_before_action)(__unsafe_unretained id self, SEL _cmd)) {
    _pdl_objc_msgSend_before_action = pdl_objc_msgSend_before_action;
}

static void(*_pdl_objc_msgSendSuper_before_action)(struct objc_super *super, SEL _cmd) = NULL;
void(*pdl_objc_message_msgSendSuper_before_action(void))(struct objc_super *super, SEL _cmd) {
    return _pdl_objc_msgSendSuper_before_action;
}
void pdl_objc_message_set_msgSendSuper_before_action(void(*pdl_objc_msgSendSuper_before_action)(struct objc_super *super, SEL _cmd)) {
    _pdl_objc_msgSendSuper_before_action = pdl_objc_msgSendSuper_before_action;
}

#ifndef __i386__

static void(*_pdl_objc_msgSend_after_action)(__unsafe_unretained id self, SEL _cmd) = NULL;
void(*pdl_objc_message_msgSend_after_action(void))(__unsafe_unretained id self, SEL _cmd) {
    return _pdl_objc_msgSend_after_action;
}
void pdl_objc_message_set_msgSend_after_action(void(*pdl_objc_msgSend_after_action)(__unsafe_unretained id self, SEL _cmd)) {
    pdl_objc_message_initialize();
    _pdl_objc_msgSend_after_action = pdl_objc_msgSend_after_action;
}

static void(*_pdl_objc_msgSendSuper_after_action)(struct objc_super *super, SEL _cmd) = NULL;
void(*pdl_objc_message_msgSendSuper_after_action(void))(struct objc_super *super, SEL _cmd) {
    return _pdl_objc_msgSendSuper_after_action;
}
void pdl_objc_message_set_msgSendSuper_after_action(void(*pdl_objc_msgSendSuper_after_action)(struct objc_super *super, SEL _cmd)) {
    pdl_objc_message_initialize();
    _pdl_objc_msgSendSuper_after_action = pdl_objc_msgSendSuper_after_action;
}

#endif

#pragma mark - callbacks

__attribute__((visibility("hidden")))
void pdl_objc_msgSend_before(__unsafe_unretained id self, SEL _cmd) {
    typeof(_pdl_objc_msgSend_before_action) function = _pdl_objc_msgSend_before_action;
    if (function) {
        function(self, _cmd);
    }
}

__attribute__((visibility("hidden")))
void pdl_objc_msgSendFull_before(__unsafe_unretained id self, SEL _cmd, void *lr) {
    pdl_list *list = pdl_thread_list();
    pdl_list_node *node = pdl_list_create_node(list, sizeof(pdl_objc_message_data_list_node) - sizeof(pdl_list_node));
    pdl_objc_message_data_list_node *data = (pdl_objc_message_data_list_node *)node;
    data->data.obj.self = self;
    data->data._cmd = _cmd;
    data->data.lr = lr;
    pdl_list_add_tail(list, node);
    typeof(_pdl_objc_msgSend_before_action) function = _pdl_objc_msgSend_before_action;
    if (function) {
        function(self, _cmd);
    }
}

__attribute__((visibility("hidden")))
void pdl_objc_msgSendSuper_before(struct objc_super *super, SEL _cmd) {
    typeof(_pdl_objc_msgSendSuper_before_action) function = _pdl_objc_msgSendSuper_before_action;
    if (function) {
        function(super, _cmd);
    }
}

#ifndef __i386__

__attribute__((visibility("hidden")))
void *pdl_objc_msgSendFull_after(void) {
    pdl_list *list = pdl_thread_list();
    pdl_list_node *node = list->tail;
    pdl_list_remove(list, node);
    pdl_objc_message_data_list_node *data = (pdl_objc_message_data_list_node *)node;
    __unsafe_unretained id self = data->data.obj.self;
    SEL _cmd = data->data._cmd;
    void *lr = data->data.lr;
    pdl_list_destroy_node(list, node);
    typeof(_pdl_objc_msgSend_after_action) function = _pdl_objc_msgSend_after_action;
    if (function) {
        function(self, _cmd);
    }
    return lr;
}

__attribute__((visibility("hidden")))
void pdl_objc_msgSendSuperFull_before(struct objc_super *super, SEL _cmd, void *lr) {
    pdl_list *list = pdl_thread_list();
    pdl_list_node *node = pdl_list_create_node(list, sizeof(pdl_objc_message_data_list_node) - sizeof(pdl_list_node));
    pdl_objc_message_data_list_node *data = (pdl_objc_message_data_list_node *)node;
    data->data.obj.super = super;
    data->data._cmd = _cmd;
    data->data.lr = lr;
    pdl_list_add_tail(list, node);
    typeof(_pdl_objc_msgSendSuper_before_action) function = _pdl_objc_msgSendSuper_before_action;
    if (function) {
        function(super, _cmd);
    }
}

__attribute__((visibility("hidden")))
void *pdl_objc_msgSendSuperFull_after(void) {
    pdl_list *list = pdl_thread_list();
    pdl_list_node *node = list->tail;
    pdl_list_remove(list, node);
    pdl_objc_message_data_list_node *data = (pdl_objc_message_data_list_node *)node;
    struct objc_super *super = data->data.obj.super;
    SEL _cmd = data->data._cmd;
    void *lr = data->data.lr;
    pdl_list_destroy_node(list, node);
    typeof(_pdl_objc_msgSendSuper_after_action) function = _pdl_objc_msgSendSuper_after_action;
    if (function) {
        function(super, _cmd);
    }
    return lr;
}

#endif

#pragma mark - originals

void(*pdl_objc_msgSend_original)(void) = &objc_msgSend;
void(*pdl_objc_msgSendSuper_original)(void) = &objc_msgSendSuper;
void(*pdl_objc_msgSendSuper2_original)(void) = &objc_msgSendSuper2;

#ifndef __arm64__

void(*pdl_objc_msgSend_stret_original)(void) = &objc_msgSend_stret;
void(*pdl_objc_msgSendSuper_stret_original)(void) = &objc_msgSendSuper_stret;
void(*pdl_objc_msgSendSuper2_stret_original)(void) = &objc_msgSendSuper2_stret;

#endif

#endif
