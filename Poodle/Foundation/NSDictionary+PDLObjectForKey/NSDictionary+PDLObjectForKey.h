//
//  NSDictionary+PDLObjectForKey.h
//  Sun
//
//  Created by Sun on 14-7-25.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (PDLObjectForKey)

- (id)pdl_objectForKey:(id)key class:(Class)class;

- (NSNumber *)pdl_boolNumberForKey:(id)key;
- (NSNumber *)pdl_integerNumberForKey:(id)key;
- (NSNumber *)pdl_longLongNumberForKey:(id)key;
- (NSNumber *)pdl_floatNumberForKey:(id)key;
- (NSNumber *)pdl_doubleNumberForKey:(id)key;
- (NSString *)pdl_stringObjectForKey:(id)key;
- (NSDictionary *)pdl_dictionaryObjectForKey:(id)key;
- (NSArray *)pdl_arrayObjectForKey:(id)key;
- (NSData *)pdl_dataObjectForKey:(id)key;

@end
