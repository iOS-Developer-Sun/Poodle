//
//  PDLSystemImage.m
//  Poodle
//
//  Created by Poodle on 22/09/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLSystemImage.h"
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import "pdl_mach_object.h"

@interface PDLSystemImage () {
    pdl_mach_object _mach_object;
}

@property (nonatomic, assign) pdl_mach_object *machObject;

@end

@implementation PDLSystemImage

static NSMutableDictionary *_systemImages = nil;
static BOOL _loaded = NO;

static void pdl_systemImageAdded(const struct mach_header *header, intptr_t vmaddr_slide) {
    Dl_info info;
    BOOL ret = dladdr(header, &info);
    if (!ret) {
        return;
    }

    const char *name = info.dli_fname;
    pdl_mach_object mach_object = {0};
    ret = pdl_get_mach_object_with_header(header, vmaddr_slide, name, &mach_object);
    if (!ret) {
        return;
    }

    PDLSystemImage *systemImage = [[PDLSystemImage alloc] initWithMachObject:&mach_object];
    @synchronized (_systemImages) {
        _systemImages[@((unsigned long)header)] = systemImage;
    }
    if (_loaded) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PDLSystemImage.imagesDidAddNotificationName object:systemImage];
    }
}

static void pdl_systemImageRemoved(const struct mach_header *header, intptr_t vmaddr_slide) {
    PDLSystemImage *systemImage = nil;
    @synchronized (_systemImages) {
        id key = @((unsigned long)header);
        systemImage = _systemImages[key];
        _systemImages[key] = nil;
    }
    if (_loaded) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PDLSystemImage.imagesDidRemoveNotificationName object:systemImage];
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _systemImages = [NSMutableDictionary dictionary];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            _dyld_register_func_for_add_image(&pdl_systemImageAdded);
            _dyld_register_func_for_remove_image(&pdl_systemImageRemoved);
            _loaded = YES;
        });
    });
}

- (instancetype)initWithMachObject:(pdl_mach_object *)machObject {
    self = [super init];
    if (self) {
        _machObject = &_mach_object;
        memcpy(_machObject, machObject, sizeof(*_machObject));

        _path = @(machObject->name);
        _slide = machObject->vmaddr_slide;
        _address = (uintptr_t)machObject->header;

        _cpuType = machObject->header->cputype;
        _cpuSubtype = machObject->header->cpusubtype;

        _vmsize = machObject->vmsize;
        _vmAddress = (uintptr_t)machObject->vmaddr;


        if (machObject->uuid_command) {
            _uuid = machObject->uuid_command->uuid;
        }
        if (machObject->id_dylib_dylib_command) {
            _currentVersion = machObject->id_dylib_dylib_command->dylib.current_version;
        }

    }
    return self;
}

+ (NSUInteger)count {
    @synchronized (_systemImages) {
        NSUInteger count = _systemImages.count;
        return count;
    }
}

+ (NSString *)imagesDidAddNotificationName {
    return @"PDLSystemImageImagesDidAddNotification";
}

+ (NSString *)imagesDidRemoveNotificationName {
    return @"PDLSystemImageImagesDidRemoveNotification";
}

+ (instancetype)systemImageWithHeader:(struct mach_header *)header {
    @synchronized (_systemImages) {
        PDLSystemImage *systemImage = _systemImages[@((unsigned long)header)];
        return systemImage;
    }
}

+ (instancetype)systemImageWithPath:(NSString *)path {
    if (path.length == 0) {
        return nil;
    }

    PDLSystemImage *ret = nil;
    NSArray *systemImages = nil;
    @synchronized (_systemImages) {
        systemImages = _systemImages.allValues;
    }
    for (PDLSystemImage *systemImage in systemImages) {
        if ([systemImage.path isEqualToString:path]) {
            ret = systemImage;
            break;
        }
    }

    return ret;
}

+ (NSArray *)systemImages {
    NSArray *systemImages = nil;
    @synchronized (_systemImages) {
        systemImages = _systemImages.allValues;
    }
    NSArray *systemImagesSortedByAddress = [systemImages sortedArrayUsingComparator:^NSComparisonResult(PDLSystemImage *systemImage1, PDLSystemImage *systemImage2) {
        return [@(systemImage1.address) compare:@(systemImage2.address)];
    }];
    return systemImagesSortedByAddress;
}

