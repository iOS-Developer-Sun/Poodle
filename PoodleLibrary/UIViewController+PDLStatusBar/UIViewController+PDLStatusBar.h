//
//  UIViewController+PDLStatusBar.h
//  Poodle
//
//  Created by Poodle on 9/5/20.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLViewControllerStatusBar : NSObject

@property (nonatomic, copy) UIViewController *(^_Nullable delegateProvider)(UIViewController *viewController);
@property (nonatomic, weak) UIViewController *delegate;

@property (nonatomic, strong) NSNumber *preferredStatusBarStyle; // UIStatusBarStyle
@property (nonatomic, strong) NSNumber *prefersStatusBarHidden; // BOOL
@property (nonatomic, strong) NSNumber *preferredStatusBarUpdateAnimation; // UIStatusBarAnimation

+ (instancetype)defaultStatusBar;

+ (NSUInteger)enableClass:(Class)aClass;
+ (NSUInteger)enableBaseClasses; // UIViewController UINavigationController UITabBarController

@end

@interface UIViewController (PDLStatusBar)

@property (nonatomic, strong, readonly) PDLViewControllerStatusBar *pdl_statusBar;

@end

NS_ASSUME_NONNULL_END
