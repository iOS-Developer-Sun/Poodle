//
//  PDLCrash.mm
//  Poodle
//
//  Created by Poodle on 2021/2/5.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLCrash.h"
#import <mach-o/ldsyms.h>
#import <dlfcn.h>
#import <cxxabi.h>
#import "PDLSystemImage.h"
#import "PDLSharedCache.h"

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

@property (nonatomic, copy, readonly) NSString *uuidString;

@end

@implementation PDLCrashBinaryImage

- (NSString *)uuidString {
    NSString *uuidString = [self.uuid.lowercaseString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return uuidString;
}

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

    if ([name isEqualToString:@"???"]) {
        name = [NSString stringWithFormat:@"<%@>", uuid];
    }

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

@property (copy) NSArray *binaryImages;
@property (copy) NSDictionary *imagesMap;
@property (copy) NSDictionary *crashImagesMap;

@property (copy) NSString *symbolicatedString;
@property (copy) NSArray *symbolicatedLocations;
@property (assign) NSInteger symbolicatedCount;
@property (assign) BOOL UUIDMismatched;
@property (assign) BOOL appMismatched;

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

- (BOOL)symbolicateCrashLine:(NSString *)line symbolicatedLine:(NSString **)symbolicatedLine symbolicatedLocations:(NSArray **)symbolicatedLocations {
    NSDictionary *imagesMap = self.imagesMap;
    NSDictionary *crashImagesMap = self.crashImagesMap;
    NSArray *binaryImages = self.binaryImages;
    NSScanner *scanner = [NSScanner scannerWithString:line];
    if ([line hasPrefix:@"("] && [line hasSuffix:@")"]) {
        // Last Exception Backtrace
        NSMutableArray *locations = [NSMutableArray array];
        NSMutableString *result = [NSMutableString string];
        NSInteger lineNumber = 0;

        [scanner scanString:@"(" intoString:NULL];
        NSInteger symbolBegin = scanner.scanLocation;
        NSInteger length = 0;
        uintptr_t address = 0;
        while ([scanner scanHexLongLong:(unsigned long long *)&address]) {
            length = scanner.scanLocation - symbolBegin;
            symbolBegin = scanner.scanLocation;
            NSMutableString *lineNumberString = [@(lineNumber).stringValue mutableCopy];
            if (lineNumberString.length < 4) {
                while (lineNumberString.length < 4) {
                    [lineNumberString appendString:@" "];
                }
            } else {
                [lineNumberString appendString:@"\t"];
            }
            lineNumber++;

            PDLCrashBinaryImage *image = nil;
            NSInteger left = 0;
            NSInteger right = binaryImages.count - 1;
            while (right - left > 1) {
                NSInteger middle = (left + right) / 2;
                PDLCrashBinaryImage *middleImage = binaryImages[middle];
                if (address < middleImage.address) {
                    right = middle - 1;
                } else {
                    left = middle;
                }
            }

            PDLCrashBinaryImage *leftImage = binaryImages[left];
            if (address >= leftImage.address && address < leftImage.endAddress) {
                image = leftImage;
            } else if (left != right) {
                PDLCrashBinaryImage *rightImage = binaryImages[right];
                if (address >= rightImage.address && address < rightImage.endAddress) {
                    image = rightImage;
                }
            }

            NSString *resultLine = nil;
            do {
                if (!image) {
                    break;
                }

                NSString *name = image.name;
                PDLSystemImage *systemImage = self.imagesMap[name];
                if (!systemImage) {
                    break;
                }

                uintptr_t offset = address - image.address;
                uintptr_t current = systemImage.address + offset;
                Dl_info info = {0};
                int ret = dladdr((void *)current, &info);
                if (!ret) {
                    break;
                }

                if (!info.dli_fname) {
                    break;
                }

                if (![@(info.dli_fname).lastPathComponent isEqualToString:name]) {
                    break;
                }

                if ((uintptr_t)info.dli_fbase != systemImage.address) {
                    break;
                }

                const char *sname = info.dli_sname;
                if (!sname) {
                    break;
                }

                NSString *snameString = @(sname);
                if ([snameString isEqualToString:@"<redacted>"]) {
                    PDLSharedCacheImage *sharedCacheImage = [[PDLSharedCache sharedInstance] sharedCacheImageWithImageName:name];
                    PDLSharedCacheSymbol *sharedCacheSymbol = [sharedCacheImage symbolOfAddress:offset];
                    snameString = sharedCacheSymbol.name;
                    if (snameString.length > 1 && [snameString hasPrefix:@"_"]) {
                        snameString = [snameString substringFromIndex:1];
                    }
                }

                NSString *symbolicatedSymbol = [self.class demangle:snameString] ?: snameString;
                uintptr_t currentOffset = current - (uintptr_t)info.dli_saddr;
                NSString *resultPart1 = [NSString stringWithFormat:@"%@%@                \t%p ", lineNumberString, name, (void *)address];
                NSString *resultPart2 = [NSString stringWithFormat:@"%@ + %@\n", symbolicatedSymbol, @(currentOffset)];
                [locations addObject:[NSValue valueWithRange:NSMakeRange(result.length + resultPart1.length, resultPart2.length)]];
                resultLine = [NSString stringWithFormat:@"%@%@", resultPart1, resultPart2];
            } while (NO);

            if (!resultLine) {
                resultLine = [NSString stringWithFormat:@"%@%p\n", lineNumberString, (void *)address];
            }

            [result appendString:resultLine];
        }
        if (symbolicatedLocations) {
            *symbolicatedLocations = locations;
        }
        if (symbolicatedLine) {
            *symbolicatedLine = result;
        }
    }

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

    const char *sname = info.dli_sname;
    if (!sname) {
        return NO;
    }

    NSString *snameString = @(sname);
    if ([snameString isEqualToString:@"<redacted>"]) {
        PDLSharedCacheImage *sharedCacheImage = [[PDLSharedCache sharedInstance] sharedCacheImageWithImageName:name];
        PDLSharedCacheSymbol *sharedCacheSymbol = [sharedCacheImage symbolOfAddress:offset];
        snameString = sharedCacheSymbol.name;
        if (!snameString) {
            return NO;
        }

        if (snameString.length > 1 && [snameString hasPrefix:@"_"]) {
            snameString = [snameString substringFromIndex:1];
        }
    }

    if (symbolicatedLine) {
        NSString *symbolicatedSymbol = [self.class demangle:snameString] ?: snameString;
        uintptr_t currentOffset = current - (uintptr_t)info.dli_saddr;
        NSString *prefix = [line substringToIndex:symbolBegin];
        NSString *result = [NSString stringWithFormat:@"%@ %@ + %@", prefix, symbolicatedSymbol, @(currentOffset)];
        *symbolicatedLine = result;
        if (symbolicatedLocations) {
            *symbolicatedLocations = @[[NSValue valueWithRange:NSMakeRange(symbolBegin, result.length - symbolBegin)]];
        }
    }

    return YES;
}

- (BOOL)symbolicateEventLine:(NSString *)line symbolicatedLine:(NSString **)symbolicatedLine symbolicatedLocations:(NSArray **)symbolicatedLocations {
    NSScanner *scanner = [NSScanner scannerWithString:line];
    uintptr_t frame = 0;
    if (![scanner scanHexLongLong:(unsigned long long *)&frame]) {
        return NO;
    }

    NSString *unknown = @"???";
    NSString *symbol = nil;
    if (![scanner scanUpToString:@" " intoString:&symbol]) {
        return NO;
    }

    NSDictionary *imagesMap = self.imagesMap;
    NSDictionary *crashImagesMap = self.crashImagesMap;

    if (![symbol isEqualToString:unknown]) {
        if ([symbol isEqualToString:@"-"]) {
            NSString *endAddressString = nil;
            if (![scanner scanUpToString:@" " intoString:&endAddressString]) {
                return NO;
            }

            NSString *imageName = nil;
            [scanner scanUpToString:@" " intoString:&imageName];
            if (![imageName isEqualToString:unknown]) {
                return NO;
            }

            NSInteger nameBegin = [line rangeOfString:unknown options:NSBackwardsSearch].location;

            if (![scanner scanUpToString:@"<" intoString:NULL] && ![scanner scanString:@"<" intoString:NULL]) {
                return NO;
            }

            NSString *uuid = nil;
            if (![scanner scanUpToString:@">" intoString:&uuid]) {
                return NO;
            }

            [scanner scanString:@">" intoString:NULL];

            NSString *key = [uuid.lowercaseString stringByReplacingOccurrencesOfString:@"-" withString:@""];
            PDLSystemImage *systemImage = imagesMap[key];
            if (!systemImage) {
                NSString *uuidString = [NSString stringWithFormat:@"<%@>", uuid];
                systemImage = crashImagesMap[uuidString];
                if (!systemImage) {
                    return NO;
                }
            }

            if (symbolicatedLine) {
                NSString *result = line;
                result = [result stringByReplacingCharactersInRange:NSMakeRange(nameBegin, unknown.length) withString:systemImage.name];
                *symbolicatedLine = result;
                if (symbolicatedLocations) {
                    *symbolicatedLocations = @[[NSValue valueWithRange:NSMakeRange(nameBegin, systemImage.name.length)]];
                }
            }
            return YES;
        }
        return NO;
    }

    NSInteger symbolBegin = [line rangeOfString:unknown].location;

    [scanner scanUpToString:@"(" intoString:NULL];
    [scanner scanString:@"(" intoString:NULL];

    NSString *name = nil;
    if (![scanner scanUpToString:@" " intoString:&name]) {
        return NO;
    }

    NSString *uuidString = nil;
    NSInteger uuidBegin = 0;
    if ([name hasPrefix:@"<"] && [name hasSuffix:@">"]) {
        uuidString = [[name substringWithRange:NSMakeRange(1, name.length - 2)].lowercaseString stringByReplacingOccurrencesOfString:@"-" withString:@""];
        uuidBegin = [line rangeOfString:name].location;
    }

    PDLCrashBinaryImage *binaryImage = crashImagesMap[name];
    if (!binaryImage) {
        return NO;
    }

    PDLSystemImage *systemImage = imagesMap[uuidString ?: name];
    if (!systemImage) {
        systemImage = imagesMap[binaryImage.name];
        if (!systemImage) {
            return NO;
        }
    }

    [scanner scanUpToString:@"+" intoString:NULL];
    [scanner scanString:@"+" intoString:NULL];

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

    NSString *imageName = systemImage.name;
    if (![@(info.dli_fname).lastPathComponent isEqualToString:imageName]) {
        return NO;
    }

    if ((uintptr_t)info.dli_fbase != systemImage.address) {
        return NO;
    }

    const char *sname = info.dli_sname;
    if (!sname) {
        return NO;
    }

    NSString *snameString = @(sname);
    if ([snameString isEqualToString:@"<redacted>"]) {
        PDLSharedCacheImage *sharedCacheImage = [[PDLSharedCache sharedInstance] sharedCacheImageWithImageName:name];
        PDLSharedCacheSymbol *sharedCacheSymbol = [sharedCacheImage symbolOfAddress:offset];
        snameString = sharedCacheSymbol.name;
        if (!snameString) {
            return NO;
        }

        if (snameString.length > 1 && [snameString hasPrefix:@"_"]) {
            snameString = [snameString substringFromIndex:1];
        }
    }

    if (symbolicatedLine) {
        NSString *symbolicatedSymbol = [self.class demangle:snameString] ?: snameString;
        uintptr_t currentOffset = current - (uintptr_t)info.dli_saddr;
        NSString *symbolicatedSymbolString = [NSString stringWithFormat:@"%@ + %@", symbolicatedSymbol, @(currentOffset)];
        NSString *result = line;
        NSValue *uuidRangeValue = nil;
        if (uuidString) {
            result = [result stringByReplacingCharactersInRange:NSMakeRange(uuidBegin, name.length) withString:imageName];
            uuidRangeValue = [NSValue valueWithRange:NSMakeRange(uuidBegin - unknown.length + symbolicatedSymbolString.length, imageName.length)];
        }
        result = [result stringByReplacingCharactersInRange:NSMakeRange(symbolBegin, unknown.length) withString:symbolicatedSymbolString];
        *symbolicatedLine = result;
        if (symbolicatedLocations) {
            NSArray *locations = @[[NSValue valueWithRange:NSMakeRange(symbolBegin, symbolicatedSymbolString.length)]];
            if (uuidRangeValue) {
                locations = [locations arrayByAddingObject:uuidRangeValue];
            }
            *symbolicatedLocations = locations;
        }
    }

    return YES;
}

- (BOOL)symbolicate {
    NSString *string = self.string;
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

    self.binaryImages = binaryImages;

    PDLSystemImage *systemImage = [PDLSystemImage executeSystemImage];
    BOOL UUIDMismatched = ![systemImage.uuidString isEqualToString:image.uuidString];
    self.UUIDMismatched = UUIDMismatched;
    if (!self.allowsUUIDMismatched && UUIDMismatched) {
        return NO;
    }

    NSString *identifier = [self.class identifier:string];
    if (![identifier isEqualToString:[NSBundle mainBundle].bundleIdentifier]) {
        self.appMismatched = ![systemImage.name isEqualToString:(process ?: command)];
    }

    NSMutableDictionary *imagesMap = [NSMutableDictionary dictionary];
    for (PDLSystemImage *systemImage in [PDLSystemImage systemImages]) {
        imagesMap[systemImage.name] = systemImage;
        imagesMap[systemImage.uuidString] = systemImage;
    }
    self.imagesMap = imagesMap;

    NSMutableDictionary *crashImagesMap = [NSMutableDictionary dictionary];
    for (PDLCrashBinaryImage *binaryImage in binaryImages) {
        crashImagesMap[binaryImage.name] = binaryImage;
    }
    self.crashImagesMap = crashImagesMap;

    if (crashType == PDLCrashTypeEvent) {
        image.name = command;
    }

    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    NSMutableString *symbolicatedString = [NSMutableString string];
    NSMutableArray *symbolicatedLocations = [NSMutableArray array];
    NSInteger symbolicatedCount = 0;
    for (NSString *line in lines) {
        NSString *symbolicateLine = line;
        BOOL symbolicated = NO;
        NSArray *locations = nil;
        if (crashType == PDLCrashTypeCrash) {
            symbolicated = [self symbolicateCrashLine:line symbolicatedLine:&symbolicateLine symbolicatedLocations:&locations];
        } else if (crashType == PDLCrashTypeEvent) {
            symbolicated = [self symbolicateEventLine:line symbolicatedLine:&symbolicateLine symbolicatedLocations:&locations];
        }
        for (NSValue *rangeValue in locations) {
            NSRange range = rangeValue.rangeValue;
            range.location += symbolicatedString.length;
            [symbolicatedLocations addObject:[NSValue valueWithRange:range]];
        }

        [symbolicatedString appendFormat:@"%@\n", symbolicateLine];
        if (symbolicated) {
            symbolicatedCount++;
        }
    }

    BOOL symbolicated = symbolicatedCount > 0;
    if (symbolicated) {
        self.symbolicatedLocations = symbolicatedLocations;
        self.symbolicatedString = symbolicatedString;
        self.symbolicatedCount = symbolicatedCount;
    }

    return symbolicated;
}

+ (NSString *)demangle:(NSString *)name {
    if (name.length == 0) {
        return nil;
    }

    const char *cstring = name.UTF8String;
    char *demangled = __cxxabiv1::__cxa_demangle(cstring, NULL, NULL, NULL);
    if (!demangled) {
        static char *(*swift_demangle)(const char *name, size_t length, const char **output, size_t *output_length, unsigned int flags) = NULL;
        static bool open = false;
        if (!open) {
            open = true;
            void *handle = dlopen(NULL, RTLD_GLOBAL | RTLD_NOW);
            if (handle) {
                swift_demangle = (typeof(swift_demangle))dlsym(handle, "swift_demangle");
                dlclose(handle);
            }
        }
        if (swift_demangle) {
            demangled = swift_demangle(cstring, strlen(cstring), NULL, NULL, 0);
        }
    }

    if (!demangled) {
        return nil;
    }

    NSString *ret = [[NSString alloc] initWithBytesNoCopy:demangled length:strlen(demangled) encoding:NSUTF8StringEncoding freeWhenDone:YES];
    return ret;
}

@end
