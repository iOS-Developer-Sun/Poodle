//
//  PDLCrash.m
//  Poodle
//
//  Created by Poodle on 2021/2/5.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLCrash.h"
#import <mach-o/ldsyms.h>
#import <dlfcn.h>
#import "PDLSystemImage.h"

@interface PDLCrashBinaryImage : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *arch;
@property (nonatomic, assign) uintptr_t address;
@property (nonatomic, assign) uintptr_t endAddress;
@property (nonatomic, copy) NSString *path;

@end

@implementation PDLCrashBinaryImage

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        NSScanner *scanner = [NSScanner scannerWithString:string];
        if (![scanner scanHexLongLong:(unsigned long long *)&_address]) {
            return nil;
        }

        if (![scanner scanString:@"-" intoString:NULL]) {
            return nil;
        }

        if (![scanner scanHexLongLong:(unsigned long long *)&_endAddress]) {
            return nil;
        }

        NSString *name = nil;
        if (![scanner scanUpToString:@" " intoString:&name]) {
            return nil;
        }
        _name = name;

        NSString *arch = nil;
        if (![scanner scanUpToString:@" " intoString:&arch]) {
            return nil;
        }
        _arch = arch;

        NSString *uuid = nil;
        if (![scanner scanUpToString:@" " intoString:&uuid]) {
            return nil;
        }
        uuid = [uuid stringByReplacingOccurrencesOfString:@"<" withString:@""];
        uuid = [uuid stringByReplacingOccurrencesOfString:@">" withString:@""];
        _uuid = uuid;

        NSString *path = nil;
        if (![scanner scanUpToString:@" " intoString:&path]) {
            return nil;
        }
        _path = path;
    }
    return self;
}

@end

@interface PDLCrash ()

@property (copy) NSString *symbolicatedString;
@property (assign) NSInteger symbolicatedCount;

@end

@implementation PDLCrash

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        _string = [string copy];
    }
    return self;
}

- (NSString *)identifier:(NSString *)string {
    NSRange range = [string rangeOfString:@"(?<=\nIdentifier:          )[^ \f\n\r\t\v]*(?=\n)" options:NSRegularExpressionSearch];
    if (range.location == NSNotFound) {
        return nil;
    }

    NSString *identifier = [string substringWithRange:range];
    return identifier;
}

- (NSString *)process:(NSString *)string {
    NSRange range = [string rangeOfString:@"(?<=\nProcess:             )[^ \f\n\r\t\v]*(?= )" options:NSRegularExpressionSearch];
    if (range.location == NSNotFound) {
        return nil;
    }

    NSString *process = [string substringWithRange:range];
    return process;
}

- (NSArray *)binaryImages:(NSString *)string {
    NSRange range = [string rangeOfString:@"Binary Images:\n" options:0];
    if (range.location == NSNotFound) {
        return nil;
    }

    NSString *binaryImagesString = [string substringFromIndex:range.location + range.length];

    NSArray *binaryImageLines = [binaryImagesString componentsSeparatedByString:@"\n"];
    NSMutableArray *binaryImages = [NSMutableArray array];
    for (NSString *binaryImageLine in binaryImageLines) {
        PDLCrashBinaryImage *binaryImage = [[PDLCrashBinaryImage alloc] initWithString:binaryImageLine];
        if (binaryImage) {
            [binaryImages addObject:binaryImage];
        }
    }
    return [binaryImages copy];
}

