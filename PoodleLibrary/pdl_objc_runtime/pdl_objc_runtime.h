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

typedef void *pdl_objc_runtime_class;
typedef void *pdl_objc_runtime_category;
typedef void *pdl_objc_runtime_method_list;

extern pdl_objc_runtime_class *pdl_objc_runtime_classes(const void *header, size_t *count);
extern pdl_objc_runtime_class *pdl_objc_runtime_nonlazy_classes(const void *header, size_t *count);

extern pdl_objc_runtime_category *pdl_objc_runtime_categories(const void *header, size_t *count);
extern pdl_objc_runtime_category *pdl_objc_runtime_nonlazy_categories(const void *header, size_t *count);

extern pdl_objc_runtime_method_list pdl_objc_runtime_class_get_class_method_list(pdl_objc_runtime_class cls);
extern pdl_objc_runtime_method_list pdl_objc_runtime_class_get_instance_method_list(pdl_objc_runtime_class cls);

extern const char *pdl_objc_runtime_category_get_name(pdl_objc_runtime_category category);
extern pdl_objc_runtime_class pdl_objc_runtime_category_get_class(pdl_objc_runtime_category category);
extern pdl_objc_runtime_method_list pdl_objc_runtime_category_get_class_method_list(pdl_objc_runtime_category category);
extern pdl_objc_runtime_method_list pdl_objc_runtime_category_get_instance_method_list(pdl_objc_runtime_category category);

extern uint32_t pdl_objc_runtime_method_list_get_count(pdl_objc_runtime_method_list method_list);
extern Method pdl_objc_runtime_method_list_get_method(pdl_objc_runtime_method_list method_list, uint32_t index);

#ifdef __cplusplus
}
#endif