- (NSString *)name {
    NSString *name = self.path.lastPathComponent;
    return name;
}

- (uintptr_t)endAddress {
    uintptr_t endAddress = self.address + (uintptr_t)self.vmsize - 1;
    return endAddress;
}

- (uint64_t)majorVersion {
    return self.currentVersion >> 16;
}

- (uint64_t)minorVersion {
    return (self.currentVersion >> 8) & 0xff;
}

- (uint64_t)revisionVersion {
    return self.currentVersion & 0xff;
}

+ (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"%@ image count: %@", NSStringFromClass(self.class), @(self.count)];
    return description;
}

- (NSString *)uuidString {
    NSString *uuidString = nil;
    if (!uuid_is_null(self.uuid)) {
        uuid_string_t uuid_string;
        uuid_unparse_lower(self.uuid, uuid_string);
        uuidString = [@(uuid_string) stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    return uuidString;
}

- (NSString *)cpuTypeString {
    NSDictionary *cpuTypeStringDictionary = @{
                                              @(CPU_TYPE_ANY) : @"any",
                                              @(CPU_TYPE_VAX) : @"vax",
                                              @(CPU_TYPE_MC680x0) : @"mc680x0",
                                              @(CPU_TYPE_I386) : @"i386",
                                              @(CPU_TYPE_X86_64) : @"x86_64",
                                              @(CPU_TYPE_MC98000) : @"mc98000",
                                              @(CPU_TYPE_HPPA) : @"hppa",
                                              @(CPU_TYPE_ARM) : @"arm",
                                              @(CPU_TYPE_ARM64) : @"arm64",
                                              @(CPU_TYPE_MC88000) : @"mc88000",
                                              @(CPU_TYPE_SPARC) : @"sparc",
                                              @(CPU_TYPE_I860) : @"i860",
                                              @(CPU_TYPE_POWERPC) : @"powerpc",
                                              @(CPU_TYPE_POWERPC64) : @"powerpc64"
                                              };
    NSString *string = cpuTypeStringDictionary[@(self.cpuType)];
    NSString *cpuTypeString = string ?: @(self.cpuType).stringValue;
    return cpuTypeString;
}

- (NSString *)cpuSubtypeString {
    NSDictionary *cpuSubtypeStringDictionaryDictionary = @{
                                                           @(CPU_TYPE_ANY) : @{},
                                                           @(CPU_TYPE_VAX) : @{
                                                                   @(CPU_SUBTYPE_VAX_ALL) : @"vax",
                                                                   @(CPU_SUBTYPE_VAX780) : @"vax780",
                                                                   @(CPU_SUBTYPE_VAX785) : @"vax785",
                                                                   @(CPU_SUBTYPE_VAX750) : @"vax750",
                                                                   @(CPU_SUBTYPE_VAX730) : @"vax730",
                                                                   @(CPU_SUBTYPE_UVAXI) : @"uvaxi",
                                                                   @(CPU_SUBTYPE_UVAXII) : @"uvaxii",
                                                                   @(CPU_SUBTYPE_VAX8200) : @"vax8200",
                                                                   @(CPU_SUBTYPE_VAX8500) : @"vax8500",
                                                                   @(CPU_SUBTYPE_VAX8600) : @"vax8600",
                                                                   @(CPU_SUBTYPE_VAX8650) : @"vax8650",
                                                                   @(CPU_SUBTYPE_VAX8800) : @"vax8800",
                                                                   @(CPU_SUBTYPE_UVAXIII) : @"uvaxiii"
                                                                   },
                                                           @(CPU_TYPE_MC680x0) : @{
                                                                   @(CPU_SUBTYPE_MC68030) : @"mc68030",
                                                                   @(CPU_SUBTYPE_MC68040) : @"mc68040",
                                                                   @(CPU_SUBTYPE_MC68030_ONLY) : @"mc68030only"
                                                                   },
                                                           @(CPU_TYPE_I386) : @{
                                                                   @(CPU_SUBTYPE_I386_ALL) : @"i386",
                                                                   @(CPU_SUBTYPE_486) : @"486",
                                                                   @(CPU_SUBTYPE_486SX) : @"486sx",
                                                                   @(CPU_SUBTYPE_586) : @"586",
                                                                   @(CPU_SUBTYPE_PENT) : @"pent",
                                                                   @(CPU_SUBTYPE_PENTPRO) : @"pentpro",
                                                                   @(CPU_SUBTYPE_PENTII_M3) : @"pentii_m3",
                                                                   @(CPU_SUBTYPE_PENTII_M5) : @"pentii_m5",
                                                                   @(CPU_SUBTYPE_CELERON) : @"celeron",
                                                                   @(CPU_SUBTYPE_CELERON_MOBILE) : @"celeron_mobile",
                                                                   @(CPU_SUBTYPE_PENTIUM_3) : @"pentium_3",
                                                                   @(CPU_SUBTYPE_PENTIUM_3_M) : @"pentium_3",
                                                                   @(CPU_SUBTYPE_PENTIUM_3_XEON) : @"pentium_3_xeon",
                                                                   @(CPU_SUBTYPE_PENTIUM_M) : @"pentium_m",
                                                                   @(CPU_SUBTYPE_PENTIUM_4) : @"pentium_4",
                                                                   @(CPU_SUBTYPE_PENTIUM_4_M) : @"pentium_4_m",
                                                                   @(CPU_SUBTYPE_ITANIUM) : @"itanium",
                                                                   @(CPU_SUBTYPE_ITANIUM_2) : @"itanium_2",
                                                                   @(CPU_SUBTYPE_XEON) : @"xeon",
                                                                   @(CPU_SUBTYPE_XEON_MP) : @"xeon_mp"
                                                                   },
                                                           @(CPU_TYPE_X86_64) : @{
                                                                   @(CPU_SUBTYPE_X86_64_ALL) : @"x86_64",
                                                                   @(CPU_SUBTYPE_X86_ARCH1) : @"x86_arch1",
                                                                   @(CPU_SUBTYPE_X86_64_H) : @"x86_64_h"
                                                                   },
                                                           @(CPU_TYPE_MC98000) : @{
                                                                   @(CPU_SUBTYPE_MC98000_ALL) : @"mc98000",
                                                                   @(CPU_SUBTYPE_MC98601) : @"mc98601"
                                                                   },
                                                           @(CPU_TYPE_HPPA) : @{
                                                                   @(CPU_SUBTYPE_HPPA_7100) : @"hppa_7100",
                                                                   @(CPU_SUBTYPE_HPPA_7100LC) : @"hppa_7100lc"
                                                                   },
                                                           @(CPU_TYPE_ARM) : @{
                                                                   @(CPU_SUBTYPE_ARM_ALL) : @"arm",
                                                                   @(CPU_SUBTYPE_ARM_V4T) : @"arm_v4t",
                                                                   @(CPU_SUBTYPE_ARM_V6) : @"arm_v6",
                                                                   @(CPU_SUBTYPE_ARM_V5TEJ) : @"arm_v5tej",
                                                                   @(CPU_SUBTYPE_ARM_XSCALE) : @"arm_xscale",
                                                                   @(CPU_SUBTYPE_ARM_V7) : @"arm_v7",
                                                                   @(CPU_SUBTYPE_ARM_V7F) : @"arm_v7f",
                                                                   @(CPU_SUBTYPE_ARM_V7S) : @"arm_v7s",
                                                                   @(CPU_SUBTYPE_ARM_V7K) : @"arm_v7k",
                                                                   @(CPU_SUBTYPE_ARM_V6M) : @"arm_v6m",
                                                                   @(CPU_SUBTYPE_ARM_V7M) : @"arm_v7m",
                                                                   @(CPU_SUBTYPE_ARM_V7EM) : @"arm_v7em",
                                                                   @(CPU_SUBTYPE_ARM_V8) : @"arm_v8"
                                                                   },
                                                           @(CPU_TYPE_ARM64) : @{
                                                                   @(CPU_SUBTYPE_ARM64_ALL) : @"arm64",
                                                                   @(CPU_SUBTYPE_ARM64_V8) : @"arm64_v8"
                                                                   },
                                                           @(CPU_TYPE_MC88000) : @{
                                                                   @(CPU_SUBTYPE_MC88000_ALL) : @"mc88000",
                                                                   @(CPU_SUBTYPE_MC88100) : @"mc88100",
                                                                   @(CPU_SUBTYPE_MC88110) : @"mc88110"
                                                                   },
                                                           @(CPU_TYPE_SPARC) : @{
                                                                   @(CPU_SUBTYPE_SPARC_ALL) : @"sparc"
                                                                   },
                                                           @(CPU_TYPE_I860) : @{
                                                                   @(CPU_SUBTYPE_I860_ALL) : @"i860",
                                                                   @(CPU_SUBTYPE_I860_860) : @"i860_860"
                                                                   },
                                                           @(CPU_TYPE_POWERPC) : @{
                                                                   @(CPU_SUBTYPE_POWERPC_ALL) : @"powerpc",
                                                                   @(CPU_SUBTYPE_POWERPC_601) : @"powerpc_601",
                                                                   @(CPU_SUBTYPE_POWERPC_602) : @"powerpc_602",
                                                                   @(CPU_SUBTYPE_POWERPC_603) : @"powerpc_603",
                                                                   @(CPU_SUBTYPE_POWERPC_603e) : @"powerpc_603e",
                                                                   @(CPU_SUBTYPE_POWERPC_603ev) : @"powerpc_603ev",
                                                                   @(CPU_SUBTYPE_POWERPC_604) : @"powerpc_604",
                                                                   @(CPU_SUBTYPE_POWERPC_604e) : @"powerpc_604e",
                                                                   @(CPU_SUBTYPE_POWERPC_620) : @"powerpc_620",
                                                                   @(CPU_SUBTYPE_POWERPC_750) : @"powerpc_750",
                                                                   @(CPU_SUBTYPE_POWERPC_7400) : @"powerpc_7400",
                                                                   @(CPU_SUBTYPE_POWERPC_7450) : @"powerpc_7450",
                                                                   @(CPU_SUBTYPE_POWERPC_970) : @"powerpc_970"
                                                                   },
                                                           @(CPU_TYPE_POWERPC64) : @{}
                                              };
    NSDictionary *cpuSubtypeStringDictionary = cpuSubtypeStringDictionaryDictionary[@(self.cpuType)];
    NSString *string = cpuSubtypeStringDictionary[@(self.cpuSubtype)];
    NSString *cpuSubtypeString = string ?: @(self.cpuSubtype).stringValue;
    return cpuSubtypeString;
}

- (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"<%@: %p, %@(%@), version %@.%@.%@, uuid %@, cpu %@-%@, address %p-%p, vmsize %@, vmAddressSlide %p>", NSStringFromClass(self.class), self, self.name, self.path, @(self.majorVersion), @(self.minorVersion), @(self.revisionVersion), self.uuidString, self.cpuTypeString, self.cpuSubtypeString, (void *)self.address, (void *)self.endAddress, @(self.vmsize), (void *)self.slide];
    return description;
}

- (NSString *)crashLogString {
    NSString *crashLogString = [NSString stringWithFormat:@"%p - %p %@ %@ <%@> %@", (void *)self.address, (void *)self.endAddress, self.name, self.cpuTypeString, self.uuidString, self.path];
    return crashLogString;
}

- (BOOL)dump:(NSString *)path {
    NSMutableData *data = [[NSMutableData alloc] init];
    pdl_mach_object *machObject = self.machObject;

    BOOL is64 = machObject->is64;
    uint64_t slide = self.slide;
    uint32_t segmentCount = machObject->segments_count;
    for (uint32_t i = 0; i < segmentCount; i++) {
        BOOL isLastOne = i == segmentCount - 1;
        if (!is64) {
            const struct segment_command *segment = machObject->segments[i];
            [data appendBytes:(void *)(slide + segment->vmaddr) length:isLastOne ? segment->filesize : segment->vmsize];
        } else {
            const struct segment_command_64 *segment = ((pdl_mach_object_64 *)machObject)->segments[i];
            [data appendBytes:(void *)(slide + segment->vmaddr) length:(NSUInteger)(isLastOne ? segment->filesize : segment->vmsize)];
        }
    }

    BOOL ret = [data writeToFile:path atomically:YES];
    return ret;
}

@end
