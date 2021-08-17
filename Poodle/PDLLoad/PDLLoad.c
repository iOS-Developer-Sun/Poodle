//
//  PDLLoad.c
//  Poodle
//
//  Created by Poodle on 2020/12/22.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLLoad.h"
#import <mach-o/ldsyms.h>
#import <mach-o/dyld.h>
#import <string.h>
#import "pdl_objc_runtime.h"

static void emptyLoad(__unsafe_unretained id self, SEL _cmd) {
    return;
}

int pdl_disableCategoryLoad(void *image_header, bool(*filter)(Class cls, const char *category_name, IMP imp)) {
    if (!filter) {
        return 0;
    }

    int ret = 0;
    size_t count = 0;
    pdl_objc_runtime_category *categories = pdl_objc_runtime_nonlazy_categories(image_header, &count);
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
        SEL loadSel = sel_registerName("load");
        for (uint32_t j = 0; j < method_list_count; j++) {
            Method method = pdl_objc_runtime_method_list_get_method(method_list, j);
            SEL sel = method_getName(method);
            if (!sel) {
                continue;
            }
            if ((!sel_isEqual(loadSel, sel)) && (strcmp(sel_getName(sel), sel_getName(loadSel)) != 0)) {
                continue;
            }
            IMP imp = method_getImplementation(method);
            bool disabled = filter(cls, name, imp);
            if (disabled) {
                method_setImplementation(method, (IMP)&emptyLoad);
                ret++;
            }
        }
    }

    return ret;
}
