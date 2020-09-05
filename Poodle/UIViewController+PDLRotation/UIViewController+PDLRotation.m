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

static BOOL _enabled = NO;

static UIViewController *PDLViewControllerRotationDelegate(PDLViewControllerRotation *rotation, UIViewController *viewController) {
    UIViewController *delegate = nil;
    typeof(rotation.delegateProvider) delegateProvider = rotation.delegateProvider;
    if (delegateProvider) {
        delegate = delegateProvider(viewController);
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

+ (BOOL)enabled {
    return _enabled;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = [UIViewController class];
        __unused BOOL ret = [aClass pdl_interceptSelector:@selector(shouldAutorotate) withInterceptorImplementation:(IMP)&PDLViewControllerRotationShouldAutorotate isStructRet:@(NO) addIfNotExistent:NO data:NULL];
        ret &= [aClass pdl_interceptSelector:@selector(supportedInterfaceOrientations) withInterceptorImplementation:(IMP)&PDLViewControllerRotationSupportedInterfaceOrientations isStructRet:@(NO) addIfNotExistent:NO data:NULL];
        ret &= [aClass pdl_interceptSelector:@selector(preferredPresentationStyle) withInterceptorImplementation:(IMP)&PDLViewControllerRotationPreferredInterfaceOrientationForPresentation isStructRet:@(NO) addIfNotExistent:NO data:NULL];
#ifdef DEBUG
        assert(ret);
#endif
        _enabled = ret;
    });
}

@end

@implementation UIViewController (PDLRotation)

static void *PDLViewControllerRotationKey = &PDLViewControllerRotationKey;

- (PDLViewControllerRotation *)pdl_rotation {
    if (!_enabled) {
        return nil;
    }

    PDLViewControllerRotation *rotation = objc_getAssociatedObject(self, PDLViewControllerRotationKey);
    if (!rotation) {
        rotation = [[PDLViewControllerRotation alloc] init];
        objc_setAssociatedObject(self, PDLViewControllerRotationKey, rotation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return rotation;
}

@end
