//
//  PDLMachObject.m
//  Poodle
//
//  Created by Poodle on 2019/8/1.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLMachObject.h"
#import <mach-o/fixup-chains.h>

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

#define SWIFT_CONTEXT_DESCRIPTOR_KIND_MODULE 0
#define SWIFT_CONTEXT_DESCRIPTOR_KIND_EXTENSION 1
#define SWIFT_CONTEXT_DESCRIPTOR_KIND_ANONYMOUS 2
#define SWIFT_CONTEXT_DESCRIPTOR_KIND_PROTOCOL 3
#define SWIFT_CONTEXT_DESCRIPTOR_KIND_OPAQUE_TYPE 4
#define SWIFT_CONTEXT_DESCRIPTOR_KIND_CLASS 16
#define SWIFT_CONTEXT_DESCRIPTOR_KIND_STRUCT 17
#define SWIFT_CONTEXT_DESCRIPTOR_KIND_ENUM 18
#define SWIFT_CONTEXT_DESCRIPTOR_KIND_ANY 31

struct swift_type
{
    uint32_t flags;
    int32_t parent;
};

struct swift_type_module
{
    uint32_t flags;
    int32_t parent;
    int32_t name;
};

struct swift_vtable_descriptor_header
{
    uint32_t offset;
    uint32_t size;
};

struct swift_vtable_descriptor
{
    uint32_t flags;
    int32_t imp;
};

struct swift_type_class
{
    uint32_t flags;
    int32_t parent;
    int32_t name;
    int32_t access_function;
    int32_t field_descriptor;
    uint32_t superclass_type;
    uint32_t negative_size;
    uint32_t positive_size;
    uint32_t number_of_immediate_members;
    uint32_t number_of_fields;
    uint32_t field_offset_vector_offset;
    // optional
//    int32_t resilient_superclass;
//    int32_t metadataInitialization[3];
//    struct swift_vtable_descriptor_header vtable;
//    struct swift_vtable_descriptor methods[0];
};

struct swift_type_struct
{
    uint32_t flags;
    int32_t parent;
    int32_t name;
    int32_t access_function;
    int32_t field_descriptor;
    uint32_t number_of_fields;
    uint32_t field_offset_vector_offset;
};

#define SWIFT_VTABLE_DESCRIPTOR_MASK_KIND (0x0F)
#define SWIFT_VTABLE_DESCRIPTOR_MASK_IS_INSTANCE (0x10)
#define SWIFT_VTABLE_DESCRIPTOR_MASK_IS_DYNAMIC (0x20)

enum swift_method_kind {
    swift_method_kind_method,
    swift_method_kind_init,
    swift_method_kind_getter,
    swift_method_kind_setter,
    swift_method_kind_modifyCoroutine,
    swift_method_kind_readCoroutine,
};

#define SWIFT_CONTEXT_DESCRIPTOR_KIND_MODULE 0
#define SWIFT_CONTEXT_DESCRIPTOR_KIND_EXTENSION 1
#define SWIFT_CONTEXT_DESCRIPTOR_KIND_ANONYMOUS 2
#define SWIFT_CONTEXT_DESCRIPTOR_KIND_PROTOCOL 3
#define SWIFT_CONTEXT_DESCRIPTOR_KIND_OPAQUE_TYPE 4
#define SWIFT_CONTEXT_DESCRIPTOR_KIND_CLASS 16
#define SWIFT_CONTEXT_DESCRIPTOR_KIND_STRUCT 17
#define SWIFT_CONTEXT_DESCRIPTOR_KIND_ENUM 18
#define SWIFT_CONTEXT_DESCRIPTOR_KIND_ANY 31

enum {
        // All of these values are bit offsets or widths.
        // Generic flags build upwards from 0.
        // Type-specific flags build downwards from 15.

        /// Whether there's something unusual about how the metadata is
        /// initialized.
        ///
        /// Meaningful for all type-descriptor kinds.
    MetadataInitialization = 0,
    MetadataInitialization_width = 2,

