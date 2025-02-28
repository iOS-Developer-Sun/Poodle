//
//  NSData+PDLExtension.m
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSData+PDLExtension.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (PDLExtension)

- (NSString *)pdl_hexString {
    const char *bytes = (const char *)self.bytes;
    NSMutableString *hexString = [NSMutableString string];
    for (NSInteger count = 0; count < self.length; count++){
        [hexString appendFormat:@"%02x", bytes[count]];
    }
    return [hexString copy];
}

- (NSData *)pdl_md5 {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    CC_MD5([self bytes], (CC_LONG)[self length], result);
#pragma clang diagnostic pop
    NSData *md5 = [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
    return md5;
}

- (NSString *)pdl_md5String {
    NSData *md5 = [self pdl_md5];
    return md5.pdl_hexString;
}

#pragma mark - CRC

- (uint32_t)pdl_crc32 {
    static uint32_t crc32_table[256];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uint32_t polynomial = 0xEDB88320;
        for (uint32_t i = 0; i < 256; i++) {
            uint32_t crc = i;
            for (uint32_t j = 0; j < 8; j++) {
                if (crc & 1) {
                    crc = (crc >> 1) ^ polynomial;
                } else {
                    crc >>= 1;
                }
            }
            crc32_table[i] = crc;
        }
    });

    uint32_t crc = 0xFFFFFFFF;
    const uint8_t *bytes = (const uint8_t *)[self bytes];
    NSUInteger length = [self length];

    for (NSUInteger i = 0; i < length; i++) {
        uint8_t index = (crc ^ bytes[i]) & 0xFF;
        crc = (crc >> 8) ^ crc32_table[index];
    }

    return crc ^ 0xFFFFFFFF;
}

#pragma mark - AES

- (NSData *)pdl_AES256DataWithOperation:(CCOperation)operation keyData:(NSData *)key isCBCMode:(BOOL)bCBCMode initVector:(NSData *)initVector {
    if (!([key length] == 16 || [key length] == 24 || [key length] == 32) || (bCBCMode && [initVector length] != kCCBlockSizeAES128)) {
        assert(NO);
        return nil;
    }

    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCOptions options = bCBCMode ? (kCCOptionPKCS7Padding) : (kCCOptionPKCS7Padding | kCCOptionECBMode);
    CCCryptorStatus cryptStatus = CCCrypt(operation, kCCAlgorithmAES128, options, [key bytes], [key length], [initVector bytes], [self bytes], dataLength, buffer, bufferSize, &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }

    free(buffer);
    return nil;
}

#pragma mark Random Generator
+ (NSData *)pdl_AES256RandomKey {
    return [self AES256RandomDataWithSize:kCCKeySizeAES256];
}

+ (NSData *)pdl_AES256RandomInitVector {
    return [self AES256RandomDataWithSize:kCCBlockSizeAES128];
}

+ (NSData *)AES256RandomDataWithSize:(size_t)size {
    assert(size);
    if (size > 0) {
        u_int8_t buf[size];
        if (SecRandomCopyBytes(kSecRandomDefault, size, buf) == 0) {
            return [NSData dataWithBytes:buf length:size];
        }
    }

    return nil;
}

#pragma mark Encrypt
- (NSData *)pdl_AES256EncryptWithKey:(NSString *)key {
    return [self pdl_AES256EncryptWithKeyData:[key dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSData *)pdl_AES256EncryptWithKeyData:(NSData *)key {
    return [self pdl_AES256EncryptWithKeyData:key isCBCMode:NO initVector:nil];
}

- (NSData *)pdl_AES256EncryptWithKeyData:(NSData *)key isCBCMode:(BOOL)bCBCMode initVector:(NSData *)initVector {
    return [self pdl_AES256DataWithOperation:kCCEncrypt keyData:key isCBCMode:bCBCMode initVector:initVector];
}

#pragma mark Decrypt
- (NSData *)pdl_AES256DecryptWithKey:(NSString *)key {
    return [self pdl_AES256DecryptWithKeyData:[key dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSData *)pdl_AES256DecryptWithKeyData:(NSData *)key {
    return [self pdl_AES256DecryptWithKeyData:key isCBCMode:NO initVector:nil];
}

- (NSData *)pdl_AES256DecryptWithKeyData:(NSData *)key isCBCMode:(BOOL)bCBCMode initVector:(NSData *)initVector {
    return [self pdl_AES256DataWithOperation:kCCDecrypt keyData:key isCBCMode:bCBCMode initVector:initVector];
}

@end
