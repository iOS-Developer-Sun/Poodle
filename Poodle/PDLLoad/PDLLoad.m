//
//  PDLLoad.m
//  Poodle
//
//  Created by Poodle on 2020/12/22.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLLoad.h"
#import "pdl_objc_runtime.h"
#import <mach-o/ldsyms.h>
#import <mach-o/dyld.h>

@implementation PDLLoad

static void emptyLoad(__unsafe_unretained id self, SEL _cmd) {
    return;
}

+ (void)disableCategoryLoad:(BOOL(^_Nullable)(void *imageHeader, NSString *imageName, Class aClass, NSString *categoryName))filter {
    if (!filter) {
        return;
    }

    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        void *imageHeader = (void *)_dyld_get_image_header(i);
        const char *imageName = _dyld_get_image_name(i);

        size_t count = 0;
        pdl_objc_runtime_category *categories = pdl_objc_runtime_categories(imageHeader, &count);
        SEL selLoad = sel_registerName("load");
        for (size_t i = 0; i < count; i++) {
            pdl_objc_runtime_category *category = categories[i];
            if (!category) {
                continue;
            }

            const char *name = pdl_objc_runtime_category_get_name(category);
            Class aClass = pdl_objc_runtime_category_get_class(category);
            pdl_objc_runtime_method_list method_list = pdl_objc_runtime_category_get_class_method_list(category);
            if (!method_list) {
                continue;
            }

            uint32_t method_list_count = pdl_objc_runtime_method_list_get_count(method_list);
            for (uint32_t j = 0; j < method_list_count; j++) {
                Method method = pdl_objc_runtime_method_list_get_method(method_list, j);
                SEL sel = method_getName(method);
                if (!sel_isEqual(sel, selLoad)) {
                    continue;
                }

                BOOL disabled = filter(imageHeader, @(imageName), aClass, @(name));
                if (disabled) {
                    method_setImplementation(method, (IMP)&emptyLoad);
                }
            }
        }
    }
}

@end
