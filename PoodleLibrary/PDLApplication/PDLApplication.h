//
//  PDLApplication.h
//  Poodle
//
//  Created by Poodle on 2021/3/21.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLApplication : NSObject

+ (void)registerDevelopmentToolWindowInitializer:(void(^)(UIWindow *window))initializer;
+ (UIWindow *_Nullable)developmentToolWindow;
+ (void)showDevelopmentToolWindow:(BOOL)animated completion:(void(^ _Nullable)(UIWindow *window))completion;
+ (void)hideDevelopmentToolWindow:(BOOL)animated completion:(void(^ _Nullable)(UIWindow *_Nullable window))completion;

+ (void)registerVersion:(NSString *)version;
+ (void)registerIdentifier:(NSString *)version;
+ (void)registerDevelopmentToolAction:(BOOL(^)(void))action;

+ (BOOL)enable;

+ (void)exitApplication;
+ (void)terminate;

@end

NS_ASSUME_NONNULL_END
