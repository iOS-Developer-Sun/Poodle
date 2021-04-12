//
//  NSDictionary+PDLObjectForKey.m
//  Poodle
//
//  Created by Poodle on 14-7-25.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSDictionary+PDLObjectForKey.h"

#if !TARGET_OS_OSX
__unused __attribute__((visibility("hidden"))) void the_table_of_contents_is_empty(void) {}
#endif

@implementation NSDictionary (PDLObjectForKey)

- (id)pdl_dictionary_objectForKey:(id <NSCopying>)key class:(Class)class {
    id object = self[key];
    if ([object isKindOfClass:class]) {
        return object;
    } else {
        return nil;
    }
}

- (NSNumber *)pdl_boolNumberForKey:(id <NSCopying>)key {
    id object = self[key];
    if ([object respondsToSelector:@selector(boolValue)]) {
        return @([object boolValue]);
    } else {
        return nil;
    }
}

- (NSNumber *)pdl_integerNumberForKey:(id <NSCopying>)key {
    id object = self[key];
    if ([object respondsToSelector:@selector(integerValue)]) {
        return @([object integerValue]);
    } else {
        return nil;
    }
}

- (NSNumber *)pdl_longLongNumberForKey:(id <NSCopying>)key {
    id object = self[key];
    if ([object respondsToSelector:@selector(longLongValue)]) {
        return @([object longLongValue]);
    } else {
        return nil;
    }
}

- (NSNumber *)pdl_floatNumberForKey:(id <NSCopying>)key {
    id object = self[key];
    if ([object respondsToSelector:@selector(floatValue)]) {
        return @([object floatValue]);
    } else {
        return nil;
    }
}

- (NSNumber *)pdl_doubleNumberForKey:(id <NSCopying>)key {
    id object = self[key];
    if ([object respondsToSelector:@selector(doubleValue)]) {
        return @([object doubleValue]);
    } else {
        return nil;
    }
}

- (NSString *)pdl_stringObjectForKey:(id <NSCopying>)key {
    return [self pdl_dictionary_objectForKey:key class:[NSString class]];
}

- (NSDictionary *)pdl_dictionaryObjectForKey:(id <NSCopying>)key {
    return [self pdl_dictionary_objectForKey:key class:[NSDictionary class]];
}

- (NSArray *)pdl_arrayObjectForKey:(id <NSCopying>)key {
    return [self pdl_dictionary_objectForKey:key class:[NSArray class]];
}

- (NSData *)pdl_dataObjectForKey:(id <NSCopying>)key {
    return [self pdl_dictionary_objectForKey:key class:[NSData class]];
}

@end
