//
//  UIViewController+PDLNavigationBar.m
//  Poodle
//
//  Created by Poodle on 04/02/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "UIViewController+PDLNavigationBar.h"

__unused __attribute__((visibility("hidden"))) void the_table_of_contents_is_empty(void) {}

@implementation UIViewController (PDLNavigationBar)

static UIBarButtonItem *customBarItemWithImageTargetAction(UIImage *image, id target, SEL action) {
    UIBarButtonItem *customBarItem;
    if (image) {
        UIImage *barButtonItemImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        customBarItem = [[UIBarButtonItem alloc] initWithImage:barButtonItemImage style:UIBarButtonItemStylePlain target:target action:action];
    } else {
        customBarItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    }

    return customBarItem;
}

static UIBarButtonItem *customBarItemWithOriginalImageTargetAction(UIImage *image, id target, SEL action) {
    UIBarButtonItem *customBarItem;
    if (image) {
        UIImage *barButtonItemImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        customBarItem = [[UIBarButtonItem alloc] initWithImage:barButtonItemImage style:UIBarButtonItemStylePlain target:target action:action];
    } else {
        customBarItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    }

    return customBarItem;
}

static UIBarButtonItem *customBarItemWithTitleTargetAction(NSString *title, id target, SEL action) {
    UIBarButtonItem *customBarItem;
    if (title) {
        customBarItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
    } else {
        customBarItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    }

    return customBarItem;
}

- (UIBarButtonItem *)pdl_setLeftButtonWithImage:(UIImage *)image target:(id)object action:(SEL)selector {
    UIBarButtonItem *customBarItem = customBarItemWithImageTargetAction(image, object, selector);
    self.navigationItem.leftBarButtonItem = customBarItem;
    return customBarItem;
}

- (UIBarButtonItem *)pdl_setRightButtonWithImage:(UIImage *)image target:(id)object action:(SEL)selector {
    UIBarButtonItem *customBarItem = customBarItemWithImageTargetAction(image, object, selector);
    self.navigationItem.rightBarButtonItem = customBarItem;
    return customBarItem;
}

- (UIBarButtonItem *)pdl_setLeftButtonWithOriginalImage:(UIImage *)image target:(id)object action:(SEL)selector {
    UIBarButtonItem *customBarItem = customBarItemWithOriginalImageTargetAction(image, object, selector);
    self.navigationItem.leftBarButtonItem = customBarItem;
    return customBarItem;
}

- (UIBarButtonItem *)pdl_setRightButtonWithOriginalImage:(UIImage *)image target:(id)object action:(SEL)selector {
    UIBarButtonItem *customBarItem = customBarItemWithOriginalImageTargetAction(image, object, selector);
    self.navigationItem.rightBarButtonItem = customBarItem;
    return customBarItem;
}


- (UIBarButtonItem *)pdl_setLeftButtonWithTitle:(NSString *)title target:(id)object action:(SEL)selector {
    UIBarButtonItem *customBarItem = customBarItemWithTitleTargetAction(title, object, selector);
    self.navigationItem.leftBarButtonItem = customBarItem;
    return customBarItem;
}

- (UIBarButtonItem *)pdl_setRightButtonWithTitle:(NSString *)title target:(id)object action:(SEL)selector {
    UIBarButtonItem *customBarItem = customBarItemWithTitleTargetAction(title, object, selector);
    self.navigationItem.rightBarButtonItem = customBarItem;
    return customBarItem;
}

@end
