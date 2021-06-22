//
//  PDLSharedCache.h
//  Poodle
//
//  Created by Poodle on 2021/6/22.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLSharedCacheSymbol : NSObject

@property (nonatomic, assign) uint8_t n_type;
@property (nonatomic, assign) uint8_t n_sect;
@property (nonatomic, assign) int16_t n_desc;
@property (nonatomic, assign) uint64_t n_value;

@property (nonatomic, assign) uintptr_t offset;
@property (nonatomic, copy) NSString *name;

@end

@interface PDLSharedCacheImage : NSObject

@property (nonatomic, copy, readonly) NSArray *symbols;

- (PDLSharedCacheSymbol *)symbolOfAddress:(uintptr_t)address;

@end

@interface PDLSharedCache : NSObject

+ (instancetype)sharedInstance;

- (NSString *)sharedCachePathWithImageName:(NSString *)imageName;
- (PDLSharedCacheImage *)sharedCacheImageWithImageName:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
