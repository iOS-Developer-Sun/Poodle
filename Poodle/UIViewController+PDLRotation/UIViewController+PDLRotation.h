//
//  UIViewController+PDLRotation.h
//  Poodle
//
//  Created by Poodle on 9/5/20.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLViewControllerRotation : NSObject

@property (nonatomic, copy) UIViewController *(^_Nullable delegateProvider)(UIViewController *viewController);
@property (nonatomic, weak) UIViewController *_Nullable delegate;

@property (nonatomic, strong) NSNumber *_Nullable shouldAutorotate; // BOOL
@property (nonatomic, strong) NSNumber *_Nullable supportedInterfaceOrientations; // UIInterfaceOrientationMask
@property (nonatomic, strong) NSNumber *_Nullable preferredInterfaceOrientationForPresentation; // UIInterfaceOrientation

+ (instancetype)defaultRotation;

+ (NSUInteger)enableViewController;
+ (NSUInteger)enableNavigationController;
+ (NSUInteger)enableTabBarController;
+ (NSUInteger)enableBaseClasses;

@end

@interface UIViewController (PDLRotation)

@property (nonatomic, strong, readonly) PDLViewControllerRotation *pdl_rotation;
@property (nonatomic, strong, readonly, class) Class pdl_rotationClass;

@end

NS_ASSUME_NONNULL_END