        /// Set if the type has extended import information.
        ///
        /// If true, a sequence of strings follow the null terminator in the
        /// descriptor, terminated by an empty string (i.e. by two null
        /// terminators in a row).  See TypeImportInfo for the details of
        /// these strings and the order in which they appear.
        ///
        /// Meaningful for all type-descriptor kinds.
    HasImportInfo = 2,

        /// Set if the type descriptor has a pointer to a list of canonical
        /// prespecializations.
    HasCanonicalMetadataPrespecializations = 3,

        /// Set if the metadata contains a pointer to a layout string
    HasLayoutString = 4,

        // Type-specific flags:

        /// Set if the class is an actor.
        ///
        /// Only meaningful for class descriptors.
    Class_IsActor = 7,

        /// Set if the class is a default actor class.  Note that this is
        /// based on the best knowledge available to the class; actor
        /// classes with resilient superclassess might be default actors
        /// without knowing it.
        ///
        /// Only meaningful for class descriptors.
    Class_IsDefaultActor = 8,

        /// The kind of reference that this class makes to its resilient superclass
        /// descriptor.  A TypeReferenceKind.
        ///
        /// Only meaningful for class descriptors.
    Class_ResilientSuperclassReferenceKind = 9,
    Class_ResilientSuperclassReferenceKind_width = 3,

        /// Whether the immediate class members in this metadata are allocated
        /// at negative offsets.  For now, we don't use this.
    Class_AreImmediateMembersNegative = 12,

        /// Set if the context descriptor is for a class with resilient ancestry.
        ///
        /// Only meaningful for class descriptors.
    Class_HasResilientSuperclass = 13,

        /// Set if the context descriptor includes metadata for dynamically
        /// installing method overrides at metadata instantiation time.
    Class_HasOverrideTable = 14,

        /// Set if the context descriptor includes metadata for dynamically
        /// constructing a class's vtables at metadata instantiation time.
        ///
        /// Only meaningful for class descriptors.
    Class_HasVTable = 15,
};

enum MetadataInitializationKind {
        /// There are either no special rules for initializing the metadata
        /// or the metadata is generic.  (Genericity is set in the
        /// non-kind-specific descriptor flags.)
    NoMetadataInitialization = 0,

        /// The type requires non-trivial singleton initialization using the
        /// "in-place" code pattern.
    SingletonMetadataInitialization = 1,

        /// The type requires non-trivial singleton initialization using the
        /// "foreign" code pattern.
    ForeignMetadataInitialization = 2,

        // We only have two bits here, so if you add a third special kind,
        // include more flag bits in its out-of-line storage.
};

struct swift_field_record {
    uint32_t flags;
    int32_t name;
    int32_t fieldname;
};

struct swift_field_descriptor
{
    int32_t type_name;
    int32_t superclass;
    uint16_t kind;
    uint16_t field_record_size;
    uint32_t number_of_records;
    struct swift_field_record records[0];
};

#pragma mark -

#define PDLMachObjectUninitialized ((void *)(unsigned long)-1)

@interface PDLFixupImport : NSObject

@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, assign) NSUInteger libOrdinal;
@property (nonatomic, assign) BOOL weak;
@property (nonatomic, assign) NSUInteger appendex;

@end

@implementation PDLFixupImport

@end

@interface PDLMachObject () {
    pdl_mach_object_t __object;
}

@property (nonatomic, copy, readonly) NSData *originalData;
@property (nonatomic, strong, readonly) NSMutableData *data;
@property (nonatomic, strong, readonly) NSMutableDictionary *bindInfo;
@property (nonatomic, strong, readonly) NSMutableArray *fixupImports;
@property (nonatomic, strong, readonly) NSMutableDictionary *symbolsMap;
@property (nonatomic, strong, readonly) NSMutableDictionary *externalFixupsSymbolMap;
@property (nonatomic, readonly) NSDictionary *functionsSize;
@property (nonatomic, readonly) NSArray *functions;

@property (nonatomic, assign) pdl_section *classlistSection;
@property (nonatomic, assign) pdl_section *catlistSection;
@property (nonatomic, assign) pdl_section *modinitSection;
@property (nonatomic, assign) pdl_section *swift5typesSection;

