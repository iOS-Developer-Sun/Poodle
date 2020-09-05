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

@implementation PDLViewControllerRotation

+ (instancetype)defaultRotation {
    static id defaultRotation = nil;
    if (!defaultRotation) {
        defaultRotation = [[self alloc] init];
    }
    return defaultRotation;
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

+ (NSUInteger)enableBaseClasses {
    NSArray *classes = @[
        [UIViewController class],
        [UINavigationController class],
        [UITabBarController class],
    ];

    NSUInteger ret = 0;
    for (Class aClass in classes) {
        ret += [self enableClass:aClass];
    }
    return ret;
}

@end

@implementation UIViewController (PDLRotation)

static void *PDLViewControllerRotationKey = &PDLViewControllerRotationKey;

- (PDLViewControllerRotation *)pdl_rotation {
    PDLViewControllerRotation *rotation = objc_getAssociatedObject(self, PDLViewControllerRotationKey);
    if (!rotation) {
        rotation = [[PDLViewControllerRotation alloc] init];
        objc_setAssociatedObject(self, PDLViewControllerRotationKey, rotation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return rotation;
}

@end
