//
//  NSData+PDLExtension.h
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <pthread.h>
#import <Foundation/Foundation.h>

@interface NSData (PDLExtension)

- (NSString *)pdl_hexString;

#pragma mark – MD5

- (NSData *)pdl_md5;
- (NSString *)pdl_md5String;

#pragma mark – CRC

- (uint32_t)pdl_crc32;

#pragma mark – AES

#pragma mark Random Generator
+ (NSData *)pdl_AES256RandomKey;
+ (NSData *)pdl_AES256RandomInitVector;

#pragma mark Encrypt
- (NSData *)pdl_AES256EncryptWithKey:(NSString *)key;
- (NSData *)pdl_AES256EncryptWithKeyData:(NSData *)key;
- (NSData *)pdl_AES256EncryptWithKeyData:(NSData *)key isCBCMode:(BOOL)bCBCMode initVector:(NSData *)initVector;

#pragma mark Decrypt
- (NSData *)pdl_AES256DecryptWithKey:(NSString *)key;
- (NSData *)pdl_AES256DecryptWithKeyData:(NSData *)key;
- (NSData *)pdl_AES256DecryptWithKeyData:(NSData *)key isCBCMode:(BOOL)bCBCMode initVector:(NSData *)initVector;

@end
