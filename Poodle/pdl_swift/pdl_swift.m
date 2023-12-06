//
//  pdl_swift.m
//  Poodle
//
//  Created by Poodle on 23-10-05.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "pdl_swift.h"
#import "pdl_utils.h"
#import "pdl_hook.h"
#import <mach-o/ldsyms.h>
#import <dlfcn.h>
#import <pthread/pthread.h>

//__attribute__((naked))
//void *pdl_swift_get_object(void) {
//#if defined(__arm64__)
//    __asm__ volatile ("mov x0, x20 \n ret");
//#elif defined(__x86_64__)
//    __asm__ volatile ("mov %r13, %rax \n ret");
//#endif
//}

void *pdl_swift_validate_object(void *address) {
//    void *header = NULL;
//    pdl_malloc_find(address, NULL, &header);
//    return header;

    BOOL isNotPointer = address < (void *)0x100000000UL || address > (void *)0x00007FFFFFFFFFFFUL;
    if (isNotPointer) {
        return NULL;
    }

    pthread_t thread = pthread_self();
    void *threadAddress = pthread_get_stackaddr_np(thread);
    size_t threadSize = pthread_get_stacksize_np(thread);
    BOOL isInStack = address < threadAddress && address > (threadAddress - threadSize);
    if (isInStack) {
        return NULL;
    }

    if (((unsigned long)address & 0xFFFFFFFF) == 0) {
        return NULL;
    }

    return address;
}

#pragma mark -

static pdl_array_t pdl_swift_actions(void *key) {
    static pdl_dictionary_t dictionary = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = pdl_dictionary_create(NULL);
    });

    void **value = pdl_dictionary_get(dictionary, key);
    if (!value) {
        pdl_array_t actions = pdl_array_create(0);
        value = &actions;
        pdl_dictionary_set(dictionary, key, value);
    }

    return *value;
}

static pdl_dictionary_t pdl_swift_originals(void) {
    static pdl_dictionary_t dictionary = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = pdl_dictionary_create(NULL);
    });
    return dictionary;
}

static void pdl_swift_setOriginal(void *key, void *original) {
    pdl_dictionary_set(pdl_swift_originals(), key, &original);
}

static void *pdl_swift_getOriginal(void *key) {
    void **value = pdl_dictionary_get(pdl_swift_originals(), key);
    return *value;
}

static bool pdl_swift_setup(char *name, void *custom) {
    void *handle = dlopen(NULL, RTLD_GLOBAL | RTLD_NOW);
    void *original = dlsym(handle, name);
    dlclose(handle);
    int count = 1;
    pdl_hook_item items[count];
    items[0] = (pdl_hook_item) {
        name,
        NULL,
        custom,
        NULL,
    };
    int ret = pdl_hook(items, count);
    if (ret != count) {
        return false;
    }

    pdl_swift_setOriginal(custom, original);
    return true;
}

static bool pdl_swift_registerAction(void *action, char *name, void *custom) {
    if (!action) {
        return false;
    }

    bool ret = pdl_swift_setup(name, custom);
    if (!ret) {
        return false;
    }

    pdl_array_t actions = pdl_swift_actions(custom);
    if (!actions) {
        return false;
    }
    pdl_array_add(actions, action);
    return true;
}

#pragma mark - swift_allocObject

extern void *swift_allocObject(void *cls, size_t requiredSize, size_t requiredAlignmentMask);
static void *pdl_swift_allocObject(void *cls, size_t requiredSize, size_t requiredAlignmentMask) {
    void *k = &pdl_swift_allocObject;
    typeof(&pdl_swift_allocObject) original = pdl_swift_getOriginal(k);
    void *ret = original(cls, requiredSize, requiredAlignmentMask);

    pdl_array_t actions = pdl_swift_actions(k);
    if (actions) {
        unsigned int count = pdl_array_count(actions);
        for (unsigned int i = 0; i < count; i++) {
            void(*action)(void *cls, size_t requiredSize, size_t requiredAlignmentMask, void *ret) = pdl_array_get(actions, i);
            if (action) {
                action(cls, requiredSize, requiredAlignmentMask, ret);
            }
        }
    }
    return ret;
}

bool pdl_swift_registerAllocAction(void(*action)(void *cls, size_t requiredSize, size_t requiredAlignmentMask, void *ret)) {
    return pdl_swift_registerAction((void *)action, "swift_allocObject", (void *)&pdl_swift_allocObject);
}

#pragma mark - swift_beginAccess

__attribute__((swiftcall))
extern void *swift_beginAccess(void *address, void **result, int8_t flags, int64_t reserved, __attribute__((swift_context)) void *object);

__attribute__((swiftcall))
static void *pdl_swift_beginAccess(void *address, void **result, int8_t flags, int64_t reserved, __attribute__((swift_context)) void *object) {
    void *k = &pdl_swift_beginAccess;
    typeof(&pdl_swift_beginAccess) original = pdl_swift_getOriginal(k);
    void *ret = original(address, result, flags, reserved, object);

    pdl_array_t actions = pdl_swift_actions(k);
    if (actions) {
        unsigned int count = pdl_array_count(actions);
        for (unsigned int i = 0; i < count; i++) {
            void(*action)(void *address, void **result, int8_t flags, int64_t reserved, void *ret, void *object) = pdl_array_get(actions, i);
            if (action) {
                action(address, result, flags, reserved, ret, object);
            }
        }
    }
    return ret;
}