- (BOOL)symbolicateLine:(NSString *)line symbolicatedLine:(NSString **)symbolicatedLine imagesMap:(NSDictionary *)imagesMap crashImagesMap:(NSDictionary *)crashImagesMap {
    NSScanner *scanner = [NSScanner scannerWithString:line];
    int frame = 0;
    if (![scanner scanInt:&frame]) {
        return NO;
    }

    NSString *name = nil;
    if (![scanner scanUpToString:@" " intoString:&name]) {
        return NO;
    }

    PDLSystemImage *systemImage = imagesMap[name];
    if (!systemImage) {
        return NO;
    }

    uintptr_t address = 0;
    if (![scanner scanHexLongLong:(unsigned long long *)&address]) {
        return NO;
    }

    NSInteger symbolBegin = scanner.scanLocation;
    NSString *symbol = [line substringFromIndex:symbolBegin];
    if (![symbol hasPrefix:@" 0x"]) {
        return NO;
    }

    uintptr_t baseAddress = 0;
    if (![scanner scanHexLongLong:(unsigned long long *)&baseAddress]) {
        return NO;
    }

    [scanner scanUpToString:@"+" intoString:NULL];
    [scanner scanString:@"+" intoString:NULL];

    uintptr_t offset = 0;
    if (![scanner scanUnsignedLongLong:(unsigned long long *)&offset]) {
        return NO;
    }

    if (address != baseAddress + offset) {
        return NO;
    }

    PDLCrashBinaryImage *binaryImage = crashImagesMap[name];
    if (binaryImage.address != baseAddress) {
        return NO;
    }

    uintptr_t current = systemImage.address + offset;
    Dl_info info = {0};
    int ret = dladdr((void *)current, &info);
    if (!ret) {
        return NO;
    }

    if (![@(info.dli_fname).lastPathComponent isEqualToString:name]) {
        return NO;
    }

    if ((uintptr_t)info.dli_fbase != systemImage.address) {
        return NO;
    }

    if (symbolicatedLine) {
        uintptr_t currentOffset = current - (uintptr_t)info.dli_saddr;
        NSString *symbolicatedSymbol = @(info.dli_sname);
        NSString *prefix = [line substringToIndex:symbolBegin];
        NSString *result = [NSString stringWithFormat:@"%@ %@ + %@", prefix, symbolicatedSymbol, @(currentOffset)];
        *symbolicatedLine = result;
    }

    return YES;
}

- (BOOL)symbolicate {
    NSString *identifier = [self identifier:_string];
    if (![identifier isEqualToString:[NSBundle mainBundle].bundleIdentifier]) {
        return NO;
    }

    NSString *process = [self process:_string];
    if (!process) {
        return NO;
    }

    NSArray *binaryImages = [self binaryImages:_string];
    PDLCrashBinaryImage *image = binaryImages.firstObject;
    if (!image) {
        return NO;
    }

    PDLSystemImage *systemImage = [PDLSystemImage systemImageWithHeader:(struct mach_header *)&_mh_execute_header];
    if (!self.allowsUUIDMisMatched && ![systemImage.uuidString isEqualToString:image.uuid]) {
        return NO;
    }

    NSMutableDictionary *imagesMap = [NSMutableDictionary dictionary];
    for (PDLSystemImage *systemImage in [PDLSystemImage systemImages]) {
        imagesMap[systemImage.name] = systemImage;
    }

    NSMutableDictionary *crashImagesMap = [NSMutableDictionary dictionary];
    for (PDLCrashBinaryImage *binaryImage in binaryImages) {
        crashImagesMap[binaryImage.name] = binaryImage;
    }

    NSArray *lines = [_string componentsSeparatedByString:@"\n"];
    NSMutableString *symbolicatedString = [NSMutableString string];
    NSInteger symbolicatedCount = 0;
    for (NSString *line in lines) {
        NSString *symbolicateLine = line;
        BOOL symbolicated = [self symbolicateLine:line symbolicatedLine:&symbolicateLine imagesMap:imagesMap crashImagesMap:crashImagesMap];
        [symbolicatedString appendFormat:@"%@\n", symbolicateLine];
        if (symbolicated) {
            symbolicatedCount++;
        }
    }

    BOOL symbolicated = symbolicatedCount > 0;
    if (symbolicated) {
        self.symbolicatedString = symbolicatedString;
        self.symbolicatedCount = symbolicatedCount;
    }

    return symbolicated;
}

@end
