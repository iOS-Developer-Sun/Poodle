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
@property (assign, readonly) NSInteger symbolicatedCount;

@property (assign) BOOL allowsUUIDMisMatched;

- (instancetype)initWithString:(NSString *)string;

- (BOOL)symbolicate;

@end

NS_ASSUME_NONNULL_END
