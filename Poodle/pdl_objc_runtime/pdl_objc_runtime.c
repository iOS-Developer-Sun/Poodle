//
//  pdl_objc_runtime.c
//  Poodle
//
//  Created by Poodle on 2020/6/18.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "pdl_objc_runtime.h"
#import <mach-o/getsect.h>
#import "pdl_pac.h"
#import "pdl_vm.h"

struct list_t {
    uint32_t entsizeAndFlags;
    uint32_t count;
};

struct ivar_t {
    uint32_t *offset;
    const char *name;
    const char *type;
    uint32_t alignment;
    uint32_t size;
};

struct ivar_list_t {
    struct list_t list;
    struct ivar_t ivars[0];
};

struct method_t {
    SEL name;
    const char *types;
    IMP imp;
};

struct small_method_t {
    int32_t name;
    int32_t types;
    int32_t imp;
};

struct method_list_t {
    struct list_t list;
    union {
        struct small_method_t small[0];
        struct method_t big[0];
    } methods;
};

struct property_t {
    const char *name;
    const char *attribute;
};

struct property_list_t {
    struct list_t list;
    struct property_t properties[0];
};

struct protocol_list_t;
struct protocol_t {
    struct protocol_t *isa;
    const char *name;
    struct protocol_list_t *ref;
    struct method_list_t *instanceMethods;
    struct method_list_t *classMethods;
    struct method_list_t *optionalInstanceMethods;
    struct method_list_t *optionalClassMethods;
    struct property_list_t *instanceProperties;
};

struct protocol_list_t {
    uint64_t count;
    struct protocol_t protocols[0];
};

struct class_ro_t {
    uint32_t flags; // 0x4 RO_HAS_CXX_STRUCTORS
    uint32_t instanceStart;
    uint32_t instanceSize;
    uint32_t reserved;
    uint16_t *instanceVarLayout;
    const char *name;
    struct method_list_t *methods;
    struct protocol_list_t *protocols;
    struct ivar_list_t *ivars;
    uint16_t *weakInstanceVarLayout;
    struct property_list_t *properties;
};

struct class_t {
    struct class_t *isa;
    Class super_class;
    void *cache;
    void *vtable;
    struct class_ro_t *ro;
};

struct category_t {
    const char *name;
    Class cls;
    struct method_list_t *instanceMethods;
    struct method_list_t *classMethods;
    struct protocol_list_t *protocols;
    struct property_list_t *instanceProperties;
    struct property_list_t *classProperties;
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

#pragma mark -

pdl_objc_runtime_class *pdl_objc_runtime_classes(const void *header, size_t *count) {
    size_t size = 0;
    pdl_objc_runtime_class *data = (pdl_objc_runtime_class *)getDataSection(header, "__objc_classlist", &size);
    if (count) {
        *count = size / sizeof(Class);
    }
    return data;
}

pdl_objc_runtime_class *pdl_objc_runtime_nonlazy_classes(const void *header, size_t *count) {
    size_t size = 0;
    pdl_objc_runtime_class *data = (pdl_objc_runtime_class *)getDataSection(header, "__objc_nlclslist", &size);
    if (count) {
        *count = size / sizeof(Class);
    }
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

pdl_objc_runtime_method_list pdl_objc_runtime_class_get_class_method_list(pdl_objc_runtime_class cls) {
    struct class_t *c = (struct class_t *)cls;
    struct class_t *meta = c->isa;
    struct class_ro_t *ro = meta->ro;
    return pdl_ptrauth_strip_function(ro->methods);
}

pdl_objc_runtime_method_list pdl_objc_runtime_class_get_instance_method_list(pdl_objc_runtime_class cls) {
    struct class_t *c = (struct class_t *)cls;
    struct class_ro_t *ro = c->ro;
    return pdl_ptrauth_strip_function(ro->methods);
}

const char *pdl_objc_runtime_category_get_name(pdl_objc_runtime_category category) {
    struct category_t *c = (struct category_t *)category;
    return c->name;
}

pdl_objc_runtime_class pdl_objc_runtime_category_get_class(pdl_objc_runtime_category category) {
    struct category_t *c = (struct category_t *)category;
    return c->cls;
}

pdl_objc_runtime_method_list pdl_objc_runtime_category_get_class_method_list(pdl_objc_runtime_category category) {
    struct category_t *c = (struct category_t *)category;
    return pdl_ptrauth_strip_function(c->classMethods);
}

pdl_objc_runtime_method_list pdl_objc_runtime_category_get_instance_method_list(pdl_objc_runtime_category category) {
    struct category_t *c = (struct category_t *)category;
    return c->instanceMethods;
}

uint32_t pdl_objc_runtime_method_list_get_count(pdl_objc_runtime_method_list method_list) {
    struct method_list_t *m = (struct method_list_t *)method_list;
    return m->list.count;
}

Method pdl_objc_runtime_method_list_get_method(pdl_objc_runtime_method_list method_list, uint32_t index) {
    struct method_list_t *m = (struct method_list_t *)method_list;
    Method method = NULL;
    if (m->list.entsizeAndFlags & 0x80000000) {
        method = (Method)(((void *)&(m->methods.small[index])) + 1);
        method = pdl_ptrauth_sign_unauthenticated_data(method, (void *)0xc1ab);
    } else {
        method = (Method)&(m->methods.big[index]);
    }
    return method;
}

#if __arm64__
#define ISA_MASK 0x0000000ffffffff8ULL
#elif __x86_64__
#define ISA_MASK 0x00007ffffffffff8ULL
#else
#error unknown architecture
#endif

bool pdl_objc_is_object(void *address) {
    if (!address) {
        return false;
    }

    void *nsobject = (void *)(ISA_MASK & (unsigned long)objc_getMetaClass("NSObject"));
    void *nsproxy = (void *)(ISA_MASK & (unsigned long)objc_getMetaClass("NSProxy"));
    void *object = (void *)(ISA_MASK & (unsigned long)address);
    if (object == nsobject || object == nsproxy) {
        return true;
    }

    void *class = 0;
    bool success = pdl_vm_read(object, &class, sizeof(address));
    if (!success) {
        return false;
    }

    class = (void *)(ISA_MASK & (unsigned long)class);
    if (class == nsobject || class == nsproxy) {
        return true;
    }


    void *meta = 0;
    success = pdl_vm_read(class, &meta, sizeof(address));
    if (!success) {
        return false;
    }

    meta = (void *)(ISA_MASK & (unsigned long)meta);
    if (meta == nsobject || meta == nsproxy) {
        return true;
    }

    void *root = 0;
    success = pdl_vm_read(meta, &root, sizeof(address));
    if (!success) {
        return false;
    }

    root = (void *)(ISA_MASK & (unsigned long)root);
    if (root == nsobject || root == nsproxy) {
        return true;
    }

    return false;
}
