//
//  UIViewController+PDLTransitionAnimation.m
//  Poodle
//
//  Created by Poodle on 4/13/16.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "UIViewController+PDLTransitionAnimation.h"

@interface PDLUIPercentDrivenInteractiveTransition : UIPercentDrivenInteractiveTransition

@end

@implementation PDLUIPercentDrivenInteractiveTransition

- (Class)class {
    return [UIPercentDrivenInteractiveTransition class];
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    CGFloat adjustedPercentComplete = percentComplete;
    if (adjustedPercentComplete < (CGFloat)0.01) {
        adjustedPercentComplete = (CGFloat)0.01;
    }
    if (adjustedPercentComplete > (CGFloat)0.99) {
        adjustedPercentComplete = (CGFloat)0.99;
    }
    [super updateInteractiveTransition:adjustedPercentComplete];
}

@end

@interface PDLUIViewControllerTransitionAnimationDelegate : NSObject <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning>

@property (nonatomic, assign) NSTimeInterval transitionDuration;
@property (nonatomic, copy) void (^animation)(id <UIViewControllerContextTransitioning> transitionContext);
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransitioning;
@property (nonatomic, weak) id <UIViewControllerTransitioningDelegate> originalTransitioningDelegate;
@property (nonatomic, weak) UIViewController *viewController;

- (void)enableInteractiveTransitioning;

@end

@implementation PDLUIViewControllerTransitionAnimationDelegate

- (void)enableInteractiveTransitioning {
    UIPercentDrivenInteractiveTransition *interactiveTransitioning = [[PDLUIPercentDrivenInteractiveTransition alloc] init];
    self.interactiveTransitioning = interactiveTransitioning;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self.interactiveTransitioning;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self.interactiveTransitioning;
}

//- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source NS_AVAILABLE_IOS(8_0);

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return self.transitionDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.animation) {
        self.animation(transitionContext);
    }
}

- (void)animationEnded:(BOOL)transitionCompleted {
    self.animation = nil;
    self.viewController.transitioningDelegate = self.originalTransitioningDelegate;
}

#pragma mark - UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.animation) {
        self.animation(transitionContext);
    }
}

- (CGFloat)completionSpeed {
    return 1.0;
}

- (UIViewAnimationCurve)completionCurve {
    return UIViewAnimationCurveEaseInOut;
}

@end

@implementation UIViewController (PDLTransitionAnimation)

- (void)pdl_presentViewController:(UIViewController *)viewControllerToPresent duration:(NSTimeInterval)duration animations:(void (^)(id <UIViewControllerContextTransitioning> transitionContext))animations completion:(void (^)(void))completion interactiveTransition:(UIPercentDrivenInteractiveTransition **)interactiveTransition {
    PDLUIViewControllerTransitionAnimationDelegate *delegate = [[PDLUIViewControllerTransitionAnimationDelegate alloc] init];
    delegate.transitionDuration = duration;
    delegate.animation = ^(id <UIViewControllerContextTransitioning> transitionContext) {
        if (animations) {
            animations(transitionContext);
        }
    };
    if (interactiveTransition) {
        [delegate enableInteractiveTransitioning];
        *interactiveTransition = delegate.interactiveTransitioning;
    }
    delegate.originalTransitioningDelegate = viewControllerToPresent.transitioningDelegate;
    delegate.viewController = viewControllerToPresent;
    viewControllerToPresent.transitioningDelegate = delegate;
    [self presentViewController:viewControllerToPresent animated:YES completion:completion];
}

- (void)pdl_dismissViewControllerWithDuration:(NSTimeInterval)duration animations:(void (^)(id <UIViewControllerContextTransitioning> transitionContext))animations completion:(void (^)(void))completion interactiveTransition:(UIPercentDrivenInteractiveTransition **)interactiveTransition {
    PDLUIViewControllerTransitionAnimationDelegate *delegate = [[PDLUIViewControllerTransitionAnimationDelegate alloc] init];
    delegate.transitionDuration = duration;
    delegate.animation = ^(id <UIViewControllerContextTransitioning> transitionContext) {
        if (animations) {
            animations(transitionContext);
        }
    };
    if (interactiveTransition) {
        [delegate enableInteractiveTransitioning];
        *interactiveTransition = delegate.interactiveTransitioning;
    }
    delegate.originalTransitioningDelegate = self.transitioningDelegate;
    delegate.viewController = self.presentingViewController.presentedViewController;
    self.presentingViewController.presentedViewController.transitioningDelegate = delegate;
    [self dismissViewControllerAnimated:YES completion:completion];
}

