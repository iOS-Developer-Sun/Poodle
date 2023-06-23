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

@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) IMP imp;
@property (nonatomic, unsafe_unretained, readonly) Class aClass;
@property (nonatomic, assign, readonly) const char *category;

@end

@interface PDLInitializationInitializer : NSObject

@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) void *function;
@property (nonatomic, copy, readonly) NSString *imageName;
@property (nonatomic, copy, readonly) NSString *functionName;

@end

@interface PDLInitialization : NSObject

@property (nonatomic, assign, class) void (*initializer)(int argc, const char * _Nullable * _Nullable argv, const char * _Nullable * _Nullable envp, const char * _Nullable * _Nullable apple, void *pvars);

+ (NSUInteger)preloadCount;
+ (NSUInteger)preload:(const void *)header filter:(BOOL(^_Nullable)(Class aClass, const char *_Nullable categoryName, IMP imp))filter;
+ (NSArray <PDLInitializationLoader *>*)loaders;
+ (NSArray <PDLInitializationLoader *>*)topLoaders;

+ (NSUInteger)preinitializeCount;
+ (NSUInteger)preinitialize:(const void *)header filter:(BOOL(^_Nullable)(NSString *imageName, NSString *functionName, void *function))filter;
+ (NSArray <PDLInitializationInitializer *>*)initializers;
+ (NSArray <PDLInitializationInitializer *>*)topInitializers;

+ (NSTimeInterval)hostTimeConversion;

@end

NS_ASSUME_NONNULL_END
