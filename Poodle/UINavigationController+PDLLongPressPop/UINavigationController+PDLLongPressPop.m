//
//  UINavigationController+PDLLongPressPop.m
//  Poodle
//
//  Created by Poodle on 2019/1/17.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "UINavigationController+PDLLongPressPop.h"
#import <objc/runtime.h>

@interface PDLLongPressPop : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, strong) UILongPressGestureRecognizer *backButtonLongPressGestureRecognizer;

@end

@implementation PDLLongPressPop

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {
        _navigationController = navigationController;
    }
    return self;
}

- (UILongPressGestureRecognizer *)backButtonLongPressGestureRecognizer {
    if (_backButtonLongPressGestureRecognizer == nil) {
        _backButtonLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonLongPress:)];
        _backButtonLongPressGestureRecognizer.delegate = self;
    }
    return _backButtonLongPressGestureRecognizer;
}

- (UIView *)currentBackButtonView {
    UIView *backButtonView = nil;
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        @try {
            backButtonView = [navigationBar valueForKeyPath:@"visualProvider.contentView.layout.backButton"]; // "layout.leadingBar.stackView" for left and "layout.trailingBar.stackView" for right
        } @catch (NSException *exception) {
            ;
        } @finally {
            ;
        }
    } else {
        NSArray *viewControllers = self.navigationController.viewControllers;
        if (viewControllers.count >= 2) {
            UIViewController *previousViewController = viewControllers[viewControllers.count - 2];
            @try {
                backButtonView = [previousViewController.navigationItem valueForKeyPath:@"backButtonView"];
            } @catch (NSException *exception) {
                ;
            } @finally {
                ;
            }
        }
    }
    return backButtonView;
}

- (void)setEnabled:(BOOL)enabled {
    if (_enabled == enabled) {
        return;
    }

    _enabled = enabled;
    self.backButtonLongPressGestureRecognizer.enabled = enabled;
    if (enabled) {
        (void)self.navigationController.view;
        [self.navigationController.navigationBar addGestureRecognizer:self.backButtonLongPressGestureRecognizer];
    } else {
        [self.navigationController.navigationBar removeGestureRecognizer:self.backButtonLongPressGestureRecognizer];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    UIView *view = gestureRecognizer.view;
    BOOL contains = NO;
    CGPoint location = [gestureRecognizer locationInView:view];
    UIView *currentBackButtonView = [self currentBackButtonView];
    if ([currentBackButtonView isDescendantOfView:view]) {
        CGRect rect = [currentBackButtonView convertRect:currentBackButtonView.bounds toView:view];
        contains = CGRectContainsPoint(rect, location);
    }
    return contains;
}

- (void)backButtonLongPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self showNavigationViewControllers];
    } else if(longPressGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        ;
    } else if(longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        ;
    } else if(longPressGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        ;
    }
}

- (void)showNavigationViewControllers {
    NSArray *viewControllers = self.navigationController.viewControllers;
    __weak __typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Pop" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSInteger i = viewControllers.count - 2; i >= 0; i--) {
        UIViewController *viewController = viewControllers[i];
        NSString *title = NSStringFromClass(viewController.class);
        if (viewController.title) {
            title = [title stringByAppendingFormat:@":%@", viewController.title];
        }
        [alertController addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.navigationController popToViewController:viewController animated:YES];
        }]];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        ;
    }]];
    [self.navigationController.viewControllers.lastObject presentViewController:alertController animated:YES completion:nil];
}


@end

@implementation UINavigationController (PDLLongPressPop)

static void *UINavigationControllerLongPressPopKey = NULL;
- (BOOL)pdl_supportsLongPressPop {
    PDLLongPressPop *longPressPop = objc_getAssociatedObject(self, &UINavigationControllerLongPressPopKey);
    return longPressPop.enabled;
}

- (void)pdl_setSupportsLongPressPop:(BOOL)pdl_supportsLongPressPop {
    PDLLongPressPop *longPressPop = objc_getAssociatedObject(self, &UINavigationControllerLongPressPopKey);
    if (longPressPop == nil) {
        longPressPop = [[PDLLongPressPop alloc] initWithNavigationController:self];
        objc_setAssociatedObject(self, &UINavigationControllerLongPressPopKey, longPressPop, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    longPressPop.enabled = pdl_supportsLongPressPop;
}

@end
