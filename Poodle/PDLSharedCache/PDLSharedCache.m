//
//  PDLSharedCache.m
//  Poodle
//
//  Created by Poodle on 2021/6/22.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLSharedCache.h"
#import "dsc_extractor.h"
#import "pdl_mach_object.h"

@interface PDLSharedCache ()

@property (nonatomic, copy, readonly) NSString *systemCacheFile;
@property (nonatomic, copy, readonly) NSString *cachePath;

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
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *systemCachePath = @"/System/Library/Caches/com.apple.dyld";
        NSError *error = nil;
        NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:systemCachePath error:&error];
        NSString *path = nil;
        if (filenames.count != 0) {
            if (filenames.count == 1) {
                path = [systemCachePath stringByAppendingPathComponent:filenames.firstObject];
            } else {
                struct mach_header *header = pdl_execute_header();
                NSString *arch = [self.class archWithHeader:header];
                if (arch) {
                    NSString *file = [NSString stringWithFormat:@"/dyld_shared_cache_%@", arch];
                    path = [systemCachePath stringByAppendingPathComponent:file];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                        path = nil;
                    }
                }
            }
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
    }
    return self;
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

- (BOOL)extract:(NSString *)imageName {
    if (!imageName) {
        return NO;
    }

    const char *imageNames[2];
    imageNames[0] = imageName.UTF8String;
    imageNames[1] = NULL;
    int ret = dyld_shared_cache_extract_dylibs(self.systemCacheFile.UTF8String, self.cachePath.UTF8String, imageNames);
    return ret == 0;
}

@end
