//
//  pdl_mach_o_const_symbols.m
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "pdl_mach_o_const_symbols.h"
#import <Foundation/Foundation.h>
#import <mach-o/ldsyms.h>
#import <dlfcn.h>
#import "pdl_mach_o_symbols.h"
#import "dsc_extractor.h"
#import "pdl_mach_object.h"

#if !TARGET_IPHONE_SIMULATOR

#define DYLD_NO_STRICT_ARCH_CHECKING 1

@interface PDLConstSymbol : NSObject <NSCoding>

@property (nonatomic, assign) uint8_t n_type;
@property (nonatomic, assign) uint8_t n_sect;
@property (nonatomic, assign) int16_t n_desc;
@property (nonatomic, assign) uint64_t n_value;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) cpu_type_t cputype;
@property (nonatomic, assign) cpu_subtype_t cpusubtype;

@end

@implementation PDLConstSymbol

- (NSString *)description {
    NSString *description = [super description];
    return [description stringByAppendingFormat:@"name: %@, n_type: %@, n_sect: %@, n_desc: %@, n_value: %@", self.name, @(self.n_type), @(self.n_sect), @(self.n_desc), @(self.n_value)];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.n_type) forKey:@"n_type"];
    [aCoder encodeObject:@(self.n_sect) forKey:@"n_sect"];
    [aCoder encodeObject:@(self.n_desc) forKey:@"n_desc"];
    [aCoder encodeObject:@(self.n_value) forKey:@"n_value"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:@(self.cputype) forKey:@"cputype"];
    [aCoder encodeObject:@(self.cpusubtype) forKey:@"cpusubtype"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _n_type = [[aDecoder decodeObjectForKey:@"n_type"] unsignedCharValue];
        _n_sect = [[aDecoder decodeObjectForKey:@"n_sect"] unsignedCharValue];
        _n_desc = [[aDecoder decodeObjectForKey:@"n_desc"] unsignedShortValue];
        _n_value = [[aDecoder decodeObjectForKey:@"n_value"] unsignedLongLongValue];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _cputype = [[aDecoder decodeObjectForKey:@"cputype"] intValue];
        _cpusubtype = [[aDecoder decodeObjectForKey:@"cpusubtype"] intValue];
    }
    return self;
}

@end

@interface PDLConstSymbols : NSObject

@property (nonatomic, assign) pdl_mach_o_const_symbols_state currentState;
@property (atomic, copy) NSDictionary *table;

@end

@implementation PDLConstSymbols

+ (NSString *)key {
    return @"PDLConstSymbols_v1";
}

+ (NSDictionary *)table {
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 12) {
        return @{
                 @"Foundation" : @[@"_NSThreadGet0"],
                 @"libsystem_pthread.dylib" : @[@"_pthread_count"],
                 };
    } else {
        return @{
                 @"Foundation" : @[@"_NSThreadGet0", @"__NSThreads.oAllThreads"],
                 @"libsystem_pthread.dylib" : @[@"_pthread_count"],
                 };
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self sharedInstance];
    });
}

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (NSUserDefaults *)userDefaults {
    return [[NSUserDefaults alloc] initWithSuiteName:NSStringFromClass(self)];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self load];
            });
        });
    }
    return self;
}