@end

@interface PDLUINavigationControllerTransitionAnimationDelegate : PDLUIViewControllerTransitionAnimationDelegate <UINavigationControllerDelegate>

@property (nonatomic, weak) id <UINavigationControllerDelegate> originalDelegate;
@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation PDLUINavigationControllerTransitionAnimationDelegate

- (void)animationEnded:(BOOL)transitionCompleted {
    [super animationEnded:transitionCompleted];

    self.navigationController.delegate = self.originalDelegate;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self.originalDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.originalDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self.originalDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.originalDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    return self;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    return self.interactiveTransitioning;
}

@end

@implementation UINavigationController (PDLTransitionAnimation)

- (void)pdl_pushViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration animations:(void (^)(id <UIViewControllerContextTransitioning> transitionContext))animations interactiveTransition:(UIPercentDrivenInteractiveTransition **)interactiveTransition {
    PDLUINavigationControllerTransitionAnimationDelegate *delegate = [[PDLUINavigationControllerTransitionAnimationDelegate alloc] init];
    delegate.transitionDuration = duration;
    delegate.animation = ^(id <UIViewControllerContextTransitioning> transitionContext) {
        if (animations) {
            animations(transitionContext);
        }
    };
    if (interactiveTransition) {
        [delegate enableInteractiveTransitioning];
        *interactiveTransition = delegate.interactiveTransitioning;
    }
    delegate.originalDelegate = self.delegate;
    delegate.navigationController = self;
    self.delegate = delegate;
    [self pushViewController:viewController animated:YES];
}

- (UIViewController *)pdl_popViewControllerWithDuration:(NSTimeInterval)duration animations:(void (^)(id <UIViewControllerContextTransitioning> transitionContext))animations interactiveTransition:(UIPercentDrivenInteractiveTransition **)interactiveTransition {
    PDLUINavigationControllerTransitionAnimationDelegate *delegate = [[PDLUINavigationControllerTransitionAnimationDelegate alloc] init];
    delegate.transitionDuration = duration;
    delegate.animation = ^(id <UIViewControllerContextTransitioning> transitionContext) {
        if (animations) {
            animations(transitionContext);
        }
    };
    if (interactiveTransition) {
        [delegate enableInteractiveTransitioning];
        *interactiveTransition = delegate.interactiveTransitioning;
    }
    delegate.originalDelegate = self.delegate;
    delegate.navigationController = self;
    self.delegate = delegate;
    UIViewController *viewController = [self popViewControllerAnimated:YES];
    return viewController;
}

- (NSArray *)pdl_popToViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration animations:(void (^)(id <UIViewControllerContextTransitioning> transitionContext))animations interactiveTransition:(UIPercentDrivenInteractiveTransition **)interactiveTransition {
    PDLUINavigationControllerTransitionAnimationDelegate *delegate = [[PDLUINavigationControllerTransitionAnimationDelegate alloc] init];
    delegate.transitionDuration = duration;
    delegate.animation = ^(id <UIViewControllerContextTransitioning> transitionContext) {
        if (animations) {
            animations(transitionContext);
        }
    };
    if (interactiveTransition) {
        [delegate enableInteractiveTransitioning];
        *interactiveTransition = delegate.interactiveTransitioning;
    }
    delegate.originalDelegate = self.delegate;
    delegate.navigationController = self;
    self.delegate = delegate;
    NSArray *viewControllers = [self popToViewController:viewController animated:YES];
    return viewControllers;
}

