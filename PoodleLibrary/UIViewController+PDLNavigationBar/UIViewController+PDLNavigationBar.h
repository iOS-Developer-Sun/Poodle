//
//  UIViewController+PDLNavigationBar.h
//  Poodle
//
//  Created by Poodle on 04/02/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (PDLNavigationBar)

- (UIBarButtonItem *)pdl_setLeftButtonWithImage:(UIImage *)image target:(id)object action:(SEL)selector;
- (UIBarButtonItem *)pdl_setRightButtonWithImage:(UIImage *)image target:(id)object action:(SEL)selector;

- (UIBarButtonItem *)pdl_setLeftButtonWithOriginalImage:(UIImage *)image target:(id)object action:(SEL)selector;
- (UIBarButtonItem *)pdl_setRightButtonWithOriginalImage:(UIImage *)image target:(id)object action:(SEL)selector;

- (UIBarButtonItem *)pdl_setLeftButtonWithTitle:(NSString *)title target:(id)object action:(SEL)selector;
- (UIBarButtonItem *)pdl_setRightButtonWithTitle:(NSString *)title target:(id)object action:(SEL)selector;

@end