- (void)load {
    struct mach_header *header = pdl_execute_header();
    NSString *arch = [self archWithHeader:header];
    if (arch == nil) {
        self.currentState = PDL_MACH_O_SYMBOLS_STATE_ERROR;
        return;
    }

    NSDictionary *allTasks = [self.class table];
#if DYLD_NO_STRICT_ARCH_CHECKING
    NSString *anyLibraryName = allTasks.allKeys.firstObject;
    struct mach_header *anyLibraryHeader = pdl_mach_o_image(anyLibraryName.UTF8String);
    arch = [self archWithHeader:anyLibraryHeader];
    if (arch == nil) {
        self.currentState = PDL_MACH_O_SYMBOLS_STATE_ERROR;
        return;
    }
#endif

    NSString *key = [NSString stringWithFormat:@"%@_%@", [self.class key], arch];
    NSUserDefaults *standardUserDefaults = [self.class userDefaults];
    NSData *data = [standardUserDefaults objectForKey:key];
    NSDictionary *savedTable = nil;
    if (data) {
        savedTable = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    self.table = savedTable;

    NSMutableDictionary *table = [NSMutableDictionary dictionaryWithDictionary:savedTable];
    NSMutableDictionary *tasks = [NSMutableDictionary dictionary];
    for (NSString *imageName in allTasks) {
        NSDictionary *symbols = table[imageName];
        NSArray *symbolNames = allTasks[imageName];
        BOOL needsExtract = NO;
        for (NSString *symbol in symbolNames) {
            if (symbols[symbol] == nil) {
                needsExtract = YES;
                break;
            }
        }

        if (!needsExtract) {
            continue;
        }

        tasks[imageName] = allTasks[imageName];
    }

    BOOL hasError = NO;
    if (tasks.count) {
        NSDictionary *ret = [self createTable:tasks forArch:arch];
        if (ret) {
            [table addEntriesFromDictionary:ret];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:table];
            [standardUserDefaults setObject:data forKey:key];
            [standardUserDefaults synchronize];
        } else {
            hasError = YES;
        }
    }

    self.table = table;
    if (hasError) {
        self.currentState = PDL_MACH_O_SYMBOLS_STATE_ERROR;
    } else {
        self.currentState = PDL_MACH_O_SYMBOLS_STATE_READY;
    }
}

- (NSString *)archWithHeader:(struct mach_header *)header {
    if (header == NULL) {
        return nil;
    }

    NSDictionary *archTable = @{
                                @(CPU_TYPE_ARM) : @{
                                        @(CPU_SUBTYPE_ARM_ALL) : @"arm",
                                        @(CPU_SUBTYPE_ARM_V4T) : @"armv4",
                                        @(CPU_SUBTYPE_ARM_V6) : @"armv6",
                                        @(CPU_SUBTYPE_ARM_V5TEJ) : @"armv5t",
                                        @(CPU_SUBTYPE_ARM_XSCALE) : @"xscale",
                                        @(CPU_SUBTYPE_ARM_V7) : @"armv7",
                                        @(CPU_SUBTYPE_ARM_V7F) : @"armv7f",
                                        @(CPU_SUBTYPE_ARM_V7S) : @"armv7s",
                                        @(CPU_SUBTYPE_ARM_V7K) : @"armv7k",
                                        @(CPU_SUBTYPE_ARM_V6M) : @"armv6m",
                                        @(CPU_SUBTYPE_ARM_V7M) : @"armv7m",
                                        @(CPU_SUBTYPE_ARM_V7EM) : @"armv7em",
//                                        @(CPU_SUBTYPE_ARM_V8) : @"armv8"
                                        },
                                @(CPU_TYPE_ARM64) : @{
                                        @(CPU_SUBTYPE_ARM64_ALL) : @"arm64",
//                                        @(CPU_SUBTYPE_ARM64_V8) : @"arm64v8",
//                                        @(CPU_SUBTYPE_ARM64E) : @"arm64e"
                                        }
                                };

    cpu_type_t cpuType = header->cputype;
    cpu_subtype_t cpuSubtype = header->cpusubtype;
    return archTable[@(cpuType)][@(cpuSubtype)];
}