bool pdl_swift_registerAccessBeginAction(void(*action)(void *address, void **result, int8_t flags, int64_t reserved, void *ret, void *object)) {
    return pdl_swift_registerAction((void *)action, "swift_beginAccess", (void *)&pdl_swift_beginAccess);
}

#pragma mark - swift_endAccess

__attribute__((swiftcall))
extern void *swift_endAccess(void **result, __attribute__((swift_context)) void *object);

__attribute__((swiftcall))
static void *pdl_swift_endAccess(void **result, __attribute__((swift_context)) void *object) {
    void *k = &pdl_swift_endAccess;
    typeof(&pdl_swift_endAccess) original = pdl_swift_getOriginal(k);
    void *ret = original(result, object);

    pdl_array_t actions = pdl_swift_actions(k);
    if (actions) {
        unsigned int count = pdl_array_count(actions);
        for (unsigned int i = 0; i < count; i++) {
            void(*action)(void **result, void *ret, void *object) = pdl_array_get(actions, i);
            if (action) {
                action(result, ret, object);
            }
        }
    }
    return ret;
}

bool pdl_swift_registerAccessEndAction(void(*action)(void **result, void *ret, void *object)) {
    return pdl_swift_registerAction((void *)action, "swift_endAccess", (void *)&pdl_swift_endAccess);
}

#pragma mark - Swift.Dictionary.subscript.getter

__attribute__((swiftcall))
extern void $sSDyq_Sgxcig(__attribute__((swift_indirect_result))void **indirect_result, void **key, void *dictionary, void **meta, void *a, void *b, __attribute__((swift_context)) void **context);

__attribute__((swiftcall))
static void pdl_sSDyq_Sgxcig(__attribute__((swift_indirect_result))void **indirect_result, void **key, void *dictionary, void **meta, void *a, void *b, __attribute__((swift_context)) void **context) {
    void *k = &pdl_sSDyq_Sgxcig;
    typeof(&pdl_sSDyq_Sgxcig) original = pdl_swift_getOriginal(k);
    original(indirect_result, key, dictionary, meta, a, b, context);

    pdl_array_t actions = pdl_swift_actions(k);
    if (actions) {
        unsigned int count = pdl_array_count(actions);
        for (unsigned int i = 0; i < count; i++) {
            void(*action)(void **key, void *object, void **meta) = pdl_array_get(actions, i);
            if (action) {
                action(key, dictionary, meta);
            }
        }
    }
}

bool pdl_swift_registerDictionaryGetterAction(void(*action)(void **key, void *object, void **meta)) {
    return pdl_swift_registerAction((void *)action, "$sSDyq_Sgxcig", (void *)&pdl_sSDyq_Sgxcig);
}

#pragma mark - Swift.Dictionary.subscript.setter

__attribute__((swiftcall))
extern void $sSDyq_Sgxcis(void **value, void **key, void **meta, __attribute__((swift_context)) void **context);

__attribute__((swiftcall))
static void pdl_sSDyq_Sgxcis(void **value, void **key, void **meta, __attribute__((swift_context)) void **context) {
    void *object = *context;
    void *k = &pdl_sSDyq_Sgxcis;
    typeof(&pdl_sSDyq_Sgxcis) original = pdl_swift_getOriginal(k);
    original(value, key, meta, context);
    object = *context;

    pdl_array_t actions = pdl_swift_actions(k);
    if (actions) {
        unsigned int count = pdl_array_count(actions);
        for (unsigned int i = 0; i < count; i++) {
            void(*action)(void **value, void **key, void **meta, void *object) = pdl_array_get(actions, i);
            if (action) {
                action(value, key, meta, object);
            }
        }
    }
}

bool pdl_swift_registerDictionarySetterAction(void(*action)(void **value, void **key, void **meta, void *object)) {
    return pdl_swift_registerAction((void *)action, "$sSDyq_Sgxcis", (void *)&pdl_sSDyq_Sgxcis);
}

#pragma mark - Swift.Dictionary.subscript.modifier

__attribute__((swiftcall))
extern pdl_swift_dictionary_modify_ret $sSDyq_SgxciM(void **value, void **key, void **meta, __attribute__((swift_context)) void **context);

__attribute__((swiftcall))
static pdl_swift_dictionary_modify_ret pdl_sSDyq_SgxciM(void **value, void **key, void **meta, __attribute__((swift_context)) void **context) {
    void *object = *context;
    void *k = &pdl_sSDyq_SgxciM;
    typeof(&pdl_sSDyq_SgxciM) original = pdl_swift_getOriginal(k);
    pdl_swift_dictionary_modify_ret ret = original(value, key, meta, context);

    pdl_array_t actions = pdl_swift_actions(k);
    if (actions) {
        unsigned int count = pdl_array_count(actions);
        for (unsigned int i = 0; i < count; i++) {
            void(*action)(void **value, void **key, void **meta, pdl_swift_dictionary_modify_ret ret, void *object) = pdl_array_get(actions, i);
            if (action) {
                action(value, key, meta, ret, object);
            }
        }
    }
    return ret;
}

bool pdl_swift_registerDictionaryModifyAction(void(*action)(void **value, void **key, void **meta, pdl_swift_dictionary_modify_ret ret, void *object)) {
    return pdl_swift_registerAction((void *)action, "$sSDyq_SgxciM", (void *)&pdl_sSDyq_SgxciM);
}

// sSayxSiciM
