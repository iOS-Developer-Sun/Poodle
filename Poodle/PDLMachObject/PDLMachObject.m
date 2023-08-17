//
//  PDLMachObject.m
//  Poodle
//
//  Created by Poodle on 2019/8/1.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLMachObject.h"
#import "PDLSystemImage.h"

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
    struct class_t *cls;
    struct method_list_t *instanceMethods;
    struct method_list_t *classMethods;
    struct protocol_list_t *protocols;
    struct property_list_t *instanceProperties;
    struct property_list_t *classProperties;
};

#pragma mark -

@interface PDLMachObject () {
    pdl_mach_object_t __object;
}

@property (nonatomic, copy, readonly) NSData *data;
@property (nonatomic, assign, readonly) pdl_mach_object_t *object;

@end

@implementation PDLMachObject

+ (instancetype)executable {
    PDLSystemImage *executable = [PDLSystemImage executeSystemImage];
    NSString *path = executable.path;
    return [[self alloc] initWithPath:path];
}

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        PDLSystemImage *executable = [PDLSystemImage executeSystemImage];
        NSData *data = [NSData dataWithContentsOfFile:path];
        cpu_type_t my_cputype = executable.cpuType;
        cpu_subtype_t my_cpusubtype = executable.cpuSubtype;
        pdl_fat_object object;
        pdl_fat_object *fat_object = &object;
        struct mach_header *header = NULL;
        bool isFat = pdl_get_fat_object_with_header((const struct fat_header *)data.bytes, fat_object);
        if (isFat) {
            uint32_t archCount = fat_object->arch_count;
            if (fat_object->swaps) {
                archCount = OSSwapInt32(archCount);
            }
            for (uint32_t i = 0; i < archCount; i++) {
                cpu_type_t cpuType;
                cpu_subtype_t cpuSubtype;
                uint64_t offset;
                if (fat_object->is64 == false) {
                    struct fat_arch *arch = &fat_object->arch_list[i];
                    cpuType = arch->cputype;
                    cpuSubtype = arch->cpusubtype;
                    offset = arch->offset;
                } else {
                    struct fat_arch_64 *arch = &((pdl_fat_object_64 *)fat_object)->arch_list[i];
                    cpuType = arch->cputype;
                    cpuSubtype = arch->cpusubtype;
                    offset = arch->offset;
                }

                if (fat_object->swaps) {
                    cpuType = OSSwapInt32(cpuType);
                    cpuSubtype = OSSwapInt32(cpuSubtype);
                    if (fat_object->is64 == false) {
                        offset = OSSwapInt32((uint32_t)offset);
                    } else {
                        offset = OSSwapInt64(offset);
                    }
                }

                if (cpuType == my_cputype && cpuSubtype == my_cpusubtype) {
                    header = (struct mach_header *)(((char *)fat_object->header) + offset);
                    break;
                }
            }
        } else {
            header = (struct mach_header *)data.bytes;
        }
        _data = data;
        _object = &__object;
        BOOL ret = pdl_get_mach_object_with_header(header, -1, NULL, (pdl_mach_object *)_object);
        if (!ret) {
            return nil;
        }
    }
    return self;
}

- (const pdl_section *)sectionWithSegmentName:(const char *)segname sectionName:(const char *)sectname {
    for (uint32_t i = 0; i < self.object->sections_count; i++) {
        const pdl_section *section = self.object->sections[i];
        if (
            (strncmp(section->segname, segname, sizeof(section->segname)) == 0)
            && (strncmp(section->sectname, sectname, sizeof(section->sectname)) == 0)
            ) {
            return section;
        }
    }
    return NULL;
}

- (const pdl_section *)sectionOfAddress:(PDLMachObjectAddress)address {
    unsigned long addr = (unsigned long)address;
    for (uint32_t i = 0; i < self.object->sections_count; i++) {
        const pdl_section *section = self.object->sections[i];
        if (addr >= section->addr && addr < section->addr + section->size)
            {
            return section;
        }
    }
    return NULL;
}

- (const pdl_section *)sectionOfOffset:(intptr_t)offset {
    for (uint32_t i = 0; i < self.object->sections_count; i++) {
        const pdl_section *section = self.object->sections[i];
        if (offset >= section->offset && offset < section->offset + section->size)
            {
            return section;
        }
    }
    return NULL;
}

- (intptr_t)offset:(PDLMachObjectAddress)address {
    const pdl_section *section = [self sectionOfAddress:address];
    if (!section) {
        NSLog(@"!");
    }
    assert(section);
    intptr_t fileOffset = (unsigned long)address - section->addr + section->offset;
    return fileOffset;
}

