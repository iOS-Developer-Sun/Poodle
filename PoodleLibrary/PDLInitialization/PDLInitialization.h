//
//  PDLInitialization.h
//  Poodle
//
//  Created by Poodle on 2020/9/3.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLInitializationLoader : NSObject

@property (nonatomic, unsafe_unretained, readonly) Class aClass;
@property (nonatomic, assign, readonly) CFTimeInterval duration;
@property (nonatomic, assign, readonly) IMP imp;

@end

@interface PDLInitialization : NSObject

+ (NSUInteger)preloadCount;
+ (NSUInteger)preload:(BOOL(^_Nullable)(Class aClass, IMP imp))filter;
+ (NSArray <PDLInitializationLoader *>*)loaders;
+ (NSArray <PDLInitializationLoader *>*)topLoaders;

@end

NS_ASSUME_NONNULL_END