- (NSDictionary *)createTable:(NSDictionary *)task forArch:(NSString *)arch {
    NSString *tmp = NSTemporaryDirectory();
    NSArray *allKeys = task.allKeys;
    NSInteger count = allKeys.count;
    const char *imageNames[count + 1];
    for (NSInteger i= 0; i < count; i++) {
        NSString *key = allKeys[i];
        imageNames[i] = key.UTF8String;
    }
    imageNames[count] = NULL;
    NSString *path = [NSString stringWithFormat:@"/System/Library/Caches/com.apple.dyld/dyld_shared_cache_%@", arch];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"PDLConstSymbols failed to get symbols: %@ does not exist.", path);
        return nil;
    }

    NSLog(@"PDLConstSymbols task created.");
    int ret = dyld_shared_cache_extract_dylibs(path.UTF8String, tmp.UTF8String, imageNames);
    if (ret != 0) {
        NSLog(@"PDLConstSymbols failed to get symbols: failed to extract, error is %d.", ret);
        return nil;
    }

    NSMutableDictionary *table = [NSMutableDictionary dictionary];
    for (NSString *imageName in task) {
        @autoreleasepool {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            NSString *path = [tmp stringByAppendingPathComponent:imageName];
            NSData *data = [NSData dataWithContentsOfFile:path];

            struct mach_header *live = pdl_mach_o_image(imageName.UTF8String);
            cpu_type_t my_cputype = live->cputype;
            cpu_subtype_t my_cpusubtype = live->cpusubtype;

            struct mach_header *header = NULL;
            pdl_fat_object object;
            pdl_fat_object *fat_object = &object;
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

            if (header == NULL) {
                NSLog(@"PDLConstSymbols failed to find header for %@.", imageName);
                continue;
            }

            NSArray *symbolNames = task[imageName];
            for (NSString *symbol in symbolNames) {
                pdl_mach_o_symbol *symbols = pdl_get_mach_o_symbol_list_contains_symbol_name(header, (char *)symbol.UTF8String);
                if (symbols == NULL) {
                    NSLog(@"PDLConstSymbols failed to find symbol for %@ in %@.", symbol, imageName);
                    continue;
                }

                NSMutableArray *array = [NSMutableArray array];
                pdl_mach_o_symbol *current = symbols;
                while (current) {
                    PDLConstSymbol *symbol = [[PDLConstSymbol alloc] init];
                    symbol.n_type = current->n_type;
                    symbol.n_sect = current->n_sect;
                    symbol.n_desc = current->n_desc;
                    symbol.n_value = current->n_value;
                    symbol.name = current->symbol_name ? @(current->symbol_name) : nil;
                    symbol.cputype = my_cputype;
                    symbol.cpusubtype = my_cpusubtype;
                    [array addObject:symbol];
                    current = current->next;
                }
                pdl_free_mach_o_symbol_list(symbols);
                dictionary[symbol] = [array copy];
            }

            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];

            table[imageName] = [dictionary copy];
        }
    }
    NSLog(@"PDLConstSymbols task finished.");
    return [table copy];
}

- (pdl_mach_o_symbol *)symbolsWithImageName:(NSString *)imageName symbolName:(NSString *)symbolName {
    NSArray *array = self.table[imageName][symbolName];
    pdl_mach_o_symbol *symbols = NULL;
    pdl_mach_o_symbol *current = symbols;
    struct mach_header *header = pdl_mach_o_image(imageName.UTF8String);
    intptr_t vmaddr_slide = pdl_mach_o_image_vmaddr_slide(header);
    for (PDLConstSymbol *symbol in array) {
        pdl_mach_o_symbol *node = (pdl_mach_o_symbol *)malloc(sizeof(pdl_mach_o_symbol));
        if (node == NULL) {
            pdl_free_mach_o_symbol_list(symbols);
            return NULL;
        }
        node->n_type = symbol.n_type;
        node->n_sect = symbol.n_sect;
        node->n_desc = symbol.n_desc;
        node->n_value = symbol.n_value;

        node->symbol = vmaddr_slide + (uintptr_t)symbol.n_value;
        node->symbol_name = symbol.name.UTF8String;
        node->symtab_index = UINT32_MAX;
        node->header = header;
        node->next = NULL;

        if (symbol.cputype == CPU_TYPE_ARM) {
            // processor assumes code address with low bit set is thumb
            if (node->n_desc & N_ARM_THUMB_DEF) {
                node->symbol |= 1;
            }
        }

        if (current) {
            current->next = node;
            current = node;
        } else {
            current = node;
            symbols = current;
        }
    }
    return symbols;
}

@end

#endif

pdl_mach_o_const_symbols_state pdl_const_symbols_current_state(void) {
#if TARGET_IPHONE_SIMULATOR
    return true;
#else
    return [PDLConstSymbols sharedInstance].currentState;
#endif
}

pdl_mach_o_symbol *pdl_const_symbols(const char *image_name, const char *symbol_name) {
#if TARGET_IPHONE_SIMULATOR
    return NULL;
#else
    pdl_mach_o_symbol *symbols = [[PDLConstSymbols sharedInstance] symbolsWithImageName:@(image_name) symbolName:@(symbol_name)];
    return symbols;
#endif
}