@end

@implementation PDLMachObject

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _object = &__object;

        _originalData = [data copy];
        _data = [_originalData mutableCopy];

        struct mach_header *header = (struct mach_header *)_data.bytes;
        BOOL ret = pdl_get_mach_object_with_header(header, -1, NULL, (pdl_mach_object *)_object);
        if (!ret) {
            return nil;
        }

        BOOL supported = NO;
#ifdef __LP64__
        supported = YES;
#endif
        if (!supported || !_object->is64) {
            return nil;
        }

        _classlistSection = PDLMachObjectUninitialized;
        _catlistSection = PDLMachObjectUninitialized;
        _modinitSection = PDLMachObjectUninitialized;
        _swift5typesSection = PDLMachObjectUninitialized;

        [self setup];
    }
    return self;
}

- (uintptr_t)mainOffset {
    uintptr_t mainOffset = 0;
    if (self.object->entry_point_command) {
        mainOffset = self.object->entry_point_command->entryoff;
    }
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
    [self setupFunctions];
    [self setupDyld];
    [self setupDyldFixups];
}

- (void)setupFunctions {
    pdl_mach_object *machObject = (pdl_mach_object *)self.object;
    const struct linkedit_data_command *function_starts =  machObject->function_starts_linkedit_data_command;
    if (!function_starts || function_starts->datasize == 0) {
        return;
    }

    unsigned char *data_begin = (unsigned char *)(machObject->linkedit_base + function_starts->dataoff);
    unsigned char *data_end = data_begin + function_starts->datasize;
    uint64_t currentOffset = read_uleb128(&data_begin, data_end);
    NSMutableArray *functions = [NSMutableArray array];
    NSMutableDictionary *functionsSize = [NSMutableDictionary dictionary];
    while (true) {
        uint64_t function_begin = currentOffset;
        uint64_t size = read_uleb128(&data_begin, data_end);
        if (size == 0) {
            break;
        }

        currentOffset += size;
        [functions addObject:@(function_begin)];
        functionsSize[@(function_begin)] = @(size);
    }

    // last
    pdl_segment_command *text = (pdl_segment_command *)machObject->text_segment_command;
    NSInteger base = text->vmaddr;
    pdl_section *textSection = NULL;
    NSInteger value = base + currentOffset;
    for (NSInteger i = 0; i < machObject->sections_count; i++) {
        pdl_section *section = (pdl_section *)machObject->sections[i];
        if (value >= section->addr && value < section->addr + section->size) {
            textSection = section;
            break;
        }
    }
    if (textSection) {
        uint64_t lastSize = (textSection->addr + textSection->size) - value;
        [functions addObject:@(currentOffset)];
        functionsSize[@(currentOffset)] = @(lastSize);
    }

    _functions = [functions copy];
    _functionsSize = [functionsSize copy];
}

- (void)setupSymbols {
    pdl_nlist *symtab_list = (pdl_nlist *)self.object->symtab_list;
    if (!symtab_list) {
        return;
    }

    _symbolsMap = [NSMutableDictionary dictionary];

    const char *strtab = self.object->strtab;
    for (uint32_t i = 0; i < self.object->symtab_count; i++) {
        pdl_nlist *nlist = symtab_list + i;
        uint32_t strx = nlist->n_un.n_strx;
//        uint8_t type = nlist->n_type;
//        uint8_t sect = nlist->n_sect;
//        int16_t desc = nlist->n_desc;
        u_long value = (u_long)nlist->n_value;
        const char *str = strtab + strx;
        self.symbolsMap[@(str)] = @(value);
    }
}

