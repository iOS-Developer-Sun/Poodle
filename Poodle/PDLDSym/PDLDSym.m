//
//  PDLDSym.m
//  Poodle
//
//  Created by Poodle on 2023/8/3.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLDSym.h"
#import <mach-o/stab.h>

#define DW_TAG_compile_unit 0x11
#define DW_TAG_base_type 0x24
#define DW_TAG_subprogram 0x2e
#define DW_TAG_variable 0x34

#define DW_AT_location 0x02
#define DW_AT_name 0x03
#define DW_AT_byte_size 0x0b
#define DW_AT_low_pc 0x11
#define DW_AT_high_pc 0x12
#define DW_AT_encoding 0x3e
#define DW_AT_external 0x3f
#define DW_AT_type 0x49

#define DW_FORM_strp 0x0e
#define DW_FORM_addr 0x01
#define DW_FORM_data4 0x06
#define DW_FORM_data1 0x0b
#define DW_FORM_ref4 0x13
#define DW_FORM_exprloc 0x18
#define DW_FORM_flag_present 0x19

#define DW_CHILDREN_no 0x00
#define DW_CHILDREN_yes 0x01

#define DW_ATE_unsigned 0x7

#define DW_OP_addr 0x03

#define PDL_ADD_N_STAB 0

#define PDL_DIE_INDEX_CU 1
#define PDL_DIE_INDEX_BASE_TYPE 2
#define PDL_DIE_INDEX_FUNCTION 3
#define PDL_DIE_INDEX_VARIABLE 4

#define page_align(size) ((size + NSPageSize() - 1) & ~(NSPageSize() - 1))

struct pdl_debug_info_cu {
    uint32_t length;
    uint16_t version;
    uint32_t abbr_offset;
    uint8_t cu_type;
} __attribute__ ((aligned (1), packed));
_Static_assert(sizeof(struct pdl_debug_info_cu) == 11, "");

#define PDL_DIE_INDEX_SIZE 1
#define PDL_SIZE_DW_FORM_flag_present 0
#define PDL_SIZE_DW_FORM_data1 1
#define PDL_SIZE_DW_FORM_strp 4
#define PDL_SIZE_DW_FORM_data4 4
#define PDL_SIZE_DW_FORM_ref4 4
#define PDL_SIZE_DW_FORM_addr sizeof(unsigned long)
#define PDL_SIZE_DW_FORM_exprloc 10

static char PDLCompileUnitItem[] = {
    PDL_DIE_INDEX_CU,
    DW_TAG_compile_unit, DW_CHILDREN_yes,

    DW_AT_name, DW_FORM_strp,

    0, 0
};
#define PDL_INFO_CU_SIZE ( \
    PDL_DIE_INDEX_SIZE \
    \
    + PDL_SIZE_DW_FORM_strp \
)

static char PDLBaseTypeItem[] = {
    PDL_DIE_INDEX_BASE_TYPE,
    DW_TAG_base_type, DW_CHILDREN_no,

    DW_AT_name, DW_FORM_strp,
    DW_AT_encoding, DW_FORM_data1,
    DW_AT_byte_size, DW_FORM_data1,

    0, 0
};
#define PDL_INFO_BASE_TYPE_SIZE ( \
    PDL_DIE_INDEX_SIZE \
    \
    + PDL_SIZE_DW_FORM_strp \
    + PDL_SIZE_DW_FORM_data1 \
    + PDL_SIZE_DW_FORM_data1 \
)

static char PDLSubprogramItem[] = {
    PDL_DIE_INDEX_FUNCTION,
    DW_TAG_subprogram, DW_CHILDREN_no,

    DW_AT_name, DW_FORM_strp,
    DW_AT_low_pc, DW_FORM_addr,
    DW_AT_high_pc, DW_FORM_data4,

    0, 0
};
#define PDL_INFO_FUNCTION_SIZE ( \
    PDL_DIE_INDEX_SIZE \
    \
    + PDL_SIZE_DW_FORM_strp \
    + PDL_SIZE_DW_FORM_addr \
    + PDL_SIZE_DW_FORM_data4 \
)

