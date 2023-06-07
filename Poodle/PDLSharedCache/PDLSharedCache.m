//
//  PDLSharedCache.m
//  Poodle
//
//  Created by Poodle on 2021/6/22.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLSharedCache.h"
#import <sys/stat.h>
#import <sys/mman.h>
#import "dsc_extractor.h"
#import "pdl_mach_object.h"
#import "pdl_mach_o_symbols.h"
#import "PDLDYLDSharedCache.h"

@implementation PDLSharedCacheSymbol

- (NSString *)description {
    NSString *description = [super description];
    return [description stringByAppendingFormat:@"name: %@, offset: %p, n_type: %@, n_sect: %@, n_desc: %@, n_value: %@", self.name, (void *)self.offset, @(self.n_type), @(self.n_sect), @(self.n_desc), @(self.n_value)];
}

@end

@interface PDLSharedCacheImage ()

@property (nonatomic, copy) NSArray <PDLSharedCacheSymbol *>*symbols;
@property (nonatomic, assign) uintptr_t endAddress;

@end

@implementation PDLSharedCacheImage

+ (PDLSharedCacheSymbol *)symbol:(NSArray <PDLSharedCacheSymbol *>*)symbols address:(uintptr_t)address {
    PDLSharedCacheSymbol *symbol = nil;
    if (symbols.count == 1) {
        symbol = symbols[0];
    } else if (symbols.count == 2) {
        PDLSharedCacheSymbol *first = symbols[0];
        PDLSharedCacheSymbol *last = symbols[1];
        if (address >= first.offset && address < last.offset) {
            symbol = first;
        } else {
            symbol = last;
        }
    } else {
        PDLSharedCacheSymbol *middle = symbols[symbols.count / 2];
        if (address < middle.offset) {
            symbol = [self symbol:[symbols subarrayWithRange:NSMakeRange(0, symbols.count / 2)] address:address];
        } else {
            symbol = [self symbol:[symbols subarrayWithRange:NSMakeRange(symbols.count / 2, symbols.count - symbols.count / 2)] address:address];
        }
    }
    return symbol;
}

- (PDLSharedCacheSymbol *)symbolOfAddress:(uintptr_t)address {
    if (address >= self.endAddress) {
        return nil;
    }

    return [self.class symbol:self.symbols address:address];
}

@end

@interface PDLSharedCache ()

@property (nonatomic, copy, readonly) NSString *systemCacheFile;
@property (nonatomic, copy, readonly) NSString *cachePath;
@property (nonatomic, copy, readonly) NSString *tmpPath;
@property (nonatomic, strong) NSMutableDictionary *images;

@end

@implementation PDLSharedCache

+ (NSString *)archWithHeader:(struct mach_header *)header {
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
                @(CPU_SUBTYPE_ARM_V8) : @"armv8",
        },
        @(CPU_TYPE_ARM64) : @{
                @(CPU_SUBTYPE_ARM64_ALL) : @"arm64",
                @(CPU_SUBTYPE_ARM64_V8) : @"arm64v8",
                @(CPU_SUBTYPE_ARM64E) : @"arm64e",
        },
    };

    cpu_type_t cpuType = header->cputype;
    cpu_subtype_t cpuSubtype = header->cpusubtype;
    return archTable[@(cpuType)][@(cpuSubtype)];
}

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if TARGET_OS_IPHONE && !TARGET_OS_SIMULATOR
        sharedInstance = [[self alloc] init];
#endif
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _images = [NSMutableDictionary dictionary];

        NSString *systemCachePath = @"/System/Library/Caches/com.apple.dyld";
        NSError *error = nil;
        NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:systemCachePath error:&error];
        NSMutableArray *cacheFiles = [NSMutableArray array];
        for (NSString *filename in filenames) {
            if (filename.pathExtension.length == 0) {
                [cacheFiles addObject:filename];
            }
        }

        NSString *path = nil;
        if (cacheFiles.count != 0) {
            if (cacheFiles.count == 1) {
                path = [systemCachePath stringByAppendingPathComponent:cacheFiles.firstObject];
            } else {
                struct mach_header *header = pdl_execute_header();
                NSString *arch = [self.class archWithHeader:header];
                NSString *file = [NSString stringWithFormat:@"dyld_shared_cache_%@", arch];
                if (arch && [cacheFiles containsObject:file]) {
                    path = [systemCachePath stringByAppendingPathComponent:file];
                }
            }
        }

        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            path = nil;
        }
        _systemCacheFile = path;

        NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryPath = libraryPaths.firstObject;
        NSString *cachePath = [libraryPath stringByAppendingPathComponent:@"PDLSharedCache"];
        BOOL isDir = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _cachePath = cachePath;
        NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"PDLSharedCache"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:tmpPath isDirectory:&isDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _tmpPath = tmpPath;
    }
    return self;
}