- (void)setupDyld {
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

- (void)setupDyldFixups {
    struct linkedit_data_command const *dyld_chained_fixups_command = self.object->dyld_chained_fixups_command;
    if (!dyld_chained_fixups_command) {
        return;
    }

    uint32_t dataoff = dyld_chained_fixups_command->dataoff;
    uint32_t datasize = dyld_chained_fixups_command->datasize;
    if (dataoff == 0 || datasize == 0) {
        return;
    }

    void *headerPointer = ((void *)self.object->header) + dataoff;
    struct dyld_chained_fixups_header *header = headerPointer;
    if (header->fixups_version != 0) {
        return;
    }

    if (header->symbols_format != 0) {
        return;
    }

    [self setupSymbols];

    _fixupImports = [NSMutableArray array];
    _externalFixupsSymbolMap = [NSMutableDictionary dictionary];

    char *symbolsPool = headerPointer + header->symbols_offset;

    // imports
    uint32_t *imports = headerPointer + header->imports_offset;
    int libOrdinal = 0;
    switch (header->imports_format) {
        case DYLD_CHAINED_IMPORT: {
            for (uint32_t i = 0; i < header->imports_count; ++i) {
                struct dyld_chained_import *import = &((struct dyld_chained_import *)imports)[i];
                const char *symbolName = &symbolsPool[import->name_offset];
                uint8_t libVal = import->lib_ordinal;
                if ( libVal > 0xF0 ) {
                    libOrdinal = (int8_t)libVal;
                } else {
                    libOrdinal = libVal;
                }

                PDLFixupImport *fixupImport = [[PDLFixupImport alloc] init];
                fixupImport.libOrdinal = libOrdinal;
                fixupImport.symbol = @(symbolName);
                fixupImport.appendex = 0;
                fixupImport.weak = import->weak_import;
                [self.fixupImports addObject:fixupImport];
            }
        } break;
        case DYLD_CHAINED_IMPORT_ADDEND: {
            for (uint32_t i = 0; i < header->imports_count; ++i) {
                struct dyld_chained_import_addend *import = &((struct dyld_chained_import_addend *)imports)[i];
                const char *symbolName = &symbolsPool[import->name_offset];
                uint8_t libVal = import->lib_ordinal;
                if ( libVal > 0xF0 ) {
                    libOrdinal = (int8_t)libVal;
                } else {
                    libOrdinal = libVal;
                }

                PDLFixupImport *fixupImport = [[PDLFixupImport alloc] init];
                fixupImport.libOrdinal = libOrdinal;
                fixupImport.symbol = @(symbolName);
                fixupImport.appendex = import->addend;
                fixupImport.weak = import->weak_import;
                [self.fixupImports addObject:fixupImport];
            }
        } break;
        case DYLD_CHAINED_IMPORT_ADDEND64: {
            for (uint32_t i = 0; i < header->imports_count; ++i) {
                struct dyld_chained_import_addend64 *import = &((struct dyld_chained_import_addend64 *)imports)[i];
                const char *symbolName = &symbolsPool[import->name_offset];
                uint8_t libVal = import->lib_ordinal;
                if ( libVal > 0xF0 ) {
                    libOrdinal = (int8_t)libVal;
                } else {
                    libOrdinal = libVal;
                }

                PDLFixupImport *fixupImport = [[PDLFixupImport alloc] init];
                fixupImport.libOrdinal = libOrdinal;
                fixupImport.symbol = @(symbolName);
                fixupImport.appendex = import->addend;
                fixupImport.weak = import->weak_import;
                [self.fixupImports addObject:fixupImport];
            }
        } break;
        default:
            break;
    }

    // starts
    struct dyld_chained_starts_in_image *starts = headerPointer + header->starts_offset;
    for (uint32 i = 0; i < starts->seg_count; i++) {
        uint32 seg_info_offset = starts->seg_info_offset[i];
        if (!seg_info_offset) {
            continue;
        }

        const pdl_segment_command *segment = self.object->total_segments[i];
        struct dyld_chained_starts_in_segment *starts_in_segment = (((void *)starts) + seg_info_offset);
        for (uint32 j = 0; j < starts_in_segment->page_count; j++) {
            uint16_t firstOffset = starts_in_segment->page_start[j];
            if (firstOffset == DYLD_CHAINED_PTR_START_NONE) {
                continue;
            }
            uint32_t page = (uint32_t)(segment->fileoff + starts_in_segment->page_size * j + firstOffset);
            switch (starts_in_segment->pointer_format) {
//#if  __has_feature(ptrauth_calls)
//                case DYLD_CHAINED_PTR_ARM64E:
//                    fixupPageAuth64(pageContent, blob, segInfo, pageIndex, false);
//                    break;
//                case DYLD_CHAINED_PTR_ARM64E_USERLAND:
//                case DYLD_CHAINED_PTR_ARM64E_USERLAND24:
//                    fixupPageAuth64(pageContent, blob, segInfo, pageIndex, true);
//                    break;
//#endif
                case DYLD_CHAINED_PTR_64:
                    [self fixupPage64:page segInfo:starts_in_segment offsetBased:false];
                    break;
                case DYLD_CHAINED_PTR_64_OFFSET:
                    [self fixupPage64:page segInfo:starts_in_segment offsetBased:true];
                    break;
                case DYLD_CHAINED_PTR_32:
//                    fixupPage32(pageOffset, segInfo, pageIndex);
                    break;
                default:
                    NSLog(@"*** Unsupported pointer format %d ***", starts_in_segment->pointer_format);
                    break;
            }
        }
    }
}

- (void)fixupPage64:(uint32_t)pageOffset segInfo:(struct dyld_chained_starts_in_segment *)segInfo offsetBased:(BOOL)offsetBased {
    uint64_t targetAdjust = 0;
    uint32_t offset = pageOffset;
    uint64_t delta = 0;

    do {
        uint64_t value  = *(uint64_t *)(((void *)self.object->header) + offset);
        bool isBind = (value & 0x8000000000000000ULL);
        delta = (value >> 51) & 0xFFF;
        if (isBind) {
            // bind
            uint32_t bindOrdinal = value & 0x00FFFFFF;
            uint32_t addend = (value >> 24) & 0xFF;
            if (bindOrdinal < self.fixupImports.count) {
                PDLFixupImport *fixupImport = self.fixupImports[bindOrdinal];
                NSString *symbol = fixupImport.symbol;
                uint32_t libOrdinal = (uint32_t)fixupImport.libOrdinal;
                if (libOrdinal == 0) {
                    NSNumber *addressNumber = self.symbolsMap[symbol];
                    if (addressNumber) {
                        uint64_t address = [addressNumber unsignedLongLongValue];
                        if (address) {
                            uint64_t newValue = address + addend;
                            [self.data replaceBytesInRange:NSMakeRange(offset, 8) withBytes:&newValue];
//                            NSLog(@"fixup bind 0x%X -> 0x%llX", offset, newValue);
                        } else {
                            NSNumber *addressNumber = self.symbolsMap[symbol];
                            if (addressNumber) {
                                self.externalFixupsSymbolMap[@(value)] = symbol;
                            }
                        }
                    }
                } else {
                    NSNumber *addressNumber = self.symbolsMap[symbol];
                    if (addressNumber) {
                        self.externalFixupsSymbolMap[@(value)] = symbol;
                    }
                }
            }
        } else {
            // rebase
            uint64_t target = value & 0xFFFFFFFFFULL;
            uint64_t high8  = (value >> 36) & 0xFF;
            high8 = high8;
            uint64_t newValue = target + targetAdjust + (high8 << 56);
            [self.data replaceBytesInRange:NSMakeRange(offset, 8) withBytes:&newValue];
//            NSLog(@"fixup rebase 0x%X -> 0x%llX", offset, newValue);
        }
        offset = offset + ((uint32_t)delta * 4); // 4-byte stride
    } while (delta != 0);
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

- (NSUInteger)functionSize:(ptrdiff_t)offset {
    NSNumber *size = self.functionsSize[@(offset)];
    return [size unsignedIntegerValue];
}

- (void *)realAddress:(PDLMachObjectAddress)address {
    intptr_t offset = [self offset:address];
    void *ret = ((void *)self.object->header) + offset;
    return ret;
}

- (PDLMachObjectAddress *)classList:(size_t *)count {
    const pdl_section *section = self.classlistSection;
    if (!section) {
        return NULL;
    }

    size_t size = section->size / sizeof(void *);
    if (count) {
        *count = size;
    }
    return ((void *)self.object->header) + section->offset;
}

- (const char *)classNameOfSymbol:(NSString *)symbolName {
    if (![symbolName hasPrefix:@"_OBJC_CLASS_$_"]) {
        return NULL;
    }

    const char *cstring = [symbolName cStringUsingEncoding:NSUTF8StringEncoding];
    return cstring + [@"_OBJC_CLASS_$_" length];
}

- (const char *)className:(PDLMachObjectAddress)cls {
    if (((unsigned long)cls) & ~0x000007FFFFFFFFFFUL) {
        NSString *symbolName = self.externalFixupsSymbolMap[@((unsigned long)cls)];
        return [self classNameOfSymbol:symbolName];
    }

    struct class_t *c = [self realAddress:cls];
    if (c == NULL) {
        return NULL;
    }

    struct class_ro_t *ro = [self realAddress:c->ro];
    if (((unsigned long)ro & 1) == 1) {
        ro = (struct class_ro_t *)(((unsigned long)ro) & ~1);
    }

    const char *name = [self realAddress:(PDLMachObjectAddress)ro->name];
    return name;
}

- (PDLMachObjectAddress)instanceMethodList:(PDLMachObjectAddress)cls {
    struct class_t *c = [self realAddress:cls];
    struct class_ro_t *ro = [self realAddress:c->ro];
    if (((unsigned long)ro & 1) == 1) {
        ro = (struct class_ro_t *)(((unsigned long)ro) & ~1);
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

- (pdl_section *)swift5typesSection {
    if (_swift5typesSection == PDLMachObjectUninitialized) {
        const char *sectionName = "__swift5_types";
        const pdl_section *section = [self sectionWithSegmentName:"__TEXT" sectionName:sectionName];
        _swift5typesSection = (pdl_section *)section;
    }
    return _swift5typesSection;
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
    bool isSmall = m->list.entsizeAndFlags & 0x80000000;
    for (uint32_t i = 0; i < size; i++) {
        if (isSmall) {
            struct small_method_t *method = &(m->methods.small[i]);
            PDLMachObjectAddress *nameAddress = [self realAddress:(PDLMachObjectAddress)(((unsigned long)(void *)methodList) + ((unsigned long)(void *)&(method->name) - ((unsigned long)(void *)m) + method->name))];
            PDLMachObjectAddress namePointer = *nameAddress;
            const char *name = [self realAddress:namePointer];
            const char *types = [self realAddress:(PDLMachObjectAddress)(((unsigned long)(void *)methodList) + ((unsigned long)(void *)&(method->types) - ((unsigned long)(void *)m) + method->types))];
            PDLMachObjectAddress impAddress = (PDLMachObjectAddress)(((unsigned long)(void *)methodList) + ((unsigned long)(void *)&(method->imp) - ((unsigned long)(void *)m) + method->imp));
            intptr_t impOffset = [self offset:impAddress];
            action(name, types, impOffset);
        } else {
            struct method_t *method = &(m->methods.big[i]);
            const char *name = [self realAddress:method->name];
            const char *types = [self realAddress:(PDLMachObjectAddress)method->types];
            intptr_t impOffset = [self offset:method->imp];
            action(name, types, impOffset);
        }
    }
}

static unsigned long read_intoffset(int32_t *data) {
    int32_t offset = *data;
    unsigned long ret = ((unsigned long)data) + offset;
    return ret;
}

- (char *)swiftName:(struct swift_type *)swiftType {
    uint32_t flags = swiftType->flags;
    uint8_t kind = flags & 0x1F;
    if (kind != SWIFT_CONTEXT_DESCRIPTOR_KIND_MODULE &&
        kind != SWIFT_CONTEXT_DESCRIPTOR_KIND_EXTENSION &&
        kind != SWIFT_CONTEXT_DESCRIPTOR_KIND_ANONYMOUS &&
        kind != SWIFT_CONTEXT_DESCRIPTOR_KIND_PROTOCOL &&
        kind != SWIFT_CONTEXT_DESCRIPTOR_KIND_OPAQUE_TYPE &&
        kind != SWIFT_CONTEXT_DESCRIPTOR_KIND_CLASS &&
        kind != SWIFT_CONTEXT_DESCRIPTOR_KIND_STRUCT &&
        kind != SWIFT_CONTEXT_DESCRIPTOR_KIND_ENUM) {
        return NULL;
    }
    struct swift_type_module *module = (struct swift_type_module *)swiftType;
    if (!module->name) {
        return NULL;
    }

    char *name = (void *)read_intoffset((int32_t *)&module->name);
    return name;
}

- (void)enumerateSwiftTypes:(void(^)(NSString *className, PDLSwiftMethodKind methodKind, BOOL isInstance, BOOL isDynamic, intptr_t impOffset))action {
    if (!action) {
        return;
    }

    pdl_section *swift5typesSection = self.swift5typesSection;
    if (!swift5typesSection) {
        return;
    }

    uint32_t *data = ((void *)self.object->header) + swift5typesSection->offset;
    size_t count = swift5typesSection->size / sizeof(uint32_t);
    for (size_t i = 0; i < count; i++) {
        struct swift_type *swiftType = (struct swift_type *)read_intoffset((int32_t *)(data + i));
        uint32_t flags = swiftType->flags;
        uint8_t kind = flags & 0x1F;
        if (kind != SWIFT_CONTEXT_DESCRIPTOR_KIND_CLASS) {
            continue;
        }

        struct swift_type_class *swiftClass = (struct swift_type_class *)swiftType;
        char *name = (char *)read_intoffset((int32_t *)&swiftClass->name);
        NSMutableArray *classNames = [NSMutableArray array];
        [classNames addObject:@(name)];
        if (swiftClass->parent) {
            struct swift_type *parent = (void *)read_intoffset((int32_t *)&swiftClass->parent);
            while (true) {
                char *name = [self swiftName:parent];
                if (!name) {
                    break;
                }

                [classNames insertObject:@(name) atIndex:0];

                if (!parent->parent) {
                    break;
                }

                parent = (void *)read_intoffset((int32_t *)&parent->parent);
            }
        }

        NSString *className = [classNames componentsJoinedByString:@"."];

        intptr_t accessFunctionOffset = 0;
        if (swiftClass->access_function) {
            void *accessFunction = (void *)read_intoffset((int32_t *)&swiftClass->access_function);
            accessFunctionOffset = accessFunction - ((void *)self.object->header);
            action(className, PDLSwiftMethodKindAccess, NO, NO, accessFunctionOffset);
        }

        void *optional = swiftClass + 1;
        uint16_t descriptorFlags = (flags >> 16) & 0xFFFF;
        BOOL hasResilientSuperclass = descriptorFlags & (1 << Class_HasResilientSuperclass);
        if (hasResilientSuperclass) {
            optional += 4;
        }
        uint8_t metadataInitializationFlag = descriptorFlags & 0x3;
        if (metadataInitializationFlag) {
            optional += 12;
        }
        BOOL hasVTable = descriptorFlags & (1 << Class_HasVTable);
        if (hasVTable) {
            struct swift_vtable_descriptor_header *vtable = optional;
            uint32_t count = vtable->size;
            struct swift_vtable_descriptor *vtableDescriptor = optional + sizeof(struct swift_vtable_descriptor_header);
            for (uint32_t j = 0; j < count; j++) {
                uint32_t flags = vtableDescriptor->flags;
                if (vtableDescriptor->imp) {
                    PDLSwiftMethodKind methodKind = (flags & SWIFT_VTABLE_DESCRIPTOR_MASK_KIND);
                    BOOL isInstance = flags & SWIFT_VTABLE_DESCRIPTOR_MASK_IS_INSTANCE;
                    BOOL isDynamic = flags & SWIFT_VTABLE_DESCRIPTOR_MASK_IS_DYNAMIC;
                    void *imp = (void *)read_intoffset((int32_t *)&vtableDescriptor->imp);
                    intptr_t functionOffset = imp - ((void *)self.object->header);
                    action(className, methodKind, isInstance, isDynamic, functionOffset);
                }
                vtableDescriptor++;
            }
        }

        name = name;
    }
}

@end