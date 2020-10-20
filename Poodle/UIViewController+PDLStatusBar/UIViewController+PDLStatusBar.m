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

    if (_imp) {
        ret = ((typeof(&PDLViewControllerStatusBarPreferredStatusBarStyle))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        ret = ((UIStatusBarStyle(*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
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

    if (_imp) {
        ret = ((typeof(&PDLViewControllerStatusBarPrefersStatusBarHidden))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        ret = ((BOOL(*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
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

    if (_imp) {
        ret = ((typeof(&PDLViewControllerStatusBarPreferredStatusBarUpdateAnimation))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        ret = ((UIStatusBarAnimation(*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);

    }
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

+ (NSUInteger)pdl_statusBarEnable {
    __unused NSUInteger count = 0;
    Class aClass = self;
    BOOL ret = NO;
    ret = [aClass pdl_interceptSelector:@selector(preferredStatusBarStyle) withInterceptorImplementation:(IMP)&PDLViewControllerStatusBarPreferredStatusBarStyle isStructRet:@(NO) addIfNotExistent:YES data:NULL];
    if (ret) {
        count++;
    }

    ret = [aClass pdl_interceptSelector:@selector(prefersStatusBarHidden) withInterceptorImplementation:(IMP)&PDLViewControllerStatusBarPrefersStatusBarHidden isStructRet:@(NO) addIfNotExistent:YES data:NULL];
    if (ret) {
        count++;
    }

    ret = [aClass pdl_interceptSelector:@selector(preferredStatusBarUpdateAnimation) withInterceptorImplementation:(IMP)&PDLViewControllerStatusBarPreferredStatusBarUpdateAnimation  isStructRet:@(NO) addIfNotExistent:YES data:NULL];
    if (ret) {
        count++;
    }
    return count;
}

+ (Class)pdl_statusBarClass {
    return [PDLViewControllerStatusBar class];
}

- (PDLViewControllerStatusBar *)pdl_statusBar {
    static void *PDLViewControllerStatusBarKey = &PDLViewControllerStatusBarKey;
    PDLViewControllerStatusBar *statusBar = objc_getAssociatedObject(self, PDLViewControllerStatusBarKey);
    if (!statusBar) {
        statusBar = [[self.class.pdl_statusBarClass alloc] init];
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
