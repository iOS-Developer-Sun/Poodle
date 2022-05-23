//
//  PDLFileSystem.m
//  Poodle
//
//  Created by Poodle on 2021/3/21.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLFileSystem.h"
#import <CommonCrypto/CommonCrypto.h>

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
            NSString *suiteName =  filename.stringByDeletingPathExtension;
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

    NSString *extendedAttributesKey = @"NSFileExtendedAttributes";
    NSString *attributesKey = @"PDLFileSystemMD5";
    NSDictionary *attr = fileAttr[extendedAttributesKey];
    NSData *md5 = attr[attributesKey];
    if (!md5) {
        @autoreleasepool {
            NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
            unsigned char result[CC_MD5_DIGEST_LENGTH];
            CC_MD5([data bytes], (CC_LONG)[data length], result);sleep(5);
            md5 = [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
            if (md5) {
                NSMutableDictionary *dictionary = [attr ?: @{} mutableCopy];
                dictionary[attributesKey] = md5;
                attr = [dictionary copy];
                [fm setAttributes:@{extendedAttributesKey : attr} ofItemAtPath:filePath error:NULL];
            }
        }
    }

    return md5;
}

+ (NSString *)md5String:(NSString *)filePath {
    NSString *string = nil;
    NSData *data = [self md5:filePath];
    if (data) {
        NSUInteger length = data.length;
        const unsigned char *bytes = (const unsigned char *)data.bytes;
        NSMutableString *hexString  = [NSMutableString string];
        for (NSUInteger i = 0; i < length; i++) {
            [hexString appendFormat:@"%02x", bytes[i]];
        }
        string = [hexString copy];
    }
    return string;
}


@end