- (PDLMachObjectAddress)address:(intptr_t)offset {
    const pdl_section *section = [self sectionOfOffset:offset];
    if (!section) {
        NSLog(@"!");
    }
    assert(section);
    PDLMachObjectAddress address = (PDLMachObjectAddress)(offset - section->offset + section->addr);
    return address;
}

- (PDLMachObjectAddress *)classList:(size_t *)count {
    const pdl_section *section = [self sectionWithSegmentName:"__DATA" sectionName:"__objc_classlist"];
    if (!section) {
        section = [self sectionWithSegmentName:"__DATA_CONST" sectionName:"__objc_classlist"];
    }
    if (!section) {
        section = [self sectionWithSegmentName:"__DATA_DIRTY" sectionName:"__objc_classlist"];
    }
    if (!section) {
        return NULL;
    }

    size_t size = section->size / sizeof(void *);
    if (count) {
        *count = size;
    }
    return ((void *)self.object->header) + section->offset;
}

- (void *)realAddress:(PDLMachObjectAddress)address {
    intptr_t offset = [self offset:address];
    void *ret = ((void *)self.object->header) + offset;
    return ret;
}

- (const char *)className:(PDLMachObjectAddress)cls {
    struct class_t *c = [self realAddress:cls];
    struct class_ro_t *ro = [self realAddress:c->ro];
    if (((unsigned long)ro & 1) == 1) {
        // TODO
        return NULL;
    }

    const char *name = [self realAddress:(PDLMachObjectAddress)ro->name];
    return name;
}

- (PDLMachObjectAddress)instanceMethodList:(PDLMachObjectAddress)cls {
    struct class_t *c = [self realAddress:cls];
    struct class_ro_t *ro = [self realAddress:c->ro];
    if (((unsigned long)ro & 1) == 1) {
        // TODO
        return NULL;
    }

    PDLMachObjectAddress ret = ro->methods;
    return ret;
}

- (PDLMachObjectAddress)classMethodList:(PDLMachObjectAddress)cls {
    struct class_t *c = [self realAddress:cls];
    return [self instanceMethodList:c->isa];
}

- (PDLMachObjectAddress _Nonnull * _Nullable)categoryList:(size_t *)count {
    const pdl_section *section = [self sectionWithSegmentName:"__DATA" sectionName:"__objc_catlist"];
    if (!section) {
        section = [self sectionWithSegmentName:"__DATA_CONST" sectionName:"__objc_catlist"];
    }
    if (!section) {
        section = [self sectionWithSegmentName:"__DATA_DIRTY" sectionName:"__objc_catlist"];
    }
    if (!section) {
        return NULL;
    }

    size_t size = section->size / sizeof(void *);
    if (count) {
        *count = size;
    }
    return ((void *)self.object->header) + section->offset;
}

- (const char *)categoryName:(PDLMachObjectAddress)cat {
    struct category_t *c = [self realAddress:cat];
    const char *name = [self realAddress:(PDLMachObjectAddress)c->name];
    return name;
}

- (const char *)categoryClassName:(PDLMachObjectAddress)cat {
    struct category_t *c = [self realAddress:cat];
    PDLMachObjectAddress cls = c->cls;
    // TODO
    if (cls) {
        return [self className:cls];
    }
    return NULL;
}

- (PDLMachObjectAddress)categoryInstanceMethodList:(PDLMachObjectAddress)cat {
    struct category_t *c = [self realAddress:cat];
    return c->instanceMethods;
}

- (PDLMachObjectAddress)categoryClassMethodList:(PDLMachObjectAddress)cat {
    struct category_t *c = [self realAddress:cat];
    return c->classMethods;
}

- (uint32_t)methodCount:(PDLMachObjectAddress)methodList {
    struct method_list_t *m = (struct method_list_t *)[self realAddress:methodList];
    uint32_t count = m->list.count;
    return count;
}

- (void)enumerateMethodList:(PDLMachObjectAddress)methodList action:(void(^)(const char *name, const char *type, intptr_t impOffset))action {
    if (!action) {
        return;
    }

    struct method_list_t *m = (struct method_list_t *)[self realAddress:methodList];
    uint32_t size = m->list.count;
    for (uint32_t i = 0; i < size; i++) {
        struct method_t *method = &(m->methods.big[i]);
        const char *name = [self realAddress:method->name];
        const char *types = [self realAddress:(PDLMachObjectAddress)method->types];
        intptr_t impOffset = [self offset:method->imp];
        action(name, types, impOffset);
    }
}

@end
