//
//  UIViewController+PDLRotation.m
//  Poodle
//
//  Created by Poodle on 9/5/20.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "UIViewController+PDLRotation.h"
#import <objc/runtime.h>
#import "NSObject+PDLImplementationInterceptor.h"

@interface PDLViewControllerRotation ()

@end

@implementation PDLViewControllerRotation

- (instancetype)initDefault {
    self = [super init];
    if (self) {
        ;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        PDLViewControllerRotation *defaultRotation = [self.class defaultRotation];
        _shouldAutorotate = defaultRotation.shouldAutorotate;
        _supportedInterfaceOrientations = defaultRotation.supportedInterfaceOrientations;
        _preferredInterfaceOrientationForPresentation = defaultRotation.preferredInterfaceOrientationForPresentation;
    }
    return self;
}

static UIViewController *PDLViewControllerRotationDelegate(PDLViewControllerRotation *rotation, UIViewController *viewController) {
    UIViewController *delegate = nil;
    typeof(rotation.delegateProvider) delegateProvider = rotation.delegateProvider;
    if (delegateProvider) {
        delegate = delegateProvider(viewController);
    }
    if (!delegate) {
        delegate = rotation.delegate;
    }
    return delegate;
}

static BOOL PDLViewControllerRotationShouldAutorotate(__unsafe_unretained UIViewController *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);

    BOOL ret = NO;
    PDLViewControllerRotation *rotation = self.pdl_rotation;
    UIViewController *delegate = PDLViewControllerRotationDelegate(rotation, self);
    if (delegate) {
        ret = [delegate shouldAutorotate];
        return ret;
    }

    NSNumber *shouldAutorotate = rotation.shouldAutorotate;
    if (shouldAutorotate) {
        ret = shouldAutorotate.boolValue;
        return ret;
    }

    ret = ((typeof(&PDLViewControllerRotationShouldAutorotate))_imp)(self, _cmd);
    return ret;
}

static UIInterfaceOrientationMask PDLViewControllerRotationSupportedInterfaceOrientations(__unsafe_unretained UIViewController *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);

    UIInterfaceOrientationMask ret = UIInterfaceOrientationMaskAllButUpsideDown;
    PDLViewControllerRotation *rotation = self.pdl_rotation;
    UIViewController *delegate = PDLViewControllerRotationDelegate(rotation, self);
    if (delegate) {
        ret = [delegate supportedInterfaceOrientations];
        return ret;
    }

    NSNumber *supportedInterfaceOrientations = rotation.supportedInterfaceOrientations;
    if (supportedInterfaceOrientations) {
        ret = supportedInterfaceOrientations.unsignedIntegerValue;
        return ret;
    }

    ret = ((typeof(&PDLViewControllerRotationSupportedInterfaceOrientations))_imp)(self, _cmd);
    return ret;
}

static UIInterfaceOrientation PDLViewControllerRotationPreferredInterfaceOrientationForPresentation(__unsafe_unretained UIViewController *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);

    UIInterfaceOrientation ret = UIInterfaceOrientationUnknown;
    PDLViewControllerRotation *rotation = self.pdl_rotation;
    UIViewController *delegate = PDLViewControllerRotationDelegate(rotation, self);
    if (delegate) {
        ret = [delegate preferredInterfaceOrientationForPresentation];
        return ret;
    }

    NSNumber *preferredInterfaceOrientationForPresentation = rotation.preferredInterfaceOrientationForPresentation;
    if (preferredInterfaceOrientationForPresentation) {
        ret = preferredInterfaceOrientationForPresentation.integerValue;
        return ret;
    }

    ret = ((typeof(&PDLViewControllerRotationPreferredInterfaceOrientationForPresentation))_imp)(self, _cmd);
    return ret;
}

+ (instancetype)defaultRotation {
    static id defaultRotation = nil;
    if (!defaultRotation) {
        defaultRotation = [[self alloc] initDefault];
    }
    return defaultRotation;
}

+ (NSUInteger)enableClass:(Class)aClass {
    __unused NSUInteger count = 0;
    BOOL ret = NO;
    ret = [aClass pdl_interceptSelector:@selector(shouldAutorotate) withInterceptorImplementation:(IMP)&PDLViewControllerRotationShouldAutorotate];
    if (ret) {
        count++;
    }

    ret = [aClass pdl_interceptSelector:@selector(supportedInterfaceOrientations) withInterceptorImplementation:(IMP)&PDLViewControllerRotationSupportedInterfaceOrientations];
    if (ret) {
        count++;
    }

    ret = [aClass pdl_interceptSelector:@selector(preferredInterfaceOrientationForPresentation) withInterceptorImplementation:(IMP)&PDLViewControllerRotationPreferredInterfaceOrientationForPresentation];
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

@interface PDLNavigationControllerRotation : PDLViewControllerRotation

@end

@implementation PDLNavigationControllerRotation

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

@interface PDLTabBarControllerRotation : PDLViewControllerRotation

@end

@implementation PDLTabBarControllerRotation

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

@implementation UIViewController (PDLRotation)

+ (Class)pdl_rotationClass {
    return [PDLViewControllerRotation class];
}

- (PDLViewControllerRotation *)pdl_rotation {
    static void *PDLViewControllerRotationKey = &PDLViewControllerRotationKey;
    PDLViewControllerRotation *rotation = objc_getAssociatedObject(self, PDLViewControllerRotationKey);
    if (!rotation) {
        rotation = [[self.class.pdl_rotationClass alloc] init];
        objc_setAssociatedObject(self, PDLViewControllerRotationKey, rotation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return rotation;
}

@end

@implementation UINavigationController (PDLRotation)

+ (Class)pdl_rotationClass {
    return [PDLNavigationControllerRotation class];
}

@end

@implementation UITabBarController (PDLRotation)

+ (Class)pdl_rotationClass {
    return [PDLTabBarControllerRotation class];
}

@end
