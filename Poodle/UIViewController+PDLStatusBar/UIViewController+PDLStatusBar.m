//
//  UIViewController+PDLStatusBar.m
//  Poodle
//
//  Created by Poodle on 9/5/20.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "UIViewController+PDLStatusBar.h"
#import <objc/runtime.h>
#import "NSObject+PDLImplementationInterceptor.h"

@implementation PDLViewControllerStatusBar

static BOOL _enabled = NO;

static UIViewController *PDLViewControllerStatusBarDelegate(PDLViewControllerStatusBar *statusBar, UIViewController *viewController) {
    UIViewController *delegate = nil;
    typeof(statusBar.delegateProvider) delegateProvider = statusBar.delegateProvider;
    if (delegateProvider) {
        delegate = delegateProvider(viewController);
    }
    return delegate;
}

static UIStatusBarStyle PDLViewControllerStatusBarPreferredStatusBarStyle(__unsafe_unretained UIViewController *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);

    UIStatusBarStyle ret = UIStatusBarStyleDefault;
    PDLViewControllerStatusBar *statusBar = self.pdl_statusBar;
    UIViewController *delegate = PDLViewControllerStatusBarDelegate(statusBar, self);
    if (delegate) {
        ret = [delegate preferredStatusBarStyle];
        return ret;
    }

    NSNumber *preferredStatusBarStyle = statusBar.preferredStatusBarStyle;
    if (preferredStatusBarStyle) {
        ret = preferredStatusBarStyle.integerValue;
        return ret;
    }

    ret = ((typeof(&PDLViewControllerStatusBarPreferredStatusBarStyle))_imp)(self, _cmd);
    return ret;
}

static BOOL PDLViewControllerStatusBarPrefersStatusBarHidden(__unsafe_unretained UIViewController *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);

    BOOL ret = NO;
    PDLViewControllerStatusBar *statusBar = self.pdl_statusBar;
    UIViewController *delegate = PDLViewControllerStatusBarDelegate(statusBar, self);
    if (delegate) {
        ret = [delegate prefersStatusBarHidden];
        return ret;
    }

    NSNumber *prefersStatusBarHidden = statusBar.prefersStatusBarHidden;
    if (prefersStatusBarHidden) {
        ret = prefersStatusBarHidden.boolValue;
        return ret;
    }

    ret = ((typeof(&PDLViewControllerStatusBarPrefersStatusBarHidden))_imp)(self, _cmd);
    return ret;
}

static UIStatusBarAnimation PDLViewControllerStatusBarPreferredStatusBarUpdateAnimation(__unsafe_unretained UIViewController *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);

    UIStatusBarAnimation ret = UIStatusBarAnimationNone;
    PDLViewControllerStatusBar *statusBar = self.pdl_statusBar;
    UIViewController *delegate = PDLViewControllerStatusBarDelegate(statusBar, self);
    if (delegate) {
        ret = [delegate preferredStatusBarUpdateAnimation];
        return ret;
    }

    NSNumber *preferredStatusBarUpdateAnimation = statusBar.preferredStatusBarUpdateAnimation;
    if (preferredStatusBarUpdateAnimation) {
        ret = preferredStatusBarUpdateAnimation.integerValue;
        return ret;
    }

    ret = ((typeof(&PDLViewControllerStatusBarPreferredStatusBarUpdateAnimation))_imp)(self, _cmd);
    return ret;
}

+ (BOOL)enabled {
    return _enabled;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = [UIViewController class];
        __unused BOOL ret = [aClass pdl_interceptSelector:@selector(preferredStatusBarStyle) withInterceptorImplementation:(IMP)&PDLViewControllerStatusBarPreferredStatusBarStyle];
        ret &= [aClass pdl_interceptSelector:@selector(prefersStatusBarHidden) withInterceptorImplementation:(IMP)&PDLViewControllerStatusBarPrefersStatusBarHidden];
        ret &= [aClass pdl_interceptSelector:@selector(preferredStatusBarUpdateAnimation) withInterceptorImplementation:(IMP)&PDLViewControllerStatusBarPreferredStatusBarUpdateAnimation];

        aClass = [UINavigationController class];
        ret &= [aClass pdl_interceptSelector:@selector(preferredStatusBarStyle) withInterceptorImplementation:(IMP)&PDLViewControllerStatusBarPreferredStatusBarStyle];

#ifdef DEBUG
        assert(ret);
#endif
        _enabled = ret;
    });
}

@end

@implementation UIViewController (PDLStatusBar)

static void *PDLViewControllerStatusBarKey = &PDLViewControllerStatusBarKey;

- (PDLViewControllerStatusBar *)pdl_statusBar {
    if (!_enabled) {
        return nil;
    }

    PDLViewControllerStatusBar *statusBar = objc_getAssociatedObject(self, PDLViewControllerStatusBarKey);
    if (!statusBar) {
        statusBar = [[PDLViewControllerStatusBar alloc] init];
        objc_setAssociatedObject(self, PDLViewControllerStatusBarKey, statusBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return statusBar;
}

@end
