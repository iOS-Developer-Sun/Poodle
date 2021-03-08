//
//  PDLCrash.h
//  Poodle
//
//  Created by Poodle on 2021/2/5.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLCrash : NSObject

@property (copy, readonly) NSString *string;
@property (copy, readonly) NSString *symbolicatedString;
@property (copy, readonly) NSArray *symbolicatedLocations;
@property (assign, readonly) NSInteger symbolicatedCount;
@property (assign) BOOL UUIDMismatched;

@property (assign) BOOL allowsUUIDMismatched;

- (instancetype)initWithString:(NSString *)string;

- (BOOL)symbolicate;

+ (NSString *)demangle:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
