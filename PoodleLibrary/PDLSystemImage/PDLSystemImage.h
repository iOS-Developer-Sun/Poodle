//
//  PDLSystemImage.h
//  Poodle
//
//  Created by Poodle on 22/09/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <mach-o/loader.h>
#include <mach/machine.h>

@interface PDLSystemImage : NSObject

@property (class, readonly) NSUInteger count;
@property (class, readonly) NSString *imagesDidAddNotificationName;
@property (class, readonly) NSString *imagesDidRemoveNotificationName;

@property (readonly) NSString *name;
@property (readonly) intptr_t slide;
@property (readonly) NSString *path;
@property (readonly) uint64_t vmsize;
@property (readonly) uintptr_t address;
@property (readonly) uintptr_t endAddress;
@property (readonly) uintptr_t vmAddress;
@property (readonly) cpu_type_t cpuType;
@property (readonly) cpu_subtype_t cpuSubtype;
@property (readonly) const uint8_t *uuid;
@property (readonly) uint64_t currentVersion;
@property (readonly) uint64_t majorVersion;
@property (readonly) uint64_t minorVersion;
@property (readonly) uint64_t revisionVersion;

@property (readonly) NSString *uuidString;
@property (readonly) NSString *cpuTypeString;
@property (readonly) NSString *crashLogString;

+ (void)enable;
+ (instancetype)systemImageWithHeader:(struct mach_header *)header;
+ (instancetype)systemImageWithPath:(NSString *)path;
+ (NSArray *)systemImages;

- (BOOL)dump:(NSString *)path;

@end
