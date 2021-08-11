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

@property (nonatomic, assign, class) BOOL eventFeedbackEnabled;

+ (void)registerEventFeedbackLayerInitializer:(void(^)(CALayer *layer, void(^defaultInitializer)(CALayer *layer)))initializer;

+ (void)registerDevelopmentToolWindowInitializer:(void(^)(UIWindow *window))initializer;
+ (UIWindow *_Nullable)developmentToolWindow;
+ (void)showDevelopmentToolWindow:(BOOL)animated completion:(void(^ _Nullable)(UIWindow *window))completion;
+ (void)hideDevelopmentToolWindow:(BOOL)animated completion:(void(^ _Nullable)(UIWindow *_Nullable window))completion;

+ (void)registerVersion:(NSString *)version;
+ (void)registerIdentifier:(NSString *)version;
+ (void)registerDevelopmentToolAction:(BOOL(^)(void))action;

+ (BOOL)enableDevelopmentTool;

+ (BOOL)registerShakeAction:(void(^)(void))shakeAction;

+ (void)exitApplication;
+ (void)terminate;


+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
+ (BOOL)handleUrl:(NSURL *)url;
+ (UIApplicationShortcutItem *)safeModeShortcutItem;

@end

NS_ASSUME_NONNULL_END