- (BOOL)extract:(NSString *)imageName {
    if (!imageName) {
        return NO;
    }

    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 15) {
        return NO;
    }

    BOOL ret = [self dyldExtract:@[imageName]];
    if (!ret) {
        ret = [self pdlExtract:@[imageName]];
    }

    return ret;
}

- (NSString *)sharedCachePathWithImageName:(NSString *)imageName {
    NSString *path = [self.cachePath stringByAppendingPathComponent:imageName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return path;
    }

    BOOL ret = [self extract:imageName];
    if (ret) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return path;
        }
    }
    return nil;
}

- (PDLSharedCacheImage *)sharedCacheImageWithImageName:(NSString *)imageName {
    if (imageName.length == 0) {
        return nil;
    }

    @synchronized (self.images) {
        PDLSharedCacheImage *image = self.images[imageName];
        if (image) {
            return image;
        }

        NSString *path = [self sharedCachePathWithImageName:imageName];
        if (!path) {
            return nil;
        }

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
            return nil;
        }

        pdl_mach_object mach_object;
        bool result = pdl_get_mach_object_with_header(header, -1, imageName.UTF8String, &mach_object);
        if (!result) {
            return nil;
        }

        image = [[PDLSharedCacheImage alloc] init];
        uintptr_t vmaddr = (uintptr_t)mach_object.vmaddr;
        uint32_t symtab_count = mach_object.symtab_count;
        const struct nlist *symtab_list = mach_object.symtab_list;
        const char *strtab = mach_object.strtab;
        NSMutableArray *symbols = [NSMutableArray array];
        for (uint32_t i = 0; i < symtab_count; i++) {
            uint32_t strx = 0;
            uint8_t type = 0;
            uint8_t sect = 0;
            int16_t desc = 0;
            u_long value = 0;
            if (mach_object.is64 == false) {
                const struct nlist *symtab = &symtab_list[i];
                strx = symtab->n_un.n_strx;
                type = symtab->n_type;
                sect = symtab->n_sect;
                desc = symtab->n_desc;
                value = symtab->n_value;
            } else {
                const struct nlist_64 *symtab = &((struct nlist_64 *)symtab_list)[i];
                strx = symtab->n_un.n_strx;
                type = symtab->n_type;
                sect = symtab->n_sect;
                desc = symtab->n_desc;
                value = (u_long)symtab->n_value;
            }

            const char *str = strtab + strx;
            uintptr_t offset = value - vmaddr;

            PDLSharedCacheSymbol *symbol = [[PDLSharedCacheSymbol alloc] init];
            symbol.n_type = type;
            symbol.n_desc = desc;
            symbol.n_sect = sect;
            symbol.n_value = value;
            symbol.offset = offset;
            symbol.name = @(str);
            [symbols addObject:symbol];
        }
        [symbols sortUsingComparator:^NSComparisonResult(PDLSharedCacheSymbol *obj1, PDLSharedCacheSymbol *obj2) {
            return [@(obj1.offset) compare:@(obj2.offset)];
        }];

        image.symbols = symbols;
        image.endAddress = vmaddr + (uintptr_t)mach_object.vmsize;
        self.images[imageName] = image;

        return image;
    }
}

- (BOOL)dyldExtract:(NSArray *)imageNames {
    NSString *cachePath = self.systemCacheFile;
    NSString *destinationPath = self.cachePath;
    NSString *tmpPath = self.tmpPath;
    const char *names[imageNames.count + 1];
    for (NSInteger i = 0; i < imageNames.count; i++) {
        NSString *imageName = imageNames[i];
        names[i] = imageName.UTF8String;
    }
    names[imageNames.count] = NULL;

    int result = dyld_shared_cache_extract_dylibs(cachePath.UTF8String, tmpPath.UTF8String, names);
    BOOL ret = result == 0;
    for (NSInteger i = 0; i < imageNames.count; i++) {
        NSString *file = imageNames[i];
        NSString *destinationFile = [destinationPath stringByAppendingPathComponent:file];
        ret = ret && [[NSFileManager defaultManager] moveItemAtPath:[tmpPath stringByAppendingPathComponent:file] toPath:destinationFile error:nil];
    }
    return ret;
}

- (BOOL)pdlExtract:(NSArray *)imageNames {
    NSString *cachePath = self.systemCacheFile;
    NSString *destinationPath = self.cachePath;
    NSString *tmpPath = self.tmpPath;
    PDLDYLDSharedCache *cache = [PDLDYLDSharedCache sharedCacheWithPath:cachePath];
    cache.tmpPath = tmpPath;
    cache.destinationPath = destinationPath;
    return [cache extract:imageNames];
}

- (BOOL)dump:(NSString *)path error:(NSError **)error {
    NSString *systemCachePath = @"/System/Library/Caches/com.apple.dyld";
    BOOL ret = [[NSFileManager defaultManager] copyItemAtPath:systemCachePath toPath:[path stringByAppendingPathComponent:systemCachePath.lastPathComponent] error:error];
    return ret;
}

@end
