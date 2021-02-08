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

@property (nonatomic, assign, readonly) CFTimeInterval duration;
@property (nonatomic, assign, readonly) IMP imp;
@property (nonatomic, unsafe_unretained, readonly) Class aClass;

@end

@interface PDLInitializationInitializer : NSObject

@property (nonatomic, assign, readonly) CFTimeInterval duration;
@property (nonatomic, assign, readonly) void *function;
@property (nonatomic, copy, readonly) NSString *imageName;
@property (nonatomic, copy, readonly) NSString *functionName;

@end

@interface PDLInitialization : NSObject

+ (NSUInteger)preloadCount;
+ (NSUInteger)preload:(BOOL(^_Nullable)(Class aClass, IMP imp))filter;
+ (NSArray <PDLInitializationLoader *>*)loaders;
+ (NSArray <PDLInitializationLoader *>*)topLoaders;

+ (NSUInteger)preinitializeCount;
+ (NSUInteger)preinitialize:(BOOL(^_Nullable)(NSString *imageName, NSString *functionName, void *function))filter;
+ (NSArray <PDLInitializationInitializer *>*)initializers;
+ (NSArray <PDLInitializationInitializer *>*)topInitializers;

@end

NS_ASSUME_NONNULL_END
