//
//  NSObject+PDLMethod.m
//  Poodle
//
//  Created by Poodle on 2020/7/15.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "NSObject+PDLMethod.h"
#import <pthread.h>
#import <objc/runtime.h>
#import "NSObject+PDLImplementationInterceptor.h"
#import "pdl_list.h"
#import "pdl_thread_storage.h"

@implementation NSObject (PDLMethod)

struct PDLMethodData {
    __unsafe_unretained id self;
    struct PDLImplementationInterceptorData *data;
    void *lr;
};

struct PDLMethodActions {
    IMP beforeAction;
    IMP afterAction;
};

#pragma mark - thread

static void *pdl_storage_key = &pdl_storage_key;

static void pdl_methods_list_destroy(void *arg) {
    pdl_list *list = (typeof(list))arg;
    assert(list->count == 0);
    pdl_list_destroy(list);
}

static pdl_list *pdl_thread_list(void) {
    pdl_list *list = NULL;
    void **value = pdl_thread_storage_get(pdl_storage_key);
    if (!value) {
        list = pdl_list_create(NULL, NULL);
        pdl_thread_storage_set(pdl_storage_key, list);
    } else {
        list = *value;
    }
    return list;
}

#pragma mark - before && after

extern void PDLMethodEntry(__unsafe_unretained id, SEL);

__attribute__((visibility("hidden")))
void PDLMethodBefore(__unsafe_unretained id self, SEL _cmd, void *lr) {
    // save all
    struct PDLMethodData *data = malloc(sizeof(struct PDLMethodData));
    if (data) {
        data->self = self;
        data->data = (struct PDLImplementationInterceptorData *)(void *)_cmd;
        data->lr = lr;

        pdl_list *list = pdl_thread_list();
        pdl_list_node *node = pdl_list_create_node(list, data);
        pdl_list_add_tail(list, node);
    }
    PDLImplementationInterceptorRecover(_cmd);
    struct PDLMethodActions *actions = _data;
    void(*beforeAction)(id, SEL) = (typeof(beforeAction))actions->beforeAction;
    if (beforeAction) {
        beforeAction(self, _cmd);
    }
}

__attribute__((visibility("hidden")))
void *PDLMethodAfter(void) {
    pdl_list *list = pdl_thread_list();
    pdl_list_node *node = list->tail;
    pdl_list_remove(list, node);
    struct PDLMethodData *data = node->val;
    pdl_list_destroy_node(list, node);
    __unsafe_unretained id self = data->self;
    SEL _cmd = (SEL)(void *)data->data;
    void *lr = data->lr;
    free(data);
    PDLImplementationInterceptorRecover(_cmd);
    struct PDLMethodActions *actions = _data;
    void(*afterAction)(id, SEL) = (typeof(afterAction))actions->afterAction;
    if (afterAction) {
//        volatile void *originalLinkRegister = NULL;
//        __asm__ volatile("nop");
//        __asm__ volatile("mov %0, lr" : "=r"(originalLinkRegister));
//        __asm__ volatile("nop");
        afterAction(self, _cmd);
//        __asm__ volatile("nop");
//        __asm__ volatile("mov lr, %0" :: "r"(originalLinkRegister));
//        __asm__ volatile("nop");
    }
    return lr;
}

#pragma mark - public methods

+ (NSUInteger)pdl_addInstanceMethodsBeforeAction:(IMP)beforeAction afterAction:(IMP)afterAction {
    return [self pdl_addInstanceMethodsBeforeAction:beforeAction afterAction:afterAction methodFilter:nil];
}

+ (NSUInteger)pdl_addInstanceMethodsBeforeAction:(IMP)beforeAction afterAction:(IMP)afterAction methodFilter:(BOOL(^)(SEL selector))methodFilter {
    pdl_thread_storage_register(pdl_storage_key, &pdl_methods_list_destroy);
    if (!pdl_thread_storage_enabled()) {
        return 0;
    }

    struct PDLMethodActions *actions = malloc(sizeof(struct PDLMethodActions));
    NSUInteger ret = 0;
    if (!actions) {
        return ret;
    }

    actions->beforeAction = beforeAction;
    actions->afterAction = afterAction;

    unsigned int count = 0;
    Method *methodList = class_copyMethodList(self, &count);
    for (unsigned int i = 0; i < count; i++) {
        Method method = methodList[i];
        SEL selector = method_getName(method);
        if (methodFilter && !methodFilter(selector)) {
            continue;
        }

        BOOL result = [self pdl_interceptSelector:selector withInterceptorImplementation:(IMP)&PDLMethodEntry isStructRet:nil addIfNotExistent:NO data:actions];
        if (result) {
            ret++;
        }
    }
    free(methodList);
    if (ret == 0) {
        free(actions);
    }
    return ret;
}

@end
