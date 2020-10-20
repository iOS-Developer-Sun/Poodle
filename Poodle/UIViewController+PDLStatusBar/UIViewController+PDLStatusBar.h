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
@property (nonatomic, weak) UIViewController *_Nullable delegate;

@property (nonatomic, strong) NSNumber *_Nullable preferredStatusBarStyle; // UIStatusBarStyle
@property (nonatomic, strong) NSNumber *_Nullable prefersStatusBarHidden; // BOOL
@property (nonatomic, strong) NSNumber *_Nullable preferredStatusBarUpdateAnimation; // UIStatusBarAnimation

@end

@interface UIViewController (PDLStatusBar)

@property (nonatomic, strong, readonly) PDLViewControllerStatusBar *pdl_statusBar;
@property (nonatomic, strong, readonly, class) Class pdl_statusBarClass;

+ (NSUInteger)pdl_statusBarEnable;

@end

NS_ASSUME_NONNULL_END
