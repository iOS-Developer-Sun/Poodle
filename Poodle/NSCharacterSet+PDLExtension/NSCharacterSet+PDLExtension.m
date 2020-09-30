//
//  NSCharacterSet+PDLExtension.m
//  Poodle
//
//  Created by Poodle on 2019/2/20.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSCharacterSet+PDLExtension.h"

@implementation NSCharacterSet (PDLExtension)

+ (NSCharacterSet *)pdl_emptyCharacterSet {
    return [self characterSetWithCharactersInString:@""];
}

+ (NSCharacterSet *)pdl_allCharacterSet {
    return self.pdl_emptyCharacterSet.invertedSet;
}

+ (NSCharacterSet *)pdl_URLAllowedCharacterSet {
    static NSCharacterSet *URLAllowedCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSCharacterSet *URLUserAllowedCharacterSet = [NSCharacterSet URLUserAllowedCharacterSet];
        NSCharacterSet *URLPasswordAllowedCharacterSet = [NSCharacterSet URLPasswordAllowedCharacterSet];
        NSCharacterSet *URLHostAllowedCharacterSet = [NSCharacterSet URLHostAllowedCharacterSet];
        NSCharacterSet *URLPathAllowedCharacterSet = [NSCharacterSet URLPathAllowedCharacterSet];
        NSCharacterSet *URLQueryAllowedCharacterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
        NSCharacterSet *URLFragmentAllowedCharacterSet = [NSCharacterSet URLFragmentAllowedCharacterSet];

        NSMutableCharacterSet *characterSet = [URLUserAllowedCharacterSet mutableCopy];
        [characterSet formIntersectionWithCharacterSet:URLPasswordAllowedCharacterSet];
        [characterSet formIntersectionWithCharacterSet:URLHostAllowedCharacterSet];
        [characterSet formIntersectionWithCharacterSet:URLPathAllowedCharacterSet];
        [characterSet formIntersectionWithCharacterSet:URLQueryAllowedCharacterSet];
        [characterSet formIntersectionWithCharacterSet:URLFragmentAllowedCharacterSet];

        URLAllowedCharacterSet = [characterSet copy];
    });

    return URLAllowedCharacterSet;
}

@end
