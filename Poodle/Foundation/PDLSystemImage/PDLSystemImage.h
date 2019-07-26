//
//  PDLSystemImage.h
//  Poodle
//
//  Created by Poodle on 22/09/2017.
//  
//

#import <Foundation/Foundation.h>
#include <mach-o/loader.h>
#include <mach/machine.h>
#include "pdl_mach_object.h"

@interface PDLSystemImage : NSObject

@property (readonly) struct pdl_mach_object *machObject;

@property (class, readonly) NSUInteger count;

@property (readonly) NSString *name;
@property (readonly) NSString *path;
@property (readonly) uint64_t vmsize;
@property (readonly) uintptr_t address;
@property (readonly) uintptr_t endAddress;
@property (readonly) uintptr_t vmAddress;
@property (readonly) cpu_type_t cpuType;
@property (readonly) cpu_subtype_t cpuSubtype;
@property (readonly) const uint8_t *uuid;
@property (readonly) uint64_t majorVersion;
@property (readonly) uint64_t minorVersion;
@property (readonly) uint64_t revisionVersion;

@property (readonly) NSString *uuidString;
@property (readonly) NSString *cpuTypeString;
@property (readonly) NSString *crashLogString;

+ (instancetype)systemImageAtIndex:(NSUInteger)index;
+ (instancetype)systemImageWithPath:(NSString *)path;
+ (instancetype)systemImageWithHeader:(struct mach_header *)header;
+ (NSArray *)systemImages;
+ (NSArray *)systemImagesSortedByAddress;

- (BOOL)dump:(NSString *)path;

@end
