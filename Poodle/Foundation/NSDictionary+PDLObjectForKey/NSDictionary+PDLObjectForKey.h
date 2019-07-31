//
//  NSDictionary+PDLObjectForKey.h
//  Poodle
//
//  Created by Poodle on 14-7-25.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (PDLObjectForKey)

- (id)pdl_dictionary_objectForKey:(id <NSCopying>)key class:(Class)class;

- (NSNumber *)pdl_boolNumberForKey:(id <NSCopying>)key;
- (NSNumber *)pdl_integerNumberForKey:(id <NSCopying>)key;
- (NSNumber *)pdl_longLongNumberForKey:(id <NSCopying>)key;
- (NSNumber *)pdl_floatNumberForKey:(id <NSCopying>)key;
- (NSNumber *)pdl_doubleNumberForKey:(id <NSCopying>)key;
- (NSString *)pdl_stringObjectForKey:(id <NSCopying>)key;
- (NSDictionary *)pdl_dictionaryObjectForKey:(id <NSCopying>)key;
- (NSArray *)pdl_arrayObjectForKey:(id <NSCopying>)key;
- (NSData *)pdl_dataObjectForKey:(id <NSCopying>)key;

@end
