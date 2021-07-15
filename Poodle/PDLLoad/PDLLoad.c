//
//  PDLLoad.c
//  Poodle
//
//  Created by Poodle on 2020/12/22.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLLoad.h"
#import "pdl_objc_runtime.h"
#import <mach-o/ldsyms.h>
#import <mach-o/dyld.h>
#import <string.h>

static void emptyLoad(__unsafe_unretained id self, SEL _cmd) {
    return;
}

void pdl_disableCategoryLoad(void *image_header, bool(*filter)(Class cls, const char *category_name)) {
    if (!filter) {
        return;
    }

    size_t count = 0;
    pdl_objc_runtime_category *categories = pdl_objc_runtime_categories(image_header, &count);
    for (size_t i = 0; i < count; i++) {
        pdl_objc_runtime_category *category = categories[i];
        if (!category) {
            continue;
        }

        const char *name = pdl_objc_runtime_category_get_name(category);
        Class cls = pdl_objc_runtime_category_get_class(category);
        pdl_objc_runtime_method_list method_list = pdl_objc_runtime_category_get_class_method_list(category);
        if (!method_list) {
            continue;
        }

        uint32_t method_list_count = pdl_objc_runtime_method_list_get_count(method_list);
        for (uint32_t j = 0; j < method_list_count; j++) {
            Method method = pdl_objc_runtime_method_list_get_method(method_list, j);
            SEL sel = method_getName(method);
            if (!sel) {
                continue;
            }
            const char *n1 = sel_getName(sel);
            if (!n1) {
                continue;
            }
            if (strcmp(n1, "load") != 0) {
                continue;
            }

            bool disabled = filter(cls, name);
            if (disabled) {
                method_setImplementation(method, (IMP)&emptyLoad);
            }
        }
    }
}
