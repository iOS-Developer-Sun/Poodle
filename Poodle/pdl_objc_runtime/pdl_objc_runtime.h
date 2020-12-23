//
//  pdl_objc_runtime.h
//  Poodle
//
//  Created by Poodle on 2020/6/18.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <objc/runtime.h>

#ifdef __cplusplus
extern "C" {
#endif

extern __attribute__((ns_returns_retained))
id pdl_class_createInstance(__unsafe_unretained Class cls, size_t extraBytes, __attribute__((ns_returns_retained)) id(*class_createInstance_original)(__unsafe_unretained Class cls, size_t extraBytes));

extern __attribute__((ns_returns_retained))
id pdl_objc_rootAllocWithZone(__unsafe_unretained Class cls, struct _NSZone *zone, id(*_objc_rootAllocWithZone_original)(Class cls, struct _NSZone *zone));

extern
void pdl_objc_rootDealloc(__unsafe_unretained id object, void(*_objc_rootDealloc_original)(__unsafe_unretained id object));


typedef void *pdl_objc_runtime_category;
typedef void *pdl_objc_runtime_method_list;

extern pdl_objc_runtime_category *pdl_objc_runtime_categories(const void *header, size_t *count);

extern const char *pdl_objc_runtime_category_get_name(pdl_objc_runtime_category category);
extern Class pdl_objc_runtime_category_get_class(pdl_objc_runtime_category category);
extern pdl_objc_runtime_method_list pdl_objc_runtime_category_get_class_method_list(pdl_objc_runtime_category category);
extern pdl_objc_runtime_method_list pdl_objc_runtime_category_get_instance_method_list(pdl_objc_runtime_category category);

extern uint32_t pdl_objc_runtime_method_list_get_count(pdl_objc_runtime_method_list method_list);
extern Method pdl_objc_runtime_method_list_get_method(pdl_objc_runtime_method_list method_list, uint32_t index);

#ifdef __cplusplus
}
#endif
