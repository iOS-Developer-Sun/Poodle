//
//  UIViewController+PDLTrasitionAnimation.h
//  Poodle
//
//  Created by Poodle on 4/13/16.
//
//

#import <UIKit/UIKit.h>

/*
 // present / push
 [transitionContext.containerView addSubview:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view];

 // dismiss / pop
 [transitionContext.containerView insertSubview:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view belowSubview:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]];

 // all
 [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
 */

@interface UIViewController (PDLTrasitionAnimation)

- (void)pdl_presentViewController:(UIViewController *)viewControllerToPresent duration:(NSTimeInterval)duration animations:(void (^)(id <UIViewControllerContextTransitioning> transitionContext))animations completion:(void (^)(void))completion interactiveTransition:(UIPercentDrivenInteractiveTransition **)interactiveTransition;

- (void)pdl_dismissViewControllerWithDuration:(NSTimeInterval)duration animations:(void (^)(id <UIViewControllerContextTransitioning> transitionContext))animations completion:(void (^)(void))completion interactiveTransition:(UIPercentDrivenInteractiveTransition **)interactiveTransition;

@end

@interface UINavigationController (PDLTrasitionAnimation)

- (void)pdl_pushViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration animations:(void (^)(id <UIViewControllerContextTransitioning> transitionContext))animations interactiveTransition:(UIPercentDrivenInteractiveTransition **)interactiveTransition;

- (UIViewController *)pdl_popViewControllerWithDuration:(NSTimeInterval)duration animations:(void (^)(id <UIViewControllerContextTransitioning> transitionContext))animations interactiveTransition:(UIPercentDrivenInteractiveTransition **)interactiveTransition;

- (NSArray *)popToRootViewControllerWithDuration:(NSTimeInterval)duration animations:(void (^)(id <UIViewControllerContextTransitioning> transitionContext))animations interactiveTransition:(UIPercentDrivenInteractiveTransition **)interactiveTransition;

@end

@interface UITabBarController (PDLTrasitionAnimation)

- (void)pdl_setSelectedIndex:(NSUInteger)selectedIndex duration:(NSTimeInterval)duration animations:(void (^)(id <UIViewControllerContextTransitioning> transitionContext))animations interactiveTransition:(UIPercentDrivenInteractiveTransition **)interactiveTransition;

@end
