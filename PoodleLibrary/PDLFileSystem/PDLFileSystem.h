//
//  PDLFileSystem.h
//  Poodle
//
//  Created by Poodle on 2021/3/21.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLFileSystem : NSObject

+ (NSString *)sizeStringOfBytes:(uint64_t)bytes;

+ (uint64_t)fileSystemTotalSize;
+ (uint64_t)fileSystemFreeSize;
+ (uint64_t)fileSizeAtPath:(NSString *)filePath;

+ (void)removeFilePath:(NSString *)filePath;
+ (void)removeFilePath:(NSString *)filePath exclusions:(NSArray *_Nullable )exclusions;
+ (void)removeHomeDirectory;

+ (BOOL)setExcludedFromBackup:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
