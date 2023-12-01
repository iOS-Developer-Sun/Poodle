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
#import "pdl_list.h"
#import "pdl_thread_storage.h"
#import "pdl_trampoline.h"

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
    void *super_receiver;
    void *super_class;
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
extern void PDLMethodEntry_stret(__unsafe_unretained id, SEL);
extern void PDLMethodEntryFull(__unsafe_unretained id, SEL);
extern void PDLMethodEntryFull_stret(__unsafe_unretained id, SEL);

__attribute__((visibility("hidden")))
void PDLMethodBefore(__unsafe_unretained id self, SEL _cmd) {
    struct PDLImplementationInterceptorData *interceptorData = (struct PDLImplementationInterceptorData *)(void *)_cmd;
    PDLImplementationInterceptorRecover(_cmd);
    PDLMethodActions *actions = _data;
    void(*beforeAction)(id, struct PDLImplementationInterceptorData *) = (typeof(beforeAction))actions->beforeAction;
    if (beforeAction) {
        beforeAction(self, interceptorData);
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

    struct PDLImplementationInterceptorData *interceptorData = (struct PDLImplementationInterceptorData *)(void *)_cmd;
    PDLImplementationInterceptorRecover(_cmd);
    PDLMethodActions *actions = _data;
    void(*beforeAction)(id, struct PDLImplementationInterceptorData *) = (typeof(beforeAction))actions->beforeAction;
    if (beforeAction) {
        beforeAction(self, interceptorData);
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
    struct PDLImplementationInterceptorData *interceptorData = (struct PDLImplementationInterceptorData *)(void *)_cmd;
    pdl_list_destroy_node(list, node);
    PDLImplementationInterceptorRecover(_cmd);
    PDLMethodActions *actions = _data;
    void(*afterAction)(id, struct PDLImplementationInterceptorData *) = (typeof(afterAction))actions->afterAction;
    if (afterAction) {
        afterAction(self, interceptorData);
    }
    return lr;
}

static bool pdl_initialize(void) {
    static bool enabled = false;
    static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_lock(&lock);
    static bool init = false;
    if (!init) {
        pdl_thread_storage_register(_pdl_storage_key, &pdl_methods_list_destroy);
        init = true;
        enabled = pdl_thread_storage_enabled();
    }
    pthread_mutex_unlock(&lock);
    return enabled;
}

static NSInteger addInstanceMethodsActions(Class aClass, Class baseClass, IMP _Nullable beforeAction, IMP _Nullable afterAction, BOOL(^_Nullable methodFilter)(SEL selector)) {
#ifndef __LP64__
    return 0;
#else
    NSUInteger ret = -1;
    if (!pdl_initialize()) {
        return -1;
    }

    if (!beforeAction && !afterAction) {
        return 0;
    }

    PDLMethodActions *actions = malloc(sizeof(PDLMethodActions));
    if (!actions) {
        return -1;
    }

    actions->beforeAction = beforeAction;
    actions->afterAction = afterAction;

    IMP imp = (IMP)&PDLMethodEntry;
    IMP imp_stret = (IMP)&PDLMethodEntry_stret;
    if (afterAction) {
        imp = (IMP)&PDLMethodEntryFull;
        imp_stret = (IMP)&PDLMethodEntryFull_stret;
    }

    ret = 0;
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(baseClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        Method method = methodList[i];
        SEL selector = method_getName(method);
        if (methodFilter && !methodFilter(selector)) {
            continue;
        }

        IMP (^block)(NSNumber *__autoreleasing *, void **) = ^IMP (NSNumber *__autoreleasing *isStructRetNumber, void **data) {
            NSNumber *number = *isStructRetNumber;
            if (number) {
                *data = actions;
                if (number.boolValue) {
                    return imp_stret;
                } else {
                    return imp;
                }
            } else {
                return NULL;
            }
        };
        BOOL result = NO;
        if (aClass == baseClass) {
            result = pdl_interceptMethod(aClass, method, nil, ^IMP(NSNumber *__autoreleasing *isStructRetNumber, void **data) {
                return block(isStructRetNumber, data);
            });
        } else {
            result = pdl_intercept(aClass, selector, nil, ^IMP(BOOL exists, NSNumber **isStructRetNumber, Method method, void **data) {
                return block(isStructRetNumber, data);
            });
        }

        if (result) {
            ret++;
        }
    }
    free(methodList);
    if (ret == 0) {
        free(actions);
    }
    return ret;
#endif
}

#pragma mark - public methods

+ (NSInteger)pdl_addInstanceMethodsBeforeAction:(IMP)beforeAction afterAction:(IMP)afterAction {
    return [self pdl_addInstanceMethodsBeforeAction:beforeAction afterAction:afterAction methodFilter:nil];
}

+ (NSInteger)pdl_addInstanceMethodsBeforeAction:(IMP)beforeAction afterAction:(IMP)afterAction methodFilter:(BOOL(^)(SEL selector))methodFilter {
    return addInstanceMethodsActions(self, self, beforeAction, afterAction, methodFilter);
}

NSInteger pdl_addInstanceMethodsActions(Class aClass, Class _Nullable baseClass, IMP _Nullable beforeAction, IMP _Nullable afterAction, BOOL(^_Nullable methodFilter)(SEL selector)) {
    BOOL(^_Nullable filter)(SEL selector) = nil;
    if (methodFilter) {
        filter = ^BOOL(SEL selector) {
            return methodFilter(selector);
        };
    }
    return addInstanceMethodsActions(aClass, baseClass ?: aClass, beforeAction, afterAction, filter);
}

BOOL pdl_addInstanceMethodActions(Class aClass, Method method, IMP _Nullable beforeAction, IMP _Nullable afterAction) {
#ifndef __LP64__
    return NO;
#else
    BOOL ret = NO;
    if (!pdl_initialize()) {
        return NO;
    }

    if (!beforeAction && !afterAction) {
        return NO;
    }

    PDLMethodActions *actions = malloc(sizeof(PDLMethodActions));
    if (!actions) {
        return NO;
    }

    actions->beforeAction = beforeAction;
    actions->afterAction = afterAction;

    IMP imp = (IMP)&PDLMethodEntry;
    IMP imp_stret = (IMP)&PDLMethodEntry_stret;
    if (afterAction) {
        imp = (IMP)&PDLMethodEntryFull;
        imp_stret = (IMP)&PDLMethodEntryFull_stret;
    }

    BOOL result = pdl_interceptMethod(aClass, method, nil, ^IMP(NSNumber *__autoreleasing *isStructRetNumber, void **data) {
        NSNumber *number = *isStructRetNumber;
        if (number) {
            *data = actions;
            if (number.boolValue) {
                return imp_stret;
            } else {
                return imp;
            }
        } else {
            return NULL;
        }
    });

    if (result) {
        ret = YES;
    }
    if (!ret) {
        free(actions);
    }
    return ret;
#endif
}

#pragma mark - Swift

struct PDLTargetClassMetadata {
    void *metaClass;
    void *superClass;
    void *cacheData1;
    void *cacheData2;
    void *data;
    uint32_t flags;
    uint32_t instanceAddressPoint;
    uint32_t instanceSize;
    uint16_t instanceAlignMask;
    uint16_t reserved;
    uint32_t classSize;
    uint32_t classAddressPoint;
    void *description;
    IMP ivarDestroyer;

    // After this come the class members, laid out as follows:
    //   - class members for the superclass (recursively)
    //   - metadata reference for the parent, if applicable
    //   - generic parameters for this class
    //   - class variables (if we choose to support these)
    //   - "tabulated" virtual methods
};

static void swiftBefore(void *original, void *data) {
    PDLSwiftMethodAction action = ((void **)data)[0];
    if (action) {
        action(original);
    }
}

static void swiftAfter(void *original, void *data) {
    PDLSwiftMethodAction action = ((void **)data)[1];
    if (action) {
        action(original);
    }
}

NSInteger pdl_addSwiftMethodActions(Class aClass, PDLSwiftMethodAction _Nullable beforeAction, PDLSwiftMethodAction _Nullable afterAction, BOOL(^_Nullable methodFilter)(void *imp)) {
    NSInteger count = 0;
    struct PDLTargetClassMetadata *meta = (__bridge struct PDLTargetClassMetadata *)(aClass);
    void **begin = (void **)&meta->ivarDestroyer;
    void **end = ((void *)meta) - meta->classAddressPoint + meta->classSize;
    void **data = NULL;
    for (void **current = begin; current < end; current++) {
        IMP imp = *current;
        BOOL isValid = YES;
        if (methodFilter) {
            isValid = methodFilter(imp);
        }
        if (!isValid) {
            continue;
        }

        if (!data) {
            data = malloc(sizeof(void *) * 2);
            data[0] = beforeAction;
            data[1] = afterAction;
        }

        IMP *trampoline = pdl_trampoline(imp, &swiftBefore, &swiftAfter, data);
        *current = trampoline;
        count++;
    }

    return count;
}

@end
