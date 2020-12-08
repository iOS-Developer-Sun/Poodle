//
//  UIViewController+PDLExtension.m
//  Poodle
//
//  Created by Poodle on 2020/12/8.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "UIViewController+PDLExtension.h"
#import "NSObject+PDLImplementationInterceptor.h"

typedef NS_ENUM(NSUInteger, PDLViewControllerExtensionControllerType) {
    PDLViewControllerExtensionControllerTypeViewWillAppear,
    PDLViewControllerExtensionControllerTypeViewWillDisappear,
    PDLViewControllerExtensionControllerTypeViewDidAppear,
    PDLViewControllerExtensionControllerTypeViewDidDisappear,
};

@interface PDLViewControllerExtensionActions : NSObject <PDLViewControllerExtensionActions>

@property (nonatomic, strong, readonly) NSMapTable *actions;

@end

@implementation PDLViewControllerExtensionActions

- (instancetype)init {
    self = [super init];
    if (self) {
        _actions = [NSMapTable weakToStrongObjectsMapTable];
    }
    return self;
}

- (void)act:(UIViewController *)viewController {
    NSMapTable *actions = _actions;
    for (id key in actions) {
        void(^action)(__kindof UIViewController *, id key) = [actions objectForKey:key];
        action(viewController, key);
    }
}

- (void(^)(__kindof UIViewController *))objectForKeyedSubscript:(id)key {
    return [self.actions objectForKey:key];
}

- (void)setObject:(void (^)(__kindof UIViewController * _Nonnull, id _Nonnull))obj forKeyedSubscript:(id)key {
    [self.actions setObject:obj forKey:key];
}

@end

@interface PDLViewControllerExtensionController : NSObject <PDLViewControllerExtensionController>

@property (nonatomic, strong, readonly) NSDictionary *actionsMap;

@end

@implementation PDLViewControllerExtensionController

@synthesize viewWillAppearActions = _viewWillAppearActions;
@synthesize viewWillDisappearActions = _viewWillDisappearActions;
@synthesize viewDidAppearActions = _viewDidAppearActions;
@synthesize viewDidDisappearActions = _viewDidDisappearActions;

- (instancetype)init {
    self = [super init];
    if (self) {
        _viewWillAppearActions = [[PDLViewControllerExtensionActions alloc] init];
        _viewWillDisappearActions = [[PDLViewControllerExtensionActions alloc] init];
        _viewDidAppearActions = [[PDLViewControllerExtensionActions alloc] init];
        _viewDidDisappearActions = [[PDLViewControllerExtensionActions alloc] init];

        _actionsMap = @{
            @(PDLViewControllerExtensionControllerTypeViewWillAppear) : _viewWillAppearActions,
            @(PDLViewControllerExtensionControllerTypeViewWillDisappear) : _viewWillDisappearActions,
            @(PDLViewControllerExtensionControllerTypeViewDidAppear) : _viewDidAppearActions,
            @(PDLViewControllerExtensionControllerTypeViewDidDisappear) : _viewDidDisappearActions,
        };
    }
    return self;
}

- (void)act:(UIViewController *)viewController type:(PDLViewControllerExtensionControllerType)type {
    PDLViewControllerExtensionActions *actions = self.actionsMap[@(type)];
    [actions act:viewController];
}

@end

@implementation UIViewController (PDLExtension)

- (id<PDLViewControllerExtensionController>)pdl_extensionController {
    id<PDLViewControllerExtensionController> controller = objc_getAssociatedObject(self, &PDLViewControllerDoAppear);
    if (!controller) {
        controller = [[PDLViewControllerExtensionController alloc] init];
        objc_setAssociatedObject(self, &PDLViewControllerDoAppear, controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return controller;
}

static void PDLViewControllerDoAppear(__unsafe_unretained UIViewController *self, SEL _cmd, BOOL animated) {
    PDLImplementationInterceptorRecover(_cmd);
    ((typeof(&PDLViewControllerDoAppear))(_imp))(self, _cmd, animated);
    PDLViewControllerExtensionController *extensionController = self.pdl_extensionController;
    [extensionController act:self type:(NSInteger)_data];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL ret = YES;
        ret &= [UIViewController pdl_interceptSelector:@selector(viewWillAppear:) withInterceptorImplementation:(IMP)&PDLViewControllerDoAppear isStructRet:@(NO) addIfNotExistent:NO data:(void *)(long)PDLViewControllerExtensionControllerTypeViewWillAppear];
        ret &= [UIViewController pdl_interceptSelector:@selector(viewWillDisappear:) withInterceptorImplementation:(IMP)&PDLViewControllerDoAppear isStructRet:@(NO) addIfNotExistent:NO data:(void *)(long)PDLViewControllerExtensionControllerTypeViewWillDisappear];
        ret &= [UIViewController pdl_interceptSelector:@selector(viewDidAppear:) withInterceptorImplementation:(IMP)&PDLViewControllerDoAppear isStructRet:@(NO) addIfNotExistent:NO data:(void *)(long)PDLViewControllerExtensionControllerTypeViewDidAppear];
        ret &= [UIViewController pdl_interceptSelector:@selector(viewDidDisappear:) withInterceptorImplementation:(IMP)&PDLViewControllerDoAppear isStructRet:@(NO) addIfNotExistent:NO data:(void *)(long)PDLViewControllerExtensionControllerTypeViewDidDisappear];
        NSAssert(ret, @"UIViewController+PDLExtension");
    });
}

@end
