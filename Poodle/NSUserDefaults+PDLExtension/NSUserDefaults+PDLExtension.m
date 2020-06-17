//
//  NSUserDefaults+PDLExtension.m
//  Poodle
//
//  Created by Poodle on 23/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSUserDefaults+PDLExtension.h"

__unused __attribute__((visibility("hidden"))) void the_table_of_contents_is_empty(void) {}

@implementation NSUserDefaults (PDLExtension)

- (id)objectForKeyedSubscript:(id)key {
    id object = [self objectForKey:key];
    return object;
}

- (void)setObject:(id)obj forKeyedSubscript:(id)key {
    if (obj) {
        [self setObject:obj forKey:key];
    } else {
        [self removeObjectForKey:key];
    }
}

@end
