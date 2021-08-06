//
//  pdl_objc_runtime.c
//  Poodle
//
//  Created by Poodle on 2020/6/18.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "pdl_objc_runtime.h"
#import <mach-o/getsect.h>

struct method_t {
    SEL name;
    const char *types;
    IMP imp;
};

struct method_list_t {
    uint32_t entsizeAndFlags;
    uint32_t count;
    struct method_t methods[0];
};

struct class_t {
    struct class_t *isa;
    Class super_class;
    const char *name;
    long version;
    long info;
    long instance_size;
    struct objc_ivar_list *ivars;
    struct objc_method_list **methodLists;
    struct objc_cache *cache;
    struct objc_protocol_list *protocols;
};

struct category_t {
    const char *name;
    Class cls;
    struct method_list_t *instanceMethods;
    struct method_list_t *classMethods;
    struct protocol_list_t *protocols;
    struct property_list_t *instanceProperties;
    struct property_list_t *_classProperties;
};

static uint8_t *getDataSection(const void *mhdr, const char *sectname, size_t *outBytes) {
    unsigned long byteCount = 0;
    uint8_t *data = getsectiondata(mhdr, "__DATA", sectname, &byteCount);
    if (!data) {
        data = getsectiondata(mhdr, "__DATA_CONST", sectname, &byteCount);
    }
    if (!data) {
        data = getsectiondata(mhdr, "__DATA_DIRTY", sectname, &byteCount);
    }
    if (outBytes) {
        *outBytes = byteCount;
    }
    return data;
}

Class *pdl_objc_runtime_classes(const void *header, size_t *count) {
    size_t size = 0;
    Class *data = (Class *)getDataSection(header, "__objc_classlist", &size);
    if (count) {
        *count = size / sizeof(Class);
    }
    return data;
}

Class *pdl_objc_runtime_nonlazy_classes(const void *header, size_t *count) {
    size_t size = 0;
    Class *data = (Class *)getDataSection(header, "__objc_nlclslist", &size);
    if (count) {
        *count = size / sizeof(Class);
    }
    struct class_t *c = data[0];
    return data;
}

pdl_objc_runtime_category *pdl_objc_runtime_categories(const void *header, size_t *count) {
    size_t size = 0;
    pdl_objc_runtime_category *data = (pdl_objc_runtime_category *)getDataSection(header, "__objc_catlist", &size);
    if (count) {
        *count = size / sizeof(struct category_t *);
    }
    return data;
}

pdl_objc_runtime_category *pdl_objc_runtime_nonlazy_categories(const void *header, size_t *count) {
    size_t size = 0;
    pdl_objc_runtime_category *data = (pdl_objc_runtime_category *)getDataSection(header, "__objc_nlcatlist", &size);
    if (count) {
        *count = size / sizeof(struct category_t *);
    }
    return data;
}

const char *pdl_objc_runtime_category_get_name(pdl_objc_runtime_category category) {
    struct category_t *c = (struct category_t *)category;
    return c->name;
}

Class pdl_objc_runtime_category_get_class(pdl_objc_runtime_category category) {
    struct category_t *c = (struct category_t *)category;
    return c->cls;
}

pdl_objc_runtime_method_list pdl_objc_runtime_category_get_class_method_list(pdl_objc_runtime_category category) {
    struct category_t *c = (struct category_t *)category;
    return c->classMethods;
}

pdl_objc_runtime_method_list pdl_objc_runtime_category_get_instance_method_list(pdl_objc_runtime_category category) {
    struct category_t *c = (struct category_t *)category;
    return c->instanceMethods;
}

uint32_t pdl_objc_runtime_method_list_get_count(pdl_objc_runtime_method_list method_list) {
    struct method_list_t *m = (struct method_list_t *)method_list;
    return m->count;
}

Method pdl_objc_runtime_method_list_get_method(pdl_objc_runtime_method_list method_list, uint32_t index) {
    struct method_list_t *m = (struct method_list_t *)method_list;
    return (Method)&(m->methods[index]);
}
