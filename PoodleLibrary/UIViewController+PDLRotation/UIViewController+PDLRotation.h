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
@property (nonatomic, weak) UIViewController *delegate;

@property (nonatomic, strong) NSNumber *shouldAutorotate; // BOOL
@property (nonatomic, strong) NSNumber *supportedInterfaceOrientations; // UIInterfaceOrientationMask
@property (nonatomic, strong) NSNumber *preferredInterfaceOrientationForPresentation; // UIInterfaceOrientation

+ (instancetype)defaultRotation;

+ (NSUInteger)enableClass:(Class)aClass;
+ (NSUInteger)enableBaseClasses; // UIViewController UINavigationController UITabBarController

@end

@interface UIViewController (PDLRotation)

@property (nonatomic, strong, readonly) PDLViewControllerRotation *pdl_rotation;

@end

NS_ASSUME_NONNULL_END
