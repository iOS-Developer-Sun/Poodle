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

#define PDLMachObjectUninitialized ((void *)(unsigned long)-1)

@interface PDLMachObject () {
    pdl_mach_object_t __object;
}

@property (nonatomic, copy, readonly) NSData *originalData;
@property (nonatomic, strong, readonly) NSMutableData *data;
@property (nonatomic, assign, readonly) pdl_mach_object_t *object;
@property (nonatomic, strong, readonly) NSMutableDictionary *bindInfo;

@property (nonatomic, assign) pdl_section *classlistSection;
@property (nonatomic, assign) pdl_section *catlistSection;
@property (nonatomic, assign) pdl_section *modinitSection;

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
        _originalData = [NSData dataWithContentsOfFile:path];
        NSMutableData *data = [_originalData mutableCopy];
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

        _classlistSection = PDLMachObjectUninitialized;
        _catlistSection = PDLMachObjectUninitialized;
        _modinitSection = PDLMachObjectUninitialized;

        [self setup];
    }
    return self;
}

- (uintptr_t)mainOffset {
    uintptr_t mainOffset = self.object->entry_point_command->entryoff;
    return mainOffset;
}

- (uint32_t)constructorsCount {
    pdl_section *modinitSection = self.modinitSection;
    if (!modinitSection) {
        return 0;
    }

    uint32_t ret = (uint32_t)(modinitSection->size / sizeof(unsigned long));
    return ret;
}

- (uintptr_t)constructorOffset:(uint32_t)index {
    pdl_section *modinitSection = self.modinitSection;
    if (!modinitSection) {
        return 0;
    }

    uint32_t offset = modinitSection->offset;
    PDLMachObjectAddress *constructors = ((void *)self.object->header) + offset;
    PDLMachObjectAddress constructor = constructors[index];
    return [self offset:constructor];
}

static int64_t read_sleb128(uint8_t **pointer, uint8_t *end) {
    uint8_t *p = *pointer;
    int64_t result = 0;
    int bit = 0;
    uint8_t byte;
    do {
        assert(p != end);
        byte = *p++;
        result |= ((byte & 0x7f) << bit);
        bit += 7;
    } while (byte & 0x80);
    // sign extend negative numbers
    if ( (byte & 0x40) != 0 ) {
        result |= (-1LL) << bit;
    }
    *pointer = p;
    return result;
}

static uint64_t read_uleb128(uint8_t **pointer, uint8_t *end) {
    uint8_t *p = *pointer;
    uint64_t result = 0;
    int bit = 0;
    do {
        assert(p != end);
        uint64_t slice = *p & 0x7f;
        assert(!(bit >= 64 || slice << bit >> bit != slice));
        result |= (slice << bit);
        bit += 7;
    } while (*p++ & 0x80);
    *pointer = p;
    return result;
}

static void bindDyldInfoAt(uint8_t segmentIndex, uint64_t segmentOffset, uint8_t type, int libraryOrdinal, int64_t addend, const char* symbolName, bool lazyPointer, bool weakImport, PDLMachObject *self) {
//    printf("segmentIndex: %d, segmentOffset: %llx, type: %d, libraryOrdinal: %d, addend: %llx, symbolName: %s, lazyPointer: %d, weakImport: %d\n", segmentIndex, segmentOffset, type, libraryOrdinal, addend, symbolName, lazyPointer, weakImport);
    const pdl_segment_command *segment = self.object->total_segments[segmentIndex];
    uintptr_t addr = segment->vmaddr + segmentOffset;
    self.bindInfo[@(addr)] = @((unsigned long)symbolName);
}

