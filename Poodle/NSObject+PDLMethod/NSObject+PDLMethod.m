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

typedef struct {
    __unsafe_unretained id self;
    struct PDLImplementationInterceptorData *data;
    void *lr;
} PDLMethodData;

typedef struct {
    pdl_list_node node;
    PDLMethodData data;
} PDLMethodDataListNode;

typedef struct {
    IMP beforeAction;
    IMP afterAction;
} PDLMethodActions;

#pragma mark - thread

static void *_pdl_storage_key = &_pdl_storage_key;

__unused static void pdl_methods_list_destroy(void *arg) {
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

#pragma mark - before && after

extern void PDLMethodEntry(__unsafe_unretained id, SEL);
extern void PDLMethodEntryFull(__unsafe_unretained id, SEL);

__attribute__((visibility("hidden")))
void PDLMethodBefore(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    PDLMethodActions *actions = _data;
    void(*beforeAction)(id, SEL) = (typeof(beforeAction))actions->beforeAction;
    if (beforeAction) {
        beforeAction(self, _cmd);
    }
}

__attribute__((visibility("hidden")))
void PDLMethodFullBefore(__unsafe_unretained id self, SEL _cmd, void *lr) {
    // save all
    pdl_list *list = pdl_thread_list();
    pdl_list_node *node = pdl_list_create_node(list, sizeof(PDLMethodDataListNode) - sizeof(pdl_list_node));
    PDLMethodDataListNode *data = (PDLMethodDataListNode *)node;
    data->data.self = self;
    data->data.data = (struct PDLImplementationInterceptorData *)(void *)_cmd;
    data->data.lr = lr;
    pdl_list_add_tail(list, node);

    PDLImplementationInterceptorRecover(_cmd);
    PDLMethodActions *actions = _data;
    void(*beforeAction)(id, SEL) = (typeof(beforeAction))actions->beforeAction;
    if (beforeAction) {
        beforeAction(self, _cmd);
    }
}

__attribute__((visibility("hidden")))
void *PDLMethodFullAfter(void) {
    pdl_list *list = pdl_thread_list();
    pdl_list_node *node = list->tail;
    pdl_list_remove(list, node);
    PDLMethodDataListNode *data = (PDLMethodDataListNode *)node;
    __unsafe_unretained id self = data->data.self;
    SEL _cmd = (SEL)(void *)data->data.data;
    void *lr = data->data.lr;
    pdl_list_destroy_node(list, node);
    PDLImplementationInterceptorRecover(_cmd);
    PDLMethodActions *actions = _data;
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

+ (NSInteger)pdl_addInstanceMethodsBeforeAction:(IMP)beforeAction afterAction:(IMP)afterAction {
    return [self pdl_addInstanceMethodsBeforeAction:beforeAction afterAction:afterAction methodFilter:nil];
}

+ (NSInteger)pdl_addInstanceMethodsBeforeAction:(IMP)beforeAction afterAction:(IMP)afterAction methodFilter:(BOOL(^)(SEL selector))methodFilter {
    NSUInteger ret = -1;
#ifdef __arm64__
    pdl_thread_storage_register(_pdl_storage_key, &pdl_methods_list_destroy);
    if (!pdl_thread_storage_enabled()) {
        return -1;
    }

    PDLMethodActions *actions = malloc(sizeof(PDLMethodActions));
    if (!actions) {
        return -1;
    }

    if (!beforeAction && !afterAction) {
        return 0;
    }

    actions->beforeAction = beforeAction;
    actions->afterAction = afterAction;

    IMP imp = (IMP)&PDLMethodEntry;
    if (afterAction) {
        imp = (IMP)&PDLMethodEntryFull;
    }

    ret = 0;
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(self, &count);
    for (unsigned int i = 0; i < count; i++) {
        Method method = methodList[i];
        SEL selector = method_getName(method);
        if (methodFilter && !methodFilter(selector)) {
            continue;
        }

        BOOL result = [self pdl_interceptSelector:selector withInterceptorImplementation:imp isStructRet:nil addIfNotExistent:NO data:actions];
        if (result) {
            ret++;
        }
    }
    free(methodList);
    if (ret == 0) {
        free(actions);
    }
#endif
    return ret;
}

@end