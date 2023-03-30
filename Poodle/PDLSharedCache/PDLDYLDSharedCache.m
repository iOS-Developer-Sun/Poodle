//
//  PDLDYLDSharedCache.m
//  Poodle
//
//  Created by Poodle on 2021/12/19.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLDYLDSharedCache.h"
#import <sys/stat.h>
#import "dyld_cache_format.h"
#import "dsc_iterator.h"
#import "pdl_mach_object.h"

@interface PDLDYLDSharedCacheSegment : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) uint64_t fileOffset;
@property (nonatomic, assign) uint64_t fileSize;

@end

@implementation PDLDYLDSharedCacheSegment

@end

@interface PDLDYLDSharedCacheImage : NSObject

@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) uint64_t fileOffset;
@property (nonatomic, assign) uint64_t fileSize;
@property (nonatomic, copy) NSArray <PDLDYLDSharedCacheSegment *>*segments;

@end

@implementation PDLDYLDSharedCacheImage

@end

@interface PDLDYLDSharedCache () {
    struct dyld_cache_header *_header;
    struct dyld_cache_image_info *_image_info;
    struct dyld_cache_mapping_info *_mapping_info;
}

@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, assign, readonly) NSUInteger size;

@property (nonatomic, copy) NSString *magic;
@property (nonatomic, copy) NSArray <PDLDYLDSharedCacheImage *>*images;

@end

@implementation PDLDYLDSharedCache

+ (instancetype)sharedCacheWithPath:(NSString *)path {
    return [[self alloc] initWithPath:path];
}

- (instancetype)initWithPath:(NSString *)path {
    struct stat statbuf;
    if (stat(path.UTF8String, &statbuf)) {
        return nil;
    }

    self = [super init];
    if (self) {
        _path = [path copy];
        _size = (NSUInteger)statbuf.st_size;
    }
    return self;
}

- (void)dealloc {
    free(_header);
    free(_mapping_info);
    free(_image_info);
}

- (BOOL)extract:(NSArray *)imageNames {
    int fd = open(self.path.UTF8String, O_RDONLY);
    if (fd < 0) {
        return NO;
    }

    [self parseMagic:fd];
    [self parseHeader:fd];
    [self walk:fd];
    [self dump:fd imageNames:imageNames];

    close(fd);
    return YES;
}

- (void)parseMagic:(int)fd {
    if (_magic) {
        return;
    }

    char magic[32];
    size_t size = sizeof(magic);
    size_t bytes = pread(fd, magic, sizeof(magic), 0);
    if (bytes == size) {
        _magic = @(magic);
    }
}

- (void)parseHeader:(int)fd {
    size_t size = sizeof(struct dyld_cache_header);
    struct dyld_cache_header *header = malloc(size);
    if (!header) {
        return;
    }

    size_t bytes = pread(fd, header, size, 0);
    if (bytes == size) {
        _header = header;
    } else {
        free(header);
    }
}

- (void)walk:(int)fd {
    struct dyld_cache_header *header = _header;
    if (!header) {
        return;
    }

    uint32_t imagesOffset = header->imagesOffset;
    uint32_t mappingOffset = header->mappingOffset;
    uint32_t imagesCount = header->imagesCount;
    uint32_t mappingCount = header->mappingCount;

    if (imagesCount > 0) {
        size_t image_info_size = sizeof(struct dyld_cache_image_info);
        size_t size = image_info_size * imagesCount;
        struct dyld_cache_image_info *image_info = malloc(size);
        if (image_info) {
            size_t bytes = pread(fd, image_info, size, imagesOffset);
            if (bytes == size) {
                _image_info = image_info;
            } else {
                free(image_info);
                return;
            }
        }
    }

    if (mappingCount > 0) {
        size_t mapping_info_size = sizeof(struct dyld_cache_mapping_info);
        size_t size = mapping_info_size * mappingCount;
        struct dyld_cache_mapping_info *mapping_info = malloc(size);
        if (mapping_info) {
            size_t bytes = pread(fd, mapping_info, size, mappingOffset);
            if (bytes == size) {
                _mapping_info = mapping_info;
            } else {
                free(mapping_info);
                return;
            }
        }
    }

    struct dyld_cache_image_info *image_info = _image_info;
    struct dyld_cache_mapping_info *mapping_info = _mapping_info;

    NSMutableArray *images = [NSMutableArray array];
    for (uint32_t i = 0; i < imagesCount; ++i) {
        struct dyld_cache_image_info *dylibs = image_info + i;
        uint32_t pathFileOffset = dylibs->pathFileOffset;

        size_t path_size = PATH_MAX;
        char path_string[path_size];
        size_t bytes = pread(fd, path_string, path_size, pathFileOffset);
        NSString *path = nil;
        if (bytes == path_size) {
            path = @(path_string);
        }

        uint64_t address = dylibs->address;
        uint64_t fileOffset = 0;
        for (uint32_t j = 0; j < mappingCount; j++) {
            struct dyld_cache_mapping_info *mapping = mapping_info + j;
            uint64_t mapping_address = mapping->address;
            uint64_t mapping_size = mapping->size;
            if ((mapping_address <= address) && (address < (mapping_address + mapping_size)) ) {
                fileOffset = mapping->fileOffset + address - mapping_address;
                break;
            }
        }

        NSMutableArray *segments = [NSMutableArray array];
        __block uint64_t fileSize = 0;
        [self walkSegments:fd headerOffset:fileOffset action:^(PDLDYLDSharedCacheSegment *segment) {
            [segments addObject:segment];
            fileSize += segment.fileSize;
        }];

        PDLDYLDSharedCacheImage *image = [[PDLDYLDSharedCacheImage alloc] init];
        image.path = path;
        image.fileOffset = fileOffset;
        image.fileSize = fileSize;
        image.segments = segments;
        [images addObject:image];
    }
    self.images = images;
}

- (void)walkSegments:(int)fd headerOffset:(uint64_t)headerOffset action:(void(^)(PDLDYLDSharedCacheSegment *))action {
    pdl_mach_header mach_header;
    size_t header_size = sizeof(mach_header);
    size_t bytes = pread(fd, &mach_header, header_size, headerOffset);
    if (bytes != header_size) {
        return;
    }

    size_t sizeofcmds = mach_header.sizeofcmds;
    char cmds_buffer[sizeofcmds];
    bytes = pread(fd, &cmds_buffer, sizeofcmds, headerOffset + header_size);
    if (bytes != sizeofcmds) {
        return;
    }

    struct load_command *cmds = (struct load_command *)cmds_buffer;
    const uint32_t cmd_count = mach_header.ncmds;
    uint64_t cache_file_size = self.size;
    char *cursor = (char *)cmds;
    for (uint32_t i = 0; i < cmd_count; i++) {
        struct load_command *cmd = (struct load_command *)cursor;
        if (cmd->cmd == LC_SEGMENT || cmd->cmd == LC_SEGMENT_64) {
            pdl_segment_command *segCmd = (pdl_segment_command *)cmd;
            uint64_t fileOffset = segCmd->fileoff;
            // work around until <rdar://problem/7022345> is fixed
            if (fileOffset == 0) {
                fileOffset = headerOffset;
            }
            uint64_t sizem = segCmd->vmsize;
            if (strcmp(segCmd->segname, "__LINKEDIT") == 0 ) {
                // clip LINKEDIT size if bigger than cache file
                if ((fileOffset + sizem) > cache_file_size) {
                    sizem = cache_file_size - fileOffset;
                }
            }

            if (segCmd->filesize > segCmd->vmsize) {
                continue;
            }

            PDLDYLDSharedCacheSegment *segment = [[PDLDYLDSharedCacheSegment alloc] init];
            segment.name = @(segCmd->segname);
            segment.fileOffset = fileOffset;
            segment.fileSize = sizem;
            action(segment);
        }
        cursor += cmd->cmdsize;
    }
}

- (void)dump:(int)fd imageNames:(NSArray *)imageNames {
    for (PDLDYLDSharedCacheImage *image in self.images) {
        NSString *name = image.path.lastPathComponent;
        if (![imageNames containsObject:name]) {
            continue;
        }

        [self dump:fd image:image];
    }
}

- (BOOL)dump:(int)fd image:(PDLDYLDSharedCacheImage *)image {
    NSString *destinationPath = self.destinationPath;
    NSString *file = image.path.lastPathComponent;
    NSString *destinationFile = [destinationPath stringByAppendingPathComponent:file];
    char *buffer = (char *)malloc((size_t)image.fileSize);
    uint64_t current_offset = 0;
    for (PDLDYLDSharedCacheSegment *segment in image.segments) {
        uint64_t size = segment.fileSize;
        size_t bytes = pread(fd, buffer + current_offset, (size_t)size, segment.fileOffset);
        assert(bytes == size);
        current_offset += bytes;
    }

    // update header
    pdl_mach_header *header = (pdl_mach_header *)buffer;
    header->flags &= 0x7FFFFFFF;

    // update load commands
    uint64_t cumulativeFileSize = 0;
    struct load_command *cmds = (struct load_command *)(header + 1);
    uint32_t cmd_count = header->ncmds;
    struct load_command *cmd = cmds;
    pdl_segment_command *linkEditSegCmd = NULL;
    struct symtab_command *symtab = NULL;
    struct dysymtab_command *dynamicSymTab = NULL;
    struct linkedit_data_command *functionStarts = NULL;
    struct linkedit_data_command *dataInCode = NULL;
    uint32_t exportsTrieOffset = 0;
    uint32_t exportsTrieSize = 0;
    NSMutableSet *reexportDeps = [NSMutableSet set];
    int depIndex = 0;
    for (uint32_t i = 0; i < cmd_count; i++) {
        switch (cmd->cmd) {
            case LC_SEGMENT:
            case LC_SEGMENT_64: {
                // update segment/section file offsets
                pdl_segment_command *segCmd = (pdl_segment_command *)cmd;
                segCmd->fileoff = (typeof(segCmd->fileoff))cumulativeFileSize;
                pdl_section *sectionsStart = (pdl_section *)((char*)segCmd + sizeof(pdl_segment_command));
                pdl_section *sectionsEnd = &sectionsStart[segCmd->nsects];
                for (pdl_section *sect = sectionsStart; sect < sectionsEnd; sect++) {
                    if (sect->offset != 0)
                        sect->offset = (uint32_t)(cumulativeFileSize + sect->addr - segCmd->vmaddr);
                }
                if (strcmp(segCmd->segname, "__LINKEDIT") == 0) {
                    linkEditSegCmd = segCmd;
                }
                cumulativeFileSize += segCmd->filesize;
            } break;
            case LC_DYLD_INFO_ONLY: {
                // zero out all dyld info
                struct dyld_info_command *dyldInfo = (struct dyld_info_command *)cmd;
                exportsTrieOffset = dyldInfo->export_off;
                exportsTrieSize = dyldInfo->export_size;
                dyldInfo->rebase_off = 0;
                dyldInfo->rebase_size = 0;
                dyldInfo->bind_off = 0;
                dyldInfo->bind_size = 0;
                dyldInfo->weak_bind_off = 0;
                dyldInfo->weak_bind_size = 0;
                dyldInfo->lazy_bind_off = 0;
                dyldInfo->lazy_bind_size = 0;
                dyldInfo->export_off = 0;
                dyldInfo->export_size = 0;
            } break;
            case LC_SYMTAB:
                symtab = (struct symtab_command *)cmd;
                break;
            case LC_DYSYMTAB:
                dynamicSymTab = (struct dysymtab_command *)cmd;
                break;
            case LC_FUNCTION_STARTS:
                functionStarts = (struct linkedit_data_command *)cmd;
                break;
            case LC_DATA_IN_CODE:
                dataInCode = (struct linkedit_data_command *)cmd;
                break;
            case LC_LOAD_DYLIB:
            case LC_LOAD_WEAK_DYLIB:
            case LC_REEXPORT_DYLIB:
            case LC_LOAD_UPWARD_DYLIB:
                ++depIndex;
                if (cmd->cmd == LC_REEXPORT_DYLIB) {
                    [reexportDeps addObject:@(depIndex)];
                }
                break;
        }
        cmd = (struct load_command *)(((uint8_t*)cmd)+cmd->cmdsize);
    }

    // rebuild symbol table
    if (linkEditSegCmd == NULL) {
        return NO;
    }
    if (symtab == NULL) {
        return NO;
    }
    if (dynamicSymTab == NULL) {
        return NO;
    }

    const uint64_t newFunctionStartsOffset = linkEditSegCmd->fileoff;
    uint32_t functionStartsSize = 0;
    if ( functionStarts != NULL ) {
        // copy function starts from original cache file to new mapped dylib file
        functionStartsSize = functionStarts->datasize;
        pread(fd, (char*)header + newFunctionStartsOffset, functionStartsSize, functionStarts->dataoff);
    }
    const uint64_t newDataInCodeOffset = (newFunctionStartsOffset + functionStartsSize + sizeof(void *) - 1) & (-sizeof(void *)); // pointer align
    uint32_t dataInCodeSize = 0;
    if (dataInCode != NULL) {
        // copy data-in-code info from original cache file to new mapped dylib file
        dataInCodeSize = dataInCode->datasize;
        pread(fd, (char *)header + newDataInCodeOffset, dataInCodeSize, dataInCode->dataoff);
    }

//    std::vector<mach_o::trie::Entry> exports;
    if (exportsTrieSize != 0) {
//        char exports[exportsTrieSize];
//        pread(fd, exports, exportsTrieSize, exportsTrieOffset);
//        const uint8_t* exportsStart = (const uint8_t* )exports;
//        const uint8_t* exportsEnd = &exportsStart[exportsTrieSize];
//        mach_o::trie::parseTrie(exportsStart, exportsEnd, exports);
//        exports.erase(std::remove_if(exports.begin(), exports.end(), NotReExportSymbol(reexportDeps)), exports.end());
    }

    // look for local symbol info in unmapped part of shared cache
    struct dyld_cache_header *cache_header = _header;
    pdl_nlist *localNlists = NULL;
    uint32_t localNlistCount = 0;
    char *localStrings = NULL;
    const char *localStringsEnd = NULL;
    if (cache_header->mappingOffset > offsetof(struct dyld_cache_header, localSymbolsSize)) {
        struct dyld_cache_local_symbols_info localInfoSt;
        pread(fd, &localInfoSt, sizeof(localInfoSt), cache_header->localSymbolsOffset);
        struct dyld_cache_local_symbols_info *localInfo = &localInfoSt;
        const uint32_t entriesCount = localInfo->entriesCount;
        struct dyld_cache_local_symbols_entry entriesSt[entriesCount];
        pread(fd, &entriesSt, sizeof(entriesSt), cache_header->localSymbolsOffset + localInfo->entriesOffset);
        struct dyld_cache_local_symbols_entry *entries = &entriesSt[0];
        for (uint32_t i = 0; i < entriesCount; ++i) {
            if (entries[i].dylibOffset == image.fileOffset) {
                uint32_t localNlistStart = entries[i].nlistStartIndex;
                localNlistCount = entries[i].nlistCount;
                size_t localNlistSize = localInfo->nlistCount * sizeof(pdl_nlist);
                localNlists = malloc(localNlistSize);
                pread(fd, localNlists, localNlistSize, cache_header->localSymbolsOffset + localInfo->nlistOffset + localNlistStart * sizeof(pdl_nlist));
                size_t stringsSize = localInfo->stringsSize;
                localStrings = malloc(stringsSize);
                pread(fd, localStrings, stringsSize, cache_header->localSymbolsOffset + localInfo->stringsOffset);
                localStringsEnd = &localStrings[localInfo->stringsSize];
                break;
            }
        }
    }

    // compute number of symbols in new symbol table
    size_t nlist_size = symtab->nsyms * sizeof(pdl_nlist);
    pdl_nlist *mergedSymTab = malloc(nlist_size);
    pread(fd, mergedSymTab, nlist_size, symtab->symoff);
    pdl_nlist *mergedSymTabStart = mergedSymTab;
    pdl_nlist *mergedSymTabend = &mergedSymTabStart[symtab->nsyms];
    uint32_t newSymCount = symtab->nsyms;
    if (localNlists != NULL) {
        newSymCount = localNlistCount;
        for (pdl_nlist *s = mergedSymTabStart; s != mergedSymTabend; s++) {
            // skip any locals in cache
            if ((s->n_type & (N_TYPE | N_EXT)) == N_SECT) {
                continue;
            }
            ++newSymCount;
        }
    }

    // add room for N_INDR symbols for re-exported symbols
//    newSymCount += exports.size();

    // copy symbol entries and strings from original cache file to new mapped dylib file
    const uint64_t newSymTabOffset = (newDataInCodeOffset + dataInCodeSize + sizeof(void *) - 1) & (-sizeof(void *)); // pointer align
    const uint64_t newIndSymTabOffset = newSymTabOffset + newSymCount * sizeof(pdl_nlist);
    const uint64_t newStringPoolOffset = newIndSymTabOffset + dynamicSymTab->nindirectsyms * sizeof(uint32_t);
    pdl_nlist *newSymTabStart = (pdl_nlist *)(((uint8_t *)header) + newSymTabOffset);
    char* const newStringPoolStart = (char*)header + newStringPoolOffset;

    size_t strsize = symtab->strsize;
    char *st = malloc(strsize);
    pread(fd, st, strsize, symtab->stroff);
    const char* mergedStringPoolStart = st;
    const char* mergedStringPoolEnd = &mergedStringPoolStart[symtab->strsize];
    pdl_nlist *t = newSymTabStart;
    int poolOffset = 0;
    uint32_t symbolsCopied = 0;
    newStringPoolStart[poolOffset++] = '\0'; // first pool entry is always empty string
    for (pdl_nlist *s = mergedSymTabStart; s != mergedSymTabend; s++) {
        // if we have better local symbol info, skip any locals here
        if ((localNlists != NULL) && ((s->n_type & (N_TYPE | N_EXT)) == N_SECT)) {
            continue;
        }
        *t = *s;
        t->n_un.n_strx = poolOffset;
        const char* symName = &mergedStringPoolStart[s->n_un.n_strx];
        if (symName > mergedStringPoolEnd) {
            symName = "<corrupt symbol name>";
        }
        strcpy(&newStringPoolStart[poolOffset], symName);
        poolOffset += (strlen(symName) + 1);
        ++t;
        ++symbolsCopied;
    }
    // <rdar://problem/16529213> recreate N_INDR symbols in extracted dylibs for debugger
//    for (std::vector<mach_o::trie::Entry>::iterator it = exports.begin(); it != exports.end(); ++it) {
//        strcpy(&newStringPoolStart[poolOffset], it->name);
//        t->set_n_strx(poolOffset);
//        poolOffset += (strlen(it->name) + 1);
//        t->set_n_type(N_INDR | N_EXT);
//        t->set_n_sect(0);
//        t->set_n_desc(0);
//        const char* importName = it->importName;
//        if ( *importName == '\0' )
//            importName = it->name;
//        strcpy(&newStringPoolStart[poolOffset], importName);
//        t->set_n_value(poolOffset);
//        poolOffset += (strlen(importName) + 1);
//        ++t;
//        ++symbolsCopied;
//    }
    if (localNlists != NULL) {
        // update load command to reflect new count of locals
        dynamicSymTab->ilocalsym = symbolsCopied;
        dynamicSymTab->nlocalsym = localNlistCount;
        // copy local symbols
        for (uint32_t i=0; i < localNlistCount; ++i) {
            const char* localName = &localStrings[localNlists[i].n_un.n_strx];
            if (localName > localStringsEnd) {
                localName = "<corrupt local symbol name>";
            }
            *t = localNlists[i];
            t->n_un.n_strx = poolOffset;
            strcpy(&newStringPoolStart[poolOffset], localName);
            poolOffset += (strlen(localName) + 1);
            ++t;
            ++symbolsCopied;
        }
    }

    if (newSymCount != symbolsCopied) {
        return NO;
    }

    // pointer align string pool size
    while ((poolOffset % sizeof(void *)) != 0) {
        ++poolOffset;
    }

    // copy indirect symbol table
    uint32_t *newIndSymTab = (uint32_t*)((char*)header + newIndSymTabOffset);
    pread(fd, newIndSymTab, dynamicSymTab->nindirectsyms * sizeof(uint32_t), dynamicSymTab->indirectsymoff);

    // update load commands
    if ( functionStarts != NULL ) {
        functionStarts->dataoff = (uint32_t)newFunctionStartsOffset;
        functionStarts->datasize = functionStartsSize;
    }
    if ( dataInCode != NULL ) {
        dataInCode->dataoff = (uint32_t)newDataInCodeOffset;
        dataInCode->datasize = dataInCodeSize;
    }
    symtab->nsyms = symbolsCopied;
    symtab->symoff = (uint32_t)newSymTabOffset;
    symtab->stroff = (uint32_t)newStringPoolOffset;
    symtab->strsize = poolOffset;
    dynamicSymTab->extreloff = 0;
    dynamicSymTab->nextrel = 0;
    dynamicSymTab->locreloff = 0;
    dynamicSymTab->nlocrel = 0;
    dynamicSymTab->indirectsymoff = (uint32_t)newIndSymTabOffset;
    linkEditSegCmd->filesize = symtab->stroff + symtab->strsize - linkEditSegCmd->fileoff;
    linkEditSegCmd->vmsize = (linkEditSegCmd->filesize + 4095) & (-4096);

    // return new size
    size_t newSize = (symtab->stroff + symtab->strsize + 4095) & (-4096);

    BOOL ret = NO;
    @autoreleasepool {
        NSString *tmp = [self.tmpPath ?: NSTemporaryDirectory() stringByAppendingPathComponent:file];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:newSize];
        ret = [data writeToFile:tmp atomically:YES];
        if (ret) {
            ret = [[NSFileManager defaultManager] moveItemAtPath:tmp toPath:destinationFile error:nil];
        }
    }

    free(localStrings);
    free(localNlists);
    free(st);
    free(mergedSymTab);

    return ret;
}

@end
