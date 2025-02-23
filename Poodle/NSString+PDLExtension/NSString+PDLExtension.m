//
//  NSString+PDLExtension.m
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSString+PDLExtension.h"

@implementation NSString (PDLExtension)

- (NSString *)pdl_trimmedString {
    NSString *trimmedString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmedString;
}

- (NSString *)pdl_plainText {
    NSString *plainText = [self stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    plainText = [plainText stringByReplacingOccurrencesOfString:@"\t"  withString:@" "];
    return plainText;
}

@end