- (void)setup {
    struct dyld_info_command const *dyld_info_command = self.object->dyld_info_dyld_info_command ?: self.object->dyld_info_only_dyld_info_command;
    if (!dyld_info_command) {
        return;
    }

    uint32_t bind_off = dyld_info_command->bind_off;
    uint32_t bind_size = dyld_info_command->bind_size;
    if (bind_off == 0 || bind_size == 0) {
        return;
    }

    _bindInfo = [NSMutableDictionary dictionary];

    // bind
    {
        uint8_t *start = ((void *)self.object->header) + bind_off;
        uint8_t *end = start + bind_size;
        uint8_t *p = start;

        uint8_t type = 0;
        uint64_t segmentOffset = 0;
        uint8_t segmentIndex = 0;
        const char* symbolName = NULL;
        int libraryOrdinal = 0;
        int64_t addend = 0;
        uint32_t count;
        uint32_t skip;
        bool weakImport = false;
        bool done = false;
        while (!done && (p < end)) {
            uint8_t immediate = *p & BIND_IMMEDIATE_MASK;
            uint8_t opcode = *p & BIND_OPCODE_MASK;
            ++p;
            switch (opcode) {
                case BIND_OPCODE_DONE:
                    done = true;
                    break;
                case BIND_OPCODE_SET_DYLIB_ORDINAL_IMM:
                    libraryOrdinal = immediate;
                    break;
                case BIND_OPCODE_SET_DYLIB_ORDINAL_ULEB:
                    libraryOrdinal = (int)read_uleb128(&p, end);
                    break;
                case BIND_OPCODE_SET_DYLIB_SPECIAL_IMM:
                    // the special ordinals are negative numbers
                    if ( immediate == 0 )
                        libraryOrdinal = 0;
                    else {
                        int8_t signExtended = BIND_OPCODE_MASK | immediate;
                        libraryOrdinal = signExtended;
                    }
                    break;
                case BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM:
                    weakImport = ( (immediate & BIND_SYMBOL_FLAGS_WEAK_IMPORT) != 0 );
                    symbolName = (char*)p;
                    while (*p != '\0') {
                        ++p;
                    }
                    ++p;
                    break;
                case BIND_OPCODE_SET_TYPE_IMM:
                    type = immediate;
                    break;
                case BIND_OPCODE_SET_ADDEND_SLEB:
                    addend = read_sleb128(&p, end);
                    break;
                case BIND_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB:
                    segmentIndex = immediate;
                    segmentOffset = read_uleb128(&p, end);
                    break;
                case BIND_OPCODE_ADD_ADDR_ULEB:
                    segmentOffset += read_uleb128(&p, end);
                    break;
                case BIND_OPCODE_DO_BIND:
                    bindDyldInfoAt(segmentIndex, segmentOffset, type, libraryOrdinal, addend, symbolName, false, weakImport, self);
                    segmentOffset += sizeof(intptr_t);
                    break;
                case BIND_OPCODE_DO_BIND_ADD_ADDR_ULEB:
                    bindDyldInfoAt(segmentIndex, segmentOffset, type, libraryOrdinal, addend, symbolName, false, weakImport, self);
                    segmentOffset += read_uleb128(&p, end) + sizeof(intptr_t);
                    break;
                case BIND_OPCODE_DO_BIND_ADD_ADDR_IMM_SCALED:
                    bindDyldInfoAt(segmentIndex, segmentOffset, type, libraryOrdinal, addend, symbolName, false, weakImport, self);
                    segmentOffset += immediate * sizeof(intptr_t) + sizeof(intptr_t);
                    break;
                case BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB:
                    count = (uint32_t)read_uleb128(&p, end);
                    skip = (uint32_t)read_uleb128(&p, end);
                    for (uint32_t i=0; i < count; ++i) {
                        bindDyldInfoAt(segmentIndex, segmentOffset, type, libraryOrdinal, addend, symbolName, false, weakImport, self);
                        segmentOffset += skip + sizeof(intptr_t);
                    }
                    break;
                default:
                    assert(0);
                    break;
            }
        }
    }
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
        NSLog(@"*** cannot find address %p ***", address);
    }
    assert(section);
    intptr_t fileOffset = (unsigned long)address - section->addr + section->offset;
    return fileOffset;
}

- (PDLMachObjectAddress)address:(intptr_t)offset {
    const pdl_section *section = [self sectionOfOffset:offset];
    if (!section) {
        NSLog(@"*** cannot find offset %ld ***", offset);
        assert(false);
    }
    PDLMachObjectAddress address = (PDLMachObjectAddress)(offset - section->offset + section->addr);
    return address;
}

- (void *)realAddress:(PDLMachObjectAddress)address {
    intptr_t offset = [self offset:address];
    void *ret = ((void *)self.object->header) + offset;
    return ret;
}

- (PDLMachObjectAddress *)classList:(size_t *)count {
    const pdl_section *section = [self classlistSection];
    if (!section) {
        return NULL;
    }

    size_t size = section->size / sizeof(void *);
    if (count) {
        *count = size;
    }
    return ((void *)self.object->header) + section->offset;
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

- (pdl_section *)classlistSection {
    if (_classlistSection == PDLMachObjectUninitialized) {
        const char *sectionName = "__objc_classlist";
        const pdl_section *section = [self sectionWithSegmentName:"__DATA" sectionName:sectionName];
        if (!section) {
            section = [self sectionWithSegmentName:"__DATA_CONST" sectionName:sectionName];
        }
        if (!section) {
            section = [self sectionWithSegmentName:"__DATA_DIRTY" sectionName:sectionName];
        }
        _classlistSection = (pdl_section *)section;
    }
    return _classlistSection;
}

- (pdl_section *)catlistSection {
    if (_catlistSection == PDLMachObjectUninitialized) {
        const char *sectionName = "__objc_catlist";
        const pdl_section *section = [self sectionWithSegmentName:"__DATA" sectionName:sectionName];
        if (!section) {
            section = [self sectionWithSegmentName:"__DATA_CONST" sectionName:sectionName];
        }
        if (!section) {
            section = [self sectionWithSegmentName:"__DATA_DIRTY" sectionName:sectionName];
        }
        _catlistSection = (pdl_section *)section;
    }
    return _catlistSection;
}

- (pdl_section *)modinitSection {
    if (_modinitSection == PDLMachObjectUninitialized) {
        const char *sectionName = "__mod_init_func";
        const pdl_section *section = [self sectionWithSegmentName:"__DATA" sectionName:sectionName];
        if (!section) {
            section = [self sectionWithSegmentName:"__DATA_CONST" sectionName:sectionName];
        }
        if (!section) {
            section = [self sectionWithSegmentName:"__DATA_DIRTY" sectionName:sectionName];
        }
        _modinitSection = (pdl_section *)section;
    }
    return _modinitSection;
}

- (PDLMachObjectAddress _Nonnull * _Nullable)categoryList:(size_t *)count {
    pdl_section *section = self.catlistSection;
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
    if (cls) {
        return [self className:cls];
    }

    PDLMachObjectAddress clsAddress = offsetof(struct category_t, cls) + cat;
    const char *name = (const char *)[self.bindInfo[@((unsigned long)clsAddress)] unsignedLongValue];
    if (name) {
        static const char *objc_class_prefix = "_OBJC_CLASS_$_";
        size_t prefixLength = strlen(objc_class_prefix);
        if (strncmp(objc_class_prefix, name, prefixLength) == 0) {
            const char *ret = name + prefixLength;
            return ret;
        }
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