static char PDLVariableItem[] = {
    PDL_DIE_INDEX_VARIABLE,
    DW_TAG_variable, DW_CHILDREN_no,

    DW_AT_name, DW_FORM_strp,
    DW_AT_type, DW_FORM_ref4,
    DW_AT_location, DW_FORM_exprloc,
    DW_AT_external, DW_FORM_flag_present,

    0, 0
};
#define PDL_INFO_VARIABLE_SIZE ( \
    PDL_DIE_INDEX_SIZE \
    \
    + PDL_SIZE_DW_FORM_strp \
    + PDL_SIZE_DW_FORM_ref4 \
    + PDL_SIZE_DW_FORM_exprloc \
    + PDL_SIZE_DW_FORM_flag_present \
)

@interface PDLDSym () {
    pdl_mach_object _object;
}

@property (nonatomic, readonly) NSMutableDictionary *offsetToSymbol;
@property (nonatomic, readonly) NSMutableDictionary *offsetToDebugName;
@property (nonatomic, readonly) NSMutableArray *variables;
@property (nonatomic, readonly) NSDictionary *functionsSize;
@property (nonatomic, readonly) NSArray *functions;

@end

@implementation PDLDSym

- (instancetype)initWithObject:(pdl_mach_object)machObject {
    BOOL supported = NO;
#ifdef __LP64__
    supported = YES;
#endif
    if (!supported || !machObject.is64) {
        return nil;
    }

    self = [super init];
    if (self) {
        _object = machObject;
        _machObject = &_object;
        _offsetToSymbol = [NSMutableDictionary dictionary];
        _offsetToDebugName = [NSMutableDictionary dictionary];
        _variables = [NSMutableArray array];
        _unnamedSymbolPrefix = @"___pdl_unnamed_symbol";
        [self findFunctions];
    }
    return self;
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

// const debug strings
#define PDL_CONST_DEBUG_CU_NAME @"Poodle"
#define PDL_CONST_DEBUG_VARIABLE_TYPE_STRING @"unsigned long"
- (NSArray *)constDebugStrings {
    return @[
        PDL_CONST_DEBUG_CU_NAME,
        PDL_CONST_DEBUG_VARIABLE_TYPE_STRING,
    ];
}

- (void)findFunctions {
    pdl_mach_object *machObject = self.machObject;
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

- (BOOL)addSymbol:(NSString *)symbol debugName:(NSString *)debugName offset:(ptrdiff_t)offset {
    assert(symbol);
    assert(offset > 0);
    if (self.offsetToSymbol[@(offset)]) {
        return NO;
    }

    self.offsetToSymbol[@(offset)] = symbol;
    self.offsetToDebugName[@(offset)] = debugName ?: symbol;
    if (!self.functionsSize[@(offset)]) {
        [self.variables addObject:@(offset)];
    }
    return YES;
}

- (BOOL)dump:(NSString *)path {
    NSInteger functionCount = self.functions.count;
    NSInteger variableCount = self.variables.count;
    NSInteger symbolCount = functionCount + variableCount;
    size_t symtabSize = symbolCount * sizeof(pdl_nlist) *
#if PDL_ADD_N_STAB
        2
#else
        1
#endif
    ;
    size_t strtabSize = 1;
    NSMutableDictionary *symbolToOffsets = [NSMutableDictionary dictionary];
    NSMutableDictionary *offsetToSymbol = [self.offsetToSymbol mutableCopy];
    NSMutableDictionary *symbolToDebugNameOffsets = [NSMutableDictionary dictionary];
    NSMutableDictionary *offsetToDebugName = [self.offsetToDebugName mutableCopy];
    NSInteger unnamedIndex = 1;
    NSString *unnamedSymbolPrefix = self.unnamedSymbolPrefix;
    for (NSNumber *offset in self.functions) {
        if (offsetToSymbol[offset]) {
            continue;
        }

        offsetToSymbol[offset] = [NSString stringWithFormat:@"%@%@", unnamedSymbolPrefix, @(unnamedIndex)];
        offsetToDebugName[offset] = [NSString stringWithFormat:@"%@%@", unnamedSymbolPrefix, @(unnamedIndex)];
        unnamedIndex++;
    }

    _unnamedCount = unnamedIndex - 1;
    _totalCount = self.functions.count;

    NSArray *offsets = [offsetToSymbol.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSArray *allStrings = [offsetToSymbol.allValues sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *strings = [NSMutableArray array];
    for (NSString *string in allStrings) {
        if (symbolToOffsets[string]) {
            continue;
        }

        [strings addObject:string];
        symbolToOffsets[string] = @(strtabSize);
        strtabSize += string.length + 1;
    }

    uint32_t cuNameStringIndex = 0;
    uint32_t variableTypeStringIndex = 0;

    size_t debugStrSize = 1;
    NSArray *constDebugStrings = [self constDebugStrings];
    for (NSString *constDebugString in constDebugStrings) {
        if ([constDebugString isEqualToString:PDL_CONST_DEBUG_CU_NAME]) {
            cuNameStringIndex = (uint32_t)debugStrSize;
        } else if ([constDebugString isEqualToString:PDL_CONST_DEBUG_VARIABLE_TYPE_STRING]) {
            variableTypeStringIndex = (uint32_t)debugStrSize;
        }
        debugStrSize += constDebugString.length + 1;
    }

    NSArray *allDebugStrings = [offsetToDebugName.allValues sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *debugStrings = [NSMutableArray array];
    for (NSString *string in allDebugStrings) {
        if (symbolToDebugNameOffsets[string]) {
            continue;
        }

        symbolToDebugNameOffsets[string] = @(debugStrSize);
        [debugStrings addObject:string];
        debugStrSize += string.length + 1;
    }

    pdl_mach_object *machObject = self.machObject;

    // calculate size
    uint32_t headerSize = sizeof(pdl_mach_header);
    uint32_t loadCommandsSize = sizeof(struct uuid_command)
    + sizeof(struct symtab_command)
    + machObject->total_segments_count * sizeof(pdl_segment_command)
    + machObject->sections_count * sizeof(pdl_section)
    + sizeof(pdl_segment_command);
    size_t headerLoadCommandsAlignedSize = page_align(headerSize + loadCommandsSize);
    size_t linkeditSize = symtabSize + strtabSize;
    size_t linkeditAlignedSize = page_align(linkeditSize);
    size_t debugAbbrevSize = sizeof(PDLCompileUnitItem) + sizeof(PDLBaseTypeItem) + sizeof(PDLSubprogramItem) + sizeof(PDLVariableItem) + 1;
    size_t debugInfoSize = sizeof(struct pdl_debug_info_cu) + PDL_INFO_CU_SIZE + PDL_INFO_BASE_TYPE_SIZE + PDL_INFO_FUNCTION_SIZE * functionCount + PDL_INFO_VARIABLE_SIZE * variableCount + 1;
    size_t dwarfSize = debugAbbrevSize + debugInfoSize + debugStrSize;
    size_t dwarfAlignedSize = page_align(dwarfSize);
    size_t totalLength = headerLoadCommandsAlignedSize + linkeditAlignedSize + dwarfSize;

    char *buffer = calloc(totalLength, 1);
    NSInteger offset = 0;
    pdl_segment_command *text = (pdl_segment_command *)machObject->text_segment_command;
    NSInteger base = text->vmaddr;
    NSInteger sectionCount = 0;

#pragma mark header
    {
        pdl_mach_header *header = (typeof(header))(buffer + offset);
        offset += sizeof(*header);
        pdl_mach_header *originalHeader = (typeof(originalHeader))machObject->header;
        header->magic = originalHeader->magic;
        header->cputype = originalHeader->cputype;
        header->cpusubtype = originalHeader->cpusubtype;
        header->filetype = MH_DSYM;
        header->ncmds = 3 + machObject->total_segments_count;
        header->sizeofcmds = loadCommandsSize;
        header->flags = 0;
        header->reserved = 0;
    }

#pragma mark lc uuid
    {
        struct uuid_command *uuid = (typeof(uuid))(buffer + offset);
        offset += sizeof(*uuid);
        const struct uuid_command *originalUuid = machObject->uuid_command;
        uuid->cmd = originalUuid->cmd;
        uuid->cmdsize = originalUuid->cmdsize;
        memcpy(uuid->uuid, originalUuid->uuid, sizeof(uuid->uuid));
    }

    // lc symtab
    {
        struct symtab_command *symtab = (typeof(symtab))(buffer + offset);
        offset += sizeof(*symtab);
        symtab->cmd = LC_SYMTAB;
        symtab->cmdsize = sizeof(*symtab);
        symtab->symoff = (uint32_t)headerLoadCommandsAlignedSize;
        symtab->nsyms = (uint32_t)symbolCount *
#if PDL_ADD_N_STAB
        2
#else
        1
#endif
        ;
        symtab->stroff = (uint32_t)(headerLoadCommandsAlignedSize + symtabSize);
        symtab->strsize = (uint32_t)strtabSize;
    }

    // lc linkedit
    pdl_segment_command *linkedit = (typeof(linkedit))(buffer + offset);
    {
        offset += sizeof(*linkedit);
        pdl_segment_command *originalLinkEdit = (typeof(originalLinkEdit))machObject->linkedit_segment_command;
        linkedit->cmd = originalLinkEdit->cmd;
        linkedit->cmdsize = sizeof(*linkedit);
        strcpy(linkedit->segname, originalLinkEdit->segname);
        linkedit->vmaddr = originalLinkEdit->vmaddr;
        linkedit->vmsize = linkeditAlignedSize;
        linkedit->fileoff = headerLoadCommandsAlignedSize;
        linkedit->filesize = linkeditSize;
        linkedit->maxprot = originalLinkEdit->maxprot;
        linkedit->initprot = originalLinkEdit->initprot;
        linkedit->nsects = 0;
        linkedit->flags = originalLinkEdit->flags;
    }

#pragma mark lc segment with sections
    {
        for (int i = 0; i < machObject->total_segments_count; i++) {
            pdl_segment_command *original = (typeof(original))machObject->total_segments[i];
            if (original == (pdl_segment_command *)(machObject->linkedit_segment_command)) {
                continue;
            }

            pdl_segment_command *segment = (typeof(segment))(buffer + offset);
            offset += sizeof(*segment);
            segment->cmd = original->cmd;
            segment->cmdsize = original->cmdsize;
            strcpy(segment->segname, original->segname);
            segment->vmaddr = original->vmaddr;
            segment->vmsize = original->vmsize;
            segment->fileoff = 0;
            segment->filesize = 0;
            segment->maxprot = original->maxprot;
            segment->initprot = original->initprot;
            segment->nsects = original->nsects;
            segment->flags = original->flags;
            sectionCount += original->nsects;
            for (int j = 0; j < original->nsects; j++) {
                pdl_section *section = (typeof(section))(buffer + offset);
                offset += sizeof(*section);
                pdl_section *originalSection = ((void *)(original + 1)) + sizeof(*section) * j;
                memcpy(section, originalSection, sizeof(*section));
                section->offset = 0;
            }
        }
    }

#pragma mark lc dwarf
    {
        pdl_segment_command *dwarf = (typeof(dwarf))(buffer + offset);
        offset += sizeof(*dwarf);
        dwarf->cmd = machObject->is64 ?  LC_SEGMENT_64 : LC_SEGMENT;
        dwarf->cmdsize = sizeof(*dwarf) + sizeof(pdl_section) * 3;
        strcpy(dwarf->segname, "__DWARF");
        dwarf->vmaddr = page_align(linkedit->vmaddr + linkedit->vmsize);
        dwarf->vmsize = dwarfAlignedSize;
        dwarf->fileoff = headerLoadCommandsAlignedSize + linkeditAlignedSize;
        dwarf->filesize = dwarfSize;
        dwarf->maxprot = VM_PROT_READ | VM_PROT_WRITE | VM_PROT_EXECUTE;
        dwarf->initprot = VM_PROT_READ | VM_PROT_WRITE;
        dwarf->nsects = 3;
        dwarf->flags = 0;

        size_t sectionAddr = dwarf->vmaddr;
        size_t sectionOffset = dwarf->fileoff;

        {
            pdl_section *debugAbbrevSection = (pdl_section *)(buffer + offset);
            offset += sizeof(pdl_section);
            strcpy(debugAbbrevSection->sectname, "__debug_abbrev");
            strcpy(debugAbbrevSection->segname, "__DWARF");
            debugAbbrevSection->addr = sectionAddr;
            debugAbbrevSection->size = debugAbbrevSize;
            debugAbbrevSection->offset = (uint32_t)sectionOffset;
            sectionAddr += debugAbbrevSize;
            sectionOffset += debugAbbrevSize;
        }

        {
            pdl_section *debugInfoSection = (pdl_section *)(buffer + offset);
            offset += sizeof(pdl_section);
            strcpy(debugInfoSection->sectname, "__debug_info");
            strcpy(debugInfoSection->segname, "__DWARF");
            debugInfoSection->addr = sectionAddr;
            debugInfoSection->size = debugInfoSize;
            debugInfoSection->offset = (uint32_t)sectionOffset;
            sectionAddr += debugInfoSize;
            sectionOffset += debugInfoSize;
        }

        {
            pdl_section *debugStrSection = (pdl_section *)(buffer + offset);
            offset += sizeof(pdl_section);
            strcpy(debugStrSection->sectname, "__debug_str");
            strcpy(debugStrSection->segname, "__DWARF");
            debugStrSection->addr = sectionAddr;
            debugStrSection->size = debugStrSize;
            debugStrSection->offset = (uint32_t)sectionOffset;
            sectionAddr += debugStrSize;
            sectionOffset += debugStrSize;
        }
    }

    offset = page_align(offset);
    assert(offset == headerLoadCommandsAlignedSize);
    assert(sectionCount == machObject->sections_count);

#pragma mark symbol table
    {
        pdl_nlist *nlist = (typeof(nlist))(buffer + offset);

        // N_SECT
        for (NSNumber *offsetOfSymbol in offsets) {
            NSString *symbol = offsetToSymbol[offsetOfSymbol];
            uint32_t n_strx = [symbolToOffsets[symbol] unsignedIntValue];
            nlist->n_un.n_strx = n_strx;
            nlist->n_type = N_SECT;
            uint8_t sectionIndex = 0;
            unsigned long value = base + offsetOfSymbol.unsignedIntegerValue;
            for (NSInteger i = 0; i < machObject->sections_count; i++) {
                pdl_section *section = (pdl_section *)machObject->sections[i];
                if (value >= section->addr && value < section->addr + section->size) {
                    sectionIndex = i + 1;
                    break;
                }
            }
            nlist->n_sect = sectionIndex;
            nlist->n_desc = 0;
            nlist->n_value = value;

            nlist++;
            offset += sizeof(*nlist);
        }

        // N_STAB
#if PDL_ADD_N_STAB
        for (NSNumber *offsetOfSymbol in offsets) {
            NSString *symbol = offsetToSymbol[offsetOfSymbol];
            uint32_t n_strx = [symbolToOffsets[symbol] unsignedIntValue];
            nlist->n_un.n_strx = n_strx;
            nlist->n_type = N_FUN;
            uint8_t sectionIndex = 0;
            unsigned long value = base + offsetOfSymbol.unsignedIntegerValue;
            for (NSInteger i = 0; i < machObject->sections_count; i++) {
                pdl_section *section = (pdl_section *)machObject->sections[i];
                if (value >= section->addr && value < section->addr + section->size) {
                    sectionIndex = i + 1;
                    break;
                }
            }
            nlist->n_sect = sectionIndex;
            nlist->n_desc = 0;
            nlist->n_value = value;

            nlist++;
            offset += sizeof(*nlist);
        }
#endif
    }

#pragma mark string table
    {
        char *str = buffer + offset;
        offset += strtabSize;
        str[0] = 0;
        str++;

        for (NSString *string in strings) {
            const char *s = string.UTF8String;
            strcpy(str, s);
            size_t stringOffset = strlen(s) + 1;
            str += stringOffset;
        }

        assert(buffer + offset == str);
    }

    offset = page_align(offset);
    assert(offset == headerLoadCommandsAlignedSize + linkeditAlignedSize);

#pragma mark dwarf
    {
#pragma mark debug_abbrev
        {
            char *debug_abbrev = buffer + offset;
            offset += debugAbbrevSize;

#pragma mark DW_TAG_compile_unit
            {
                memcpy(debug_abbrev, &PDLCompileUnitItem, sizeof(PDLCompileUnitItem));
                debug_abbrev += sizeof(PDLCompileUnitItem);
            }

#pragma mark DW_TAG_base_type
            {
                memcpy(debug_abbrev, &PDLBaseTypeItem, sizeof(PDLBaseTypeItem));
                debug_abbrev += sizeof(PDLBaseTypeItem);
            }

#pragma mark DW_TAG_subprogram
            {
                memcpy(debug_abbrev, &PDLSubprogramItem, sizeof(PDLSubprogramItem));
                debug_abbrev += sizeof(PDLSubprogramItem);
            }

#pragma mark DW_TAG_variable
            {
                memcpy(debug_abbrev, &PDLVariableItem, sizeof(PDLVariableItem));
                debug_abbrev += sizeof(PDLVariableItem);
            }
            *debug_abbrev = 0;
        }

#pragma mark debug_info
        {
            char *debug_info = buffer + offset;
            uint32_t variableTypeOffset = 0;
            char *debug_info_current = buffer + offset;
            offset += debugInfoSize;

#pragma mark cu
            {
                struct pdl_debug_info_cu *cu = (struct pdl_debug_info_cu *)debug_info_current;
                debug_info_current += sizeof(struct pdl_debug_info_cu);
                cu->length = (uint32_t)(debugInfoSize - 4);
                cu->version = 4;
                cu->abbr_offset = 0;
                cu->cu_type = 8;
            }

#pragma mark DW_TAG_compile_unit
            {
                // DW_TAG_compile_unit, DW_CHILDREN_yes
                *debug_info_current = PDL_DIE_INDEX_CU;
                debug_info_current++;

                // DW_AT_name, DW_FORM_strp
                uint32_t n_strx = cuNameStringIndex;
                memcpy(debug_info_current, &n_strx, sizeof(n_strx));
                debug_info_current += sizeof(n_strx);
            }

#pragma mark DW_TAG_base_type
            {
                variableTypeOffset = (uint32_t)(debug_info_current - debug_info);

                // DW_TAG_base_type, DW_CHILDREN_no
                *debug_info_current = PDL_DIE_INDEX_BASE_TYPE;
                debug_info_current++;

                // DW_AT_name, DW_FORM_strp
                uint32_t n_strx = variableTypeStringIndex;
                memcpy(debug_info_current, &n_strx, sizeof(n_strx));
                debug_info_current += sizeof(n_strx);

                // DW_AT_encoding, DW_FORM_data1
                *debug_info_current = DW_ATE_unsigned;
                debug_info_current++;

                // DW_AT_byte_size, DW_FORM_data1
                *debug_info_current = sizeof(unsigned long);
                debug_info_current++;
            }

#pragma mark DW_TAG_subprogram
            for (int i = 0; i < functionCount; i++) {
                char *checkBase = debug_info_current;

                NSNumber *offsetOfSymbol = self.functions[i];
                NSString *symbol = offsetToDebugName[offsetOfSymbol];
                uint32_t n_strx = [symbolToDebugNameOffsets[symbol] unsignedIntValue];
                unsigned long value = base + offsetOfSymbol.unsignedIntegerValue;
                uint32_t length = [self.functionsSize[offsetOfSymbol] unsignedIntValue];
                assert(length != 0);

                // DW_TAG_subprogram, DW_CHILDREN_no
                *debug_info_current = PDL_DIE_INDEX_FUNCTION;
                debug_info_current++;

                // DW_AT_name, DW_FORM_strp
                memcpy(debug_info_current, &n_strx, sizeof(n_strx));
                debug_info_current += sizeof(n_strx);

                // DW_AT_low_pc, DW_FORM_addr
                memcpy(debug_info_current, &value, sizeof(value));
                debug_info_current += sizeof(value);

                // DW_AT_high_pc, DW_FORM_data4
                memcpy(debug_info_current, &length, sizeof(length));
                debug_info_current += sizeof(length);

                assert(debug_info_current - checkBase == PDL_INFO_FUNCTION_SIZE);
            }

#pragma mark DW_TAG_variable
            for (int i = 0; i < variableCount; i++) {
                char *checkBase = debug_info_current;

                NSNumber *offsetOfSymbol = self.variables[i];
                NSString *symbol = offsetToDebugName[offsetOfSymbol];
                uint32_t n_strx = [symbolToDebugNameOffsets[symbol] unsignedIntValue];
                uint32_t type_offset = variableTypeOffset;
                unsigned long value = base + offsetOfSymbol.unsignedIntegerValue;

                // DW_TAG_variable, DW_CHILDREN_no
                *debug_info_current = PDL_DIE_INDEX_VARIABLE;
                debug_info_current++;

                // DW_AT_name, DW_FORM_strp
                memcpy(debug_info_current, &n_strx, sizeof(n_strx));
                debug_info_current += sizeof(n_strx);

                // DW_AT_type, DW_FORM_ref4
                memcpy(debug_info_current, &type_offset, sizeof(type_offset));
                debug_info_current += sizeof(type_offset);

                // DW_AT_location, DW_FORM_exprloc
                *debug_info_current = 1 + sizeof(void *);
                debug_info_current++;
                *debug_info_current = DW_OP_addr;
                debug_info_current++;
                memcpy(debug_info_current, &value, sizeof(value));
                debug_info_current += sizeof(value);

                // DW_AT_external, DW_FORM_flag_present

                assert(debug_info_current - checkBase == PDL_INFO_VARIABLE_SIZE);
            }
            *debug_info_current = 0;
            debug_info_current++;
            assert(debug_info_current - debug_info == debugInfoSize);
        }

#pragma mark debug_str
        {
            char *str = buffer + offset;
            offset += debugStrSize;
            str[0] = 0;
            str++;

            for (NSString *constDebugString in constDebugStrings) {
                const char *s = constDebugString.UTF8String;
                strcpy(str, s);
                size_t stringOffset = strlen(s) + 1;
                str += stringOffset;
            }

            for (NSString *string in debugStrings) {
                const char *s = string.UTF8String;
                strcpy(str, s);
                size_t stringOffset = strlen(s) + 1;
                str += stringOffset;
            }
        }
    }

    assert(offset == totalLength);
    NSData *data = [NSData dataWithBytesNoCopy:buffer length:totalLength];
    BOOL ret = [data writeToFile:path atomically:YES];
    return ret;
}

@end
