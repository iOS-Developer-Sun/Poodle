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

@interface PDLViewControllerStatusBar ()

@end

@implementation PDLViewControllerStatusBar

- (instancetype)init {
    self = [super init];
    if (self) {
        PDLViewControllerStatusBar *defaultStatusBar = [self.class defaultStatusBar];
        _preferredStatusBarStyle = defaultStatusBar.preferredStatusBarStyle;
        _prefersStatusBarHidden = defaultStatusBar.prefersStatusBarHidden;
        _preferredStatusBarUpdateAnimation = defaultStatusBar.preferredStatusBarUpdateAnimation;
    }
    return self;
}

static UIViewController *PDLViewControllerStatusBarDelegate(PDLViewControllerStatusBar *statusBar, UIViewController *viewController) {
    UIViewController *delegate = nil;
    typeof(statusBar.delegateProvider) delegateProvider = statusBar.delegateProvider;
    if (delegateProvider) {
        delegate = delegateProvider(viewController);
    }
    if (!delegate) {
        delegate = statusBar.delegate;
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

+ (instancetype)defaultStatusBar {
    static id defaultStatusBar = nil;
    if (!defaultStatusBar) {
        defaultStatusBar = [[self alloc] init];
    }
    return defaultStatusBar;
}

+ (NSUInteger)enableClass:(Class)aClass {
    __unused NSUInteger count = 0;
    BOOL ret = NO;
    ret = [aClass pdl_interceptSelector:@selector(preferredStatusBarStyle) withInterceptorImplementation:(IMP)&PDLViewControllerStatusBarPreferredStatusBarStyle];
    if (ret) {
        count++;
    }

    ret = [aClass pdl_interceptSelector:@selector(prefersStatusBarHidden) withInterceptorImplementation:(IMP)&PDLViewControllerStatusBarPrefersStatusBarHidden];
    if (ret) {
        count++;
    }

    ret = [aClass pdl_interceptSelector:@selector(preferredStatusBarUpdateAnimation) withInterceptorImplementation:(IMP)&PDLViewControllerStatusBarPreferredStatusBarUpdateAnimation];
    if (ret) {
        count++;
    }
    return count;
}

+ (NSUInteger)enableViewController {
    __block NSUInteger ret = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ret = [self enableClass:[UIViewController class]];
    });
    return ret;
}

+ (NSUInteger)enableNavigationController {
    __block NSUInteger ret = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ret = [self enableClass:[UINavigationController class]];
    });
    return ret;
}

+ (NSUInteger)enableTabBarController {
    __block NSUInteger ret = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ret = [self enableClass:[UITabBarController class]];
    });
    return ret;
}

+ (NSUInteger)enableBaseClasses {
    NSUInteger ret = 0;
    ret += [self enableViewController];
    ret += [self enableNavigationController];
    ret += [self enableTabBarController];
    return ret;
}

@end

#pragma mark - Subclasses

@interface PDLNavigationControllerStatusBar : PDLViewControllerStatusBar

@end

@implementation PDLNavigationControllerStatusBar

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegateProvider = ^UIViewController * _Nonnull(UIViewController * _Nonnull viewController) {
            return ((UINavigationController *)viewController).topViewController;
        };
    }
    return self;
}

@end

@interface PDLTabBarControllerStatusBar : PDLViewControllerStatusBar

@end

@implementation PDLTabBarControllerStatusBar

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegateProvider = ^UIViewController * _Nonnull(UIViewController * _Nonnull viewController) {
            return ((UITabBarController *)viewController).selectedViewController;
        };
    }
    return self;
}

@end

#pragma mark - Categories

@implementation UIViewController (PDLStatusBar)

+ (Class)pdl_statusBarClass {
    return [PDLViewControllerStatusBar class];
}

- (PDLViewControllerStatusBar *)pdl_statusBar {
    static void *PDLViewControllerStatusBarKey = &PDLViewControllerStatusBarKey;
    PDLViewControllerStatusBar *statusBar = objc_getAssociatedObject(self, PDLViewControllerStatusBarKey);
    if (!statusBar) {
        statusBar = [[[self.class pdl_statusBarClass] alloc] init];
        objc_setAssociatedObject(self, PDLViewControllerStatusBarKey, statusBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return statusBar;
}

@end

@implementation UINavigationController (PDLStatusBar)

+ (Class)pdl_statusBarClass {
    return [PDLNavigationControllerStatusBar class];
}

@end

@implementation UITabBarController (PDLStatusBar)

+ (Class)pdl_statusBarClass {
    return [PDLTabBarControllerStatusBar class];
}

@end
