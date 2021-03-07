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

typedef NS_ENUM(NSUInteger, PDLCrashType) {
    PDLCrashTypeCrash,
    PDLCrashTypeEvent,
};

@interface PDLCrashBinaryImage : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *arch;
@property (nonatomic, assign) uintptr_t address;
@property (nonatomic, assign) uintptr_t endAddress;
@property (nonatomic, copy) NSString *path;

@end

@implementation PDLCrashBinaryImage

+ (instancetype)crashBinaryImageWithString:(NSString *)string {
    uintptr_t address = 0;

    NSScanner *scanner = [NSScanner scannerWithString:string];
    if (![scanner scanHexLongLong:(unsigned long long *)&address]) {
        return nil;
    }

    if (![scanner scanString:@"-" intoString:NULL]) {
        return nil;
    }

    uintptr_t endAddress = 0;

    if (![scanner scanHexLongLong:(unsigned long long *)&endAddress]) {
        return nil;
    }

    NSString *name = nil;
    if (![scanner scanUpToString:@" " intoString:&name]) {
        return nil;
    }

    NSString *arch = nil;
    if (![scanner scanUpToString:@" " intoString:&arch]) {
        return nil;
    }

    if (![scanner scanUpToString:@"<" intoString:NULL] && ![scanner scanString:@"<" intoString:NULL]) {
        return nil;
    }

    NSString *uuid = nil;
    if (![scanner scanUpToString:@">" intoString:&uuid]) {
        return nil;
    }

    [scanner scanString:@">" intoString:NULL];

    NSString *path = nil;
    if (![scanner scanUpToString:@" " intoString:&path]) {
        return nil;
    }

    PDLCrashBinaryImage *ret = [[self alloc] init];
    ret.address = address;
    ret.endAddress = endAddress;
    ret.name = name;
    ret.arch = arch;
    ret.uuid = uuid;
    ret.path = path;
    return ret;
}