- (NSArray *)pdl_popToRootViewControllerWithDuration:(NSTimeInterval)duration animations:(void (^)(id <UIViewControllerContextTransitioning> transitionContext))animations interactiveTransition:(UIPercentDrivenInteractiveTransition **)interactiveTransition {
    PDLUINavigationControllerTransitionAnimationDelegate *delegate = [[PDLUINavigationControllerTransitionAnimationDelegate alloc] init];
    delegate.transitionDuration = duration;
    delegate.animation = ^(id <UIViewControllerContextTransitioning> transitionContext) {
        if (animations) {
            animations(transitionContext);
        }
    };
    if (interactiveTransition) {
        [delegate enableInteractiveTransitioning];
        *interactiveTransition = delegate.interactiveTransitioning;
    }
    delegate.originalDelegate = self.delegate;
    delegate.navigationController = self;
    self.delegate = delegate;
    NSArray *viewControllers = [self popToRootViewControllerAnimated:YES];
    return viewControllers;
}

@end

@interface PDLUITabBarControllerTransitionAnimationDelegate : PDLUIViewControllerTransitionAnimationDelegate <UITabBarControllerDelegate>

@property (nonatomic, weak) id <UITabBarControllerDelegate> originalDelegate;
@property (nonatomic, weak) UITabBarController *tabBarController;

@end

@implementation PDLUITabBarControllerTransitionAnimationDelegate

- (void)animationEnded:(BOOL)transitionCompleted {
    [super animationEnded:transitionCompleted];

    self.tabBarController.delegate = self.originalDelegate;
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return [self.originalDelegate tabBarController:tabBarController shouldSelectViewController:viewController];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [self.originalDelegate tabBarController:tabBarController didSelectViewController:viewController];
}

- (void)tabBarController:(UITabBarController *)tabBarController willBeginCustomizingViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    [self.originalDelegate tabBarController:tabBarController willBeginCustomizingViewControllers:viewControllers];
}

- (void)tabBarController:(UITabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers changed:(BOOL)changed {
    [self.originalDelegate tabBarController:tabBarController willEndCustomizingViewControllers:viewControllers changed:changed];
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers changed:(BOOL)changed {
    [self.originalDelegate tabBarController:tabBarController didEndCustomizingViewControllers:viewControllers changed:changed];
}

- (UIInterfaceOrientationMask)tabBarControllerSupportedInterfaceOrientations:(UITabBarController *)tabBarController {
    return [self.originalDelegate tabBarControllerSupportedInterfaceOrientations:tabBarController];
}

- (UIInterfaceOrientation)tabBarControllerPreferredInterfaceOrientationForPresentation:(UITabBarController *)tabBarController {
    return [self.originalDelegate tabBarControllerPreferredInterfaceOrientationForPresentation:tabBarController];
}

- (nullable id <UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController
                               interactionControllerForAnimationController: (id <UIViewControllerAnimatedTransitioning>)animationController {
    return self.interactiveTransitioning;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
                     animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                                       toViewController:(UIViewController *)toVC {
    return self;
}

@end

@implementation UITabBarController (PDLTransitionAnimation)

- (void)pdl_setSelectedIndex:(NSUInteger)selectedIndex duration:(NSTimeInterval)duration animations:(void (^)(id <UIViewControllerContextTransitioning> transitionContext))animations interactiveTransition:(UIPercentDrivenInteractiveTransition **)interactiveTransition {
    PDLUITabBarControllerTransitionAnimationDelegate *delegate = [[PDLUITabBarControllerTransitionAnimationDelegate alloc] init];
    delegate.transitionDuration = duration;
    delegate.animation = ^(id <UIViewControllerContextTransitioning> transitionContext) {
        if (animations) {
            animations(transitionContext);
        }
    };
    if (interactiveTransition) {
        [delegate enableInteractiveTransitioning];
        *interactiveTransition = delegate.interactiveTransitioning;
    }
    delegate.originalDelegate = self.delegate;
    delegate.tabBarController = self;
    self.delegate = delegate;
    self.selectedIndex = selectedIndex;
}

@end
