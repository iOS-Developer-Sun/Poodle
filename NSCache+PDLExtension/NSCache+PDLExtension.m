//
//  NSCache+PDLExtension.m
//
//
//  Created by Sun on 23/06/2017.
//
//

#import "NSCache+PDLExtension.h"

@implementation NSCache (PDLExtension)

@dynamic allObjects;

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
