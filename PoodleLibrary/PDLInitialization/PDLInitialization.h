//
//  PDLInitialization.h
//  Poodle
//
//  Created by Poodle on 2020/9/3.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLInitialization : NSObject

@property (nonatomic, assign, readonly) CFTimeInterval duration;
@property (nonatomic, unsafe_unretained, readonly) Class aClass;
@property (nonatomic, assign, readonly) IMP imp;

+ (NSUInteger)count;
+ (NSUInteger)preload;
+ (NSArray *)loaders;

@end

NS_ASSUME_NONNULL_END
