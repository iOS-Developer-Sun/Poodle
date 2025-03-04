//
//  PDLFileSystem.m
//  Poodle
//
//  Created by Poodle on 2021/3/21.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLFileSystem.h"
#import "NSData+PDLExtension.h"

@implementation PDLFileSystem

+ (NSString *)sizeStringOfBytes:(uint64_t)bytes {
    double gigaBytes = bytes / 1024.0 / 1024.0 / 1024.0;
    if (gigaBytes >= 1) {
        return [NSString stringWithFormat:@"%.2fG", gigaBytes];
    }

    double megaBytes = bytes / 1024.0 / 1024.0;
    if (megaBytes >= 1) {
        return [NSString stringWithFormat:@"%.2fM", megaBytes];
    }

    double kiloBytes = bytes / 1024.0;
    if (kiloBytes >= 1) {
        return [NSString stringWithFormat:@"%.2fK", kiloBytes];
    }

    return [NSString stringWithFormat:@"%@B", @(bytes)];
}

+ (uint64_t)fileSystemTotalSize {
    uint64_t totalSize = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (!error && dictionary) {
        totalSize = [dictionary[NSFileSystemSize] unsignedLongLongValue];
    }
    return totalSize;
}

+ (uint64_t)fileSystemFreeSize {
    uint64_t freeSize = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (!error && dictionary) {
        freeSize = [dictionary[NSFileSystemFreeSize] unsignedLongLongValue];
    }
    return freeSize;
}

+ (uint64_t)fileSizeAtPath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    uint64_t totalFileSize = [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
    NSArray *subpaths = nil;
    @autoreleasepool {
        subpaths = [fileManager subpathsAtPath:filePath];
    }
    for (NSString *subpath in subpaths) {
        NSString *subFilePath = [filePath stringByAppendingPathComponent:subpath];
        uint64_t fileSize = [[fileManager attributesOfItemAtPath:subFilePath error:nil] fileSize];
        totalFileSize += fileSize;
    }

    return totalFileSize;
}

+ (void)removeFilePath:(NSString *)filePath {
    [self removeFilePath:filePath exclusions:nil];
}

+ (void)removeFilePath:(NSString *)filePath exclusions:(NSArray *)exclusions {
    NSError *error = nil;
    if ([exclusions containsObject:filePath]) {
        return;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isRemoved = [fileManager removeItemAtPath:filePath error:&error];
    if (isRemoved == NO) {
        NSLog(@"cannot remove:%@, error:%@", filePath, error);
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:filePath error:nil];
        for (NSString *content in contents) {
            NSString *contentPath = [filePath stringByAppendingPathComponent:content];
            [self removeFilePath:contentPath exclusions:exclusions];
        }
    }
}

+ (void)removeHomeDirectory {
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = libraryPaths.firstObject;
    NSString *preferences = [libraryPath stringByAppendingPathComponent:@"Preferences"];
    [self removeFilePath:NSHomeDirectory() exclusions:@[preferences]];

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    void(^clear)(NSUserDefaults *) = ^(NSUserDefaults *userDefaults) {
        NSDictionary *dictionaryRepresentation = [userDefaults dictionaryRepresentation];
        for (id key in dictionaryRepresentation) {
            [userDefaults removeObjectForKey:key];
        }
        [userDefaults synchronize];
    };

    NSError *error = nil;
    NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:preferences error:&error];
    NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
    for (NSString *filename in filenames) {
        if ([filename.pathExtension isEqualToString:@"plist"]) {
            NSString *suiteName = filename.stringByDeletingPathExtension;
            if (![suiteName isEqualToString:bundleIdentifier]) {
                NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suiteName];
                clear(userDefaults);
            }
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:[preferences stringByAppendingPathComponent:filename] error:NULL];
        }
    }
    clear(standardUserDefaults);
}

+ (BOOL)setExcludedFromBackup:(NSString *)filePath {
    NSURL *url = [NSURL fileURLWithPath:filePath];
    BOOL ret = [url setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:nil];
    return ret;
}

+ (NSData *)md5:(NSString *)filePath {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *fileAttr = [fm attributesOfItemAtPath:filePath error:&error];
    if (error) {
        return nil;
    }

    uint64_t systemDate = [fileAttr[NSFileModificationDate] timeIntervalSince1970] * 1000000;
    NSString *extendedAttributesKey = @"NSFileExtendedAttributes";
    NSString *attributesKey = @"PDLFileSystemMD5";
    NSString *attributesDateKey = @"PDLFileSystemMD5Date";
    NSDictionary *attr = fileAttr[extendedAttributesKey];

    NSData *md5 = attr[attributesKey];
    NSData *md5Date = attr[attributesDateKey];
    uint64_t date = -1;
    if (md5Date.length >= sizeof(date)) {
        date = *(uint64_t *)md5Date.bytes;
    }

    if (!md5 || (date != systemDate)) {
        @autoreleasepool {
            NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
            md5 = [data pdl_md5];
            if (md5) {
                NSMutableDictionary *dictionary = [attr ?: @{} mutableCopy];
                dictionary[attributesKey] = md5;
                dictionary[attributesDateKey] = [NSData dataWithBytes:&date length:sizeof(date)];
                [fm setAttributes:@{extendedAttributesKey : dictionary} ofItemAtPath:filePath error:NULL];
            }
        }
    }

    return md5;
}

+ (NSString *)md5String:(NSString *)filePath {
    NSData *data = [self md5:filePath];
    return [data pdl_hexString];
}


@end
