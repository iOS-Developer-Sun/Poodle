//
//  UIViewController+PDLExtension.h
//  Poodle
//
//  Created by Poodle on 2020/12/8.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PDLViewControllerExtensionActions <NSObject>

- (void(^_Nullable)(__kindof UIViewController *))actionForKey:(id)key;
- (void)setAction:(void(^_Nullable)(__kindof UIViewController *viewController, id key))action forKey:(id)key;

- (void(^_Nullable)(__kindof UIViewController *))actionForWeakKey:(id)key;
- (void)setAction:(void(^_Nullable)(__kindof UIViewController *viewController, id key))action forWeakKey:(id)key;

@end

@protocol PDLViewControllerExtensionController <NSObject>

@property (nonatomic, strong, readonly) id <PDLViewControllerExtensionActions> viewWillAppearActions;
@property (nonatomic, strong, readonly) id <PDLViewControllerExtensionActions> viewWillDisappearActions;
@property (nonatomic, strong, readonly) id <PDLViewControllerExtensionActions> viewDidAppearActions;
@property (nonatomic, strong, readonly) id <PDLViewControllerExtensionActions> viewDidDisappearActions;


@end

@interface UIViewController (PDLExtension)

@property (nonatomic, strong, readonly) id <PDLViewControllerExtensionController> pdl_extensionController;

+ (void)pdl_enableExtension;

@end

NS_ASSUME_NONNULL_END
