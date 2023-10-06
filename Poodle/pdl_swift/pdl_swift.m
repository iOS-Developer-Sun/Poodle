//
//  pdl_swift.m
//  Poodle
//
//  Created by Poodle on 23-10-05.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "pdl_swift.h"
#import "pdl_array.h"
#import "pdl_hook.h"
#include <mach-o/ldsyms.h>
#include <dlfcn.h>

#define PDL_SWIFT_DECLAIRATION(name, args, arg_names, return_type) \
static pdl_array_t pdl_##name##_actions = NULL;\
static void *(*pdl_##name##_original)(args) = NULL;\
static return_type pdl_##name(args) {\
    return_type ret = pdl_##name##_original(arg_names);\
    if (pdl_##name##_actions) {\
        unsigned int count = pdl_array_count(pdl_##name##_actions);\
        for (unsigned int i = 0; i < count; i++) {\
            void(*action)(args, return_type ret) = pdl_array_get(pdl_##name##_actions, i);\
            if (action) {\
                action(arg_names, ret);\
            }\
        }\
    }\
    return ret;\
}\
static void pdl_##name##_setup(void) {\
    void *handle = dlopen(NULL, RTLD_GLOBAL | RTLD_NOW);\
    pdl_##name##_original = dlsym(handle, #name);\
    dlclose(handle);\
    int count = 1;\
    pdl_hook_item items[count];\
    items[0] = (pdl_hook_item) {\
        #name,\
        NULL,\
        &pdl_##name,\
        NULL,\
    };\
    int ret = pdl_hook(items, count);\
    if (ret == count) {\
        pdl_##name##_actions = pdl_array_create(0);\
    }\
}

#define PDL_SWIFT_REGISTER_IMPLEMENTATION(function, name, args, return_type) \
bool function(void(*action)(args, return_type ret)) { \
if (!action) {\
return false;\
}\
\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
pdl_##name##_setup();\
});\
\
if (!pdl_##name##_actions) {\
return false;\
}\
\
pdl_array_add(pdl_##name##_actions, action);\
return true;\
}

#pragma mark -

extern void *swift_allocObject(void *cls, size_t requiredSize, size_t requiredAlignmentMask);
#define swift_allocObject_args void *cls, size_t requiredSize, size_t requiredAlignmentMask
#define swift_allocObject_arg_names cls, requiredSize,requiredAlignmentMask
PDL_SWIFT_DECLAIRATION(swift_allocObject, swift_allocObject_args, swift_allocObject_arg_names, void *)
PDL_SWIFT_REGISTER_IMPLEMENTATION(pdl_swift_registerAllocAction, swift_allocObject, swift_allocObject_args, void *);

extern void *swift_beginAccess(void *address, void **result, int8_t flags, int64_t reserved);
#define swift_beginAccess_args void *address, void **result, int8_t flags, int64_t reserved
#define swift_beginAccess_arg_names address, result, flags, reserved
PDL_SWIFT_DECLAIRATION(swift_beginAccess, swift_beginAccess_args, swift_beginAccess_arg_names, void *)
PDL_SWIFT_REGISTER_IMPLEMENTATION(pdl_swift_registerAccessBeginAction, swift_beginAccess, swift_beginAccess_args, void *)

extern void *swift_endAccess(void **result);
#define swift_endAccess_args void **result
#define swift_endAccess_arg_names result
PDL_SWIFT_DECLAIRATION(swift_endAccess, swift_endAccess_args, swift_endAccess_arg_names, void *)
PDL_SWIFT_REGISTER_IMPLEMENTATION(pdl_swift_registerAccessEndAction, swift_endAccess, swift_endAccess_args, void *)

