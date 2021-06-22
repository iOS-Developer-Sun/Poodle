//
//  PDLSharedCache.h
//  Poodle
//
//  Created by Poodle on 2021/6/22.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLSharedCache : NSObject

+ (instancetype)sharedInstance;

- (NSString *)sharedCachePathWithImageName:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
