//
//  PDLDYLDSharedCache.h
//  Poodle
//
//  Created by Poodle on 2021/12/19.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDLDYLDSharedCache : NSObject

@property (nonatomic, copy) NSString *destinationPath;
@property (nonatomic, copy) NSString *tmpPath;

+ (instancetype)sharedCacheWithPath:(NSString *)path;
- (BOOL)extract:(NSArray *)imageNames;

@end