+ (instancetype)eventBinaryImageWithString:(NSString *)string {
    uintptr_t address = 0;

    NSScanner *scanner = [NSScanner scannerWithString:string];
    if (![scanner scanHexLongLong:(unsigned long long *)&address]) {
        return nil;
    }

    if (![scanner scanString:@"-" intoString:NULL]) {
        return nil;
    }

    uintptr_t endAddress = 0;

    if (![scanner scanHexLongLong:(unsigned long long *)&endAddress]) {
        if (![scanner scanString:@"???" intoString:NULL]) {
            return nil;
        }
    }

    NSString *name = nil;
    if (![scanner scanUpToString:@" " intoString:&name]) {
        return nil;
    }

    if (![scanner scanUpToString:@"<" intoString:NULL] && ![scanner scanString:@"<" intoString:NULL]) {
        return nil;
    }

    NSString *uuid = nil;
    if (![scanner scanUpToString:@">" intoString:&uuid]) {
        return nil;
    }

    [scanner scanString:@">" intoString:NULL];

    NSString *path = nil;
    [scanner scanUpToString:@" " intoString:&path];

    PDLCrashBinaryImage *ret = [[self alloc] init];
    ret.address = address;
    ret.endAddress = endAddress;
    ret.name = name;
    ret.uuid = uuid;
    ret.path = path;
    return ret;
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

+ (NSString *)string:(NSString *)string valueForKey:(NSString *)key {
    NSString *reg = [NSString stringWithFormat:@"(?<=(^|\n)%@:)[^\n]+(?=(\n|$))", key];
    NSRange range = [string rangeOfString:reg options:NSRegularExpressionSearch];
    if (range.location == NSNotFound) {
        return nil;
    }

    NSString *value = [[string substringWithRange:range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return value;
}

+ (NSString *)identifier:(NSString *)string {
    return [self string:string valueForKey:@"Identifier"];
}

+ (NSString *)process:(NSString *)string {
    NSString *value = [self string:string valueForKey:@"Process"];
    NSRange range = [value rangeOfString:@"["];
    if (range.location == NSNotFound) {
        return nil;
    }

    NSString *process = [[value substringToIndex:range.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return process;
}

+ (NSString *)command:(NSString *)string {
    return [self string:string valueForKey:@"Command"];
}

- (NSArray *)binaryImages:(NSString *)string type:(PDLCrashType)type {
    NSRange range = [string rangeOfString:@"Binary Images:\n" options:0];
    if (range.location == NSNotFound) {
        return nil;
    }

    NSString *binaryImagesString = [string substringFromIndex:range.location + range.length];

    NSArray *binaryImageLines = [binaryImagesString componentsSeparatedByString:@"\n"];
    NSMutableArray *binaryImages = [NSMutableArray array];
    for (NSString *binaryImageLine in binaryImageLines) {
        PDLCrashBinaryImage *binaryImage = nil;
        if (type == PDLCrashTypeCrash) {
            binaryImage = [PDLCrashBinaryImage crashBinaryImageWithString:binaryImageLine];
        } else if (type == PDLCrashTypeEvent) {
            binaryImage = [PDLCrashBinaryImage eventBinaryImageWithString:binaryImageLine];
        }
        if (binaryImage) {
            [binaryImages addObject:binaryImage];
        }
    }
    return [binaryImages copy];
}

- (BOOL)symbolicateCrashLine:(NSString *)line symbolicatedLine:(NSString **)symbolicatedLine imagesMap:(NSDictionary *)imagesMap crashImagesMap:(NSDictionary *)crashImagesMap {
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

    if (!info.dli_fname) {
        return NO;
    }

    if (![@(info.dli_fname).lastPathComponent isEqualToString:name]) {
        return NO;
    }

    if ((uintptr_t)info.dli_fbase != systemImage.address) {
        return NO;
    }

    if (!info.dli_sname) {
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

- (BOOL)symbolicateEventLine:(NSString *)line symbolicatedLine:(NSString **)symbolicatedLine imagesMap:(NSDictionary *)imagesMap crashImagesMap:(NSDictionary *)crashImagesMap {
    NSScanner *scanner = [NSScanner scannerWithString:line];
    int frame = 0;
    if (![scanner scanInt:&frame]) {
        return NO;
    }

    NSString *unknown = @"???";
    NSString *symbol = nil;
    if (![scanner scanUpToString:@" " intoString:&symbol]) {
        return NO;
    }

    if (![symbol isEqualToString:unknown]) {
        return NO;
    }

    NSInteger symbolBegin = [line rangeOfString:unknown].location;

    [scanner scanUpToString:@"(" intoString:NULL];
    [scanner scanString:@"(" intoString:NULL];

    NSString *name = nil;
    if (![scanner scanUpToString:@" " intoString:&name]) {
        return NO;
    }

    [scanner scanUpToString:@"+" intoString:NULL];
    [scanner scanString:@"+" intoString:NULL];

    PDLSystemImage *systemImage = imagesMap[name];
    if (!systemImage) {
        return NO;
    }

    uintptr_t offset = 0;
    if (![scanner scanUnsignedLongLong:(unsigned long long *)&offset]) {
        return NO;
    }

    [scanner scanUpToString:@"[" intoString:NULL];
    [scanner scanString:@"[" intoString:NULL];

    uintptr_t address = 0;
    if (![scanner scanHexLongLong:(unsigned long long *)&address]) {
        return NO;
    }

    PDLCrashBinaryImage *binaryImage = crashImagesMap[name];
    if (address != binaryImage.address + offset) {
        return NO;
    }

    uintptr_t current = systemImage.address + offset;
    Dl_info info = {0};
    int ret = dladdr((void *)current, &info);
    if (!ret) {
        return NO;
    }

    if (!info.dli_fname) {
        return NO;
    }

    if (![@(info.dli_fname).lastPathComponent isEqualToString:name]) {
        return NO;
    }

    if ((uintptr_t)info.dli_fbase != systemImage.address) {
        return NO;
    }

    if (!info.dli_sname) {
        return NO;
    }

    if (symbolicatedLine) {
        uintptr_t currentOffset = current - (uintptr_t)info.dli_saddr;
        NSString *symbolicatedSymbol = @(info.dli_sname);
        NSString *symbolicatedSymbolString = [NSString stringWithFormat:@"%@ + %@", symbolicatedSymbol, @(currentOffset)];
        NSString *result = [line stringByReplacingCharactersInRange:NSMakeRange(symbolBegin, unknown.length) withString:symbolicatedSymbolString];
        *symbolicatedLine = result;
    }

    return YES;
}

- (BOOL)symbolicate {
    NSString *string = self.string;
    NSString *identifier = [self.class identifier:string];
    if (![identifier isEqualToString:[NSBundle mainBundle].bundleIdentifier]) {
        return NO;
    }

    PDLCrashType crashType = PDLCrashTypeCrash;
    NSString *process = [self.class process:string];
    NSString *command = [self.class command:string];
    if (!process && !command) {
        return NO;
    }

    if (command) {
        crashType = PDLCrashTypeEvent;
    }

    NSArray *binaryImages = [self binaryImages:string type:crashType];
    PDLCrashBinaryImage *image = binaryImages.firstObject;
    if (!image) {
        return NO;
    }

    PDLSystemImage *systemImage = [PDLSystemImage systemImageWithHeader:(struct mach_header *)&_mh_execute_header];
    BOOL UUIDMismatched = ![systemImage.uuidString isEqualToString:image.uuid];
    self.UUIDMismatched = UUIDMismatched;
    if (!self.allowsUUIDMismatched && UUIDMismatched) {
        return NO;
    }

    if (crashType == PDLCrashTypeEvent) {
        image.name = command;
    }

    NSMutableDictionary *imagesMap = [NSMutableDictionary dictionary];
    for (PDLSystemImage *systemImage in [PDLSystemImage systemImages]) {
        imagesMap[systemImage.name] = systemImage;
    }

    NSMutableDictionary *crashImagesMap = [NSMutableDictionary dictionary];
    for (PDLCrashBinaryImage *binaryImage in binaryImages) {
        crashImagesMap[binaryImage.name] = binaryImage;
    }

    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    NSMutableString *symbolicatedString = [NSMutableString string];
    NSInteger symbolicatedCount = 0;
    for (NSString *line in lines) {
        NSString *symbolicateLine = line;
        BOOL symbolicated = NO;
        if (crashType == PDLCrashTypeCrash) {
            symbolicated = [self symbolicateCrashLine:line symbolicatedLine:&symbolicateLine imagesMap:imagesMap crashImagesMap:crashImagesMap];
        } else if (crashType == PDLCrashTypeEvent) {
            symbolicated = [self symbolicateEventLine:line symbolicatedLine:&symbolicateLine imagesMap:imagesMap crashImagesMap:crashImagesMap];
        }
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
