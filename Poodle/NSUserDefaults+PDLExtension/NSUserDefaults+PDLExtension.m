//
//  NSUserDefaults+PDLExtension.m
//  Poodle
//
//  Created by Poodle on 23/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSUserDefaults+PDLExtension.h"

__attribute__((objc_direct_members))
@implementation NSUserDefaults (PDLExtension)

- (id)objectForKeyedSubscript:(id)key {
    id object = [self objectForKey:key];
    return object;
}

- (void)setObject:(id)obj forKeyedSubscript:(id)key {
    [self setObject:obj forKey:key];
}

@end
