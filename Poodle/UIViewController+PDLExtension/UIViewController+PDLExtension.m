//
//  UIViewController+PDLExtension.m
//  Poodle
//
//  Created by Poodle on 2020/12/8.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "UIViewController+PDLExtension.h"
#import "NSObject+PDLImplementationInterceptor.h"
#import "NSMapTable+PDLExtension.h"

typedef NS_ENUM(NSUInteger, PDLViewControllerExtensionControllerType) {
    PDLViewControllerExtensionControllerTypeViewWillAppear,
    PDLViewControllerExtensionControllerTypeViewWillDisappear,
    PDLViewControllerExtensionControllerTypeViewDidAppear,
    PDLViewControllerExtensionControllerTypeViewDidDisappear,
};

@interface PDLViewControllerExtensionActions : NSObject <PDLViewControllerExtensionActions>

@property (nonatomic, strong, readonly) NSMapTable *actions;
@property (nonatomic, strong, readonly) NSMapTable *weakActions;

@end

@implementation PDLViewControllerExtensionActions

- (instancetype)init {
    self = [super init];
    if (self) {
        _actions = [NSMapTable strongToStrongObjectsMapTable];
        _weakActions = [NSMapTable weakToStrongObjectsMapTable];
    }
    return self;
}

- (void)act:(UIViewController *)viewController {
    NSMapTable *actions = _actions;
    for (id key in actions) {
        void(^action)(__kindof UIViewController *, id key) = actions[key];
        action(viewController, key);
    }

    NSMapTable *weakActions = _weakActions;
    for (id key in weakActions) {
        void(^action)(__kindof UIViewController *, id key) = [weakActions objectForKey:key];
        action(viewController, key);
    }
}

- (void (^)(__kindof UIViewController * _Nonnull))actionForKey:(id)key {
    return self.actions[key];
}

- (void)setAction:(void (^)(__kindof UIViewController * _Nonnull, id _Nonnull))action forKey:(id)key {
    self.actions[key] = action;
}

- (void(^_Nullable)(__kindof UIViewController *))actionForWeakKey:(id)key {
    return self.weakActions[key];
}

- (void)setAction:(void(^_Nullable)(__kindof UIViewController *viewController, id key))action forWeakKey:(id)key {
    self.weakActions[key] = action;
}

@end

@interface PDLViewControllerExtensionController : NSObject <PDLViewControllerExtensionController>

@property (nonatomic, unsafe_unretained, readonly) UIViewController *viewController;
@property (nonatomic, strong, readonly) NSMutableDictionary *actionsMap;

@end

@implementation PDLViewControllerExtensionController

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
        _actionsMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id<PDLViewControllerExtensionActions>)actionsForType:(PDLViewControllerExtensionControllerType)type {
    PDLViewControllerExtensionActions *actions = self.actionsMap[@(type)];
    if (!actions) {
        actions = [[PDLViewControllerExtensionActions alloc] init];
        self.actionsMap[@(type)] = actions;
    }
    return actions;
}

- (id<PDLViewControllerExtensionActions>)viewWillAppearActions {
    return [self actionsForType:PDLViewControllerExtensionControllerTypeViewWillAppear];
}

- (id<PDLViewControllerExtensionActions>)viewWillDisappearActions {
    return [self actionsForType:PDLViewControllerExtensionControllerTypeViewWillDisappear];
}

- (id<PDLViewControllerExtensionActions>)viewDidAppearActions {
    return [self actionsForType:PDLViewControllerExtensionControllerTypeViewDidAppear];
}

- (id<PDLViewControllerExtensionActions>)viewDidDisappearActions {
    return [self actionsForType:PDLViewControllerExtensionControllerTypeViewDidDisappear];
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
        controller = [[PDLViewControllerExtensionController alloc] initWithViewController:self];
        objc_setAssociatedObject(self, &PDLViewControllerDoAppear, controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return controller;
}

static void PDLViewControllerDoAppear(__unsafe_unretained UIViewController *self, SEL _cmd, BOOL animated) {
    PDLImplementationInterceptorRecover(_cmd);
    ((typeof(&PDLViewControllerDoAppear))(_imp))(self, _cmd, animated);
    PDLViewControllerExtensionController *extensionController = objc_getAssociatedObject(self, &PDLViewControllerDoAppear);
    [extensionController act:self type:(PDLViewControllerExtensionControllerType)(long)_data];
}

+ (void)pdl_enableExtension {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL ret = YES;
        ret = ret && [UIViewController pdl_interceptSelector:@selector(viewWillAppear:) withInterceptorImplementation:(IMP)&PDLViewControllerDoAppear isStructRet:@(NO) addIfNotExistent:NO data:(void *)(long)PDLViewControllerExtensionControllerTypeViewWillAppear];
        ret = ret && [UIViewController pdl_interceptSelector:@selector(viewWillDisappear:) withInterceptorImplementation:(IMP)&PDLViewControllerDoAppear isStructRet:@(NO) addIfNotExistent:NO data:(void *)(long)PDLViewControllerExtensionControllerTypeViewWillDisappear];
        ret = ret && [UIViewController pdl_interceptSelector:@selector(viewDidAppear:) withInterceptorImplementation:(IMP)&PDLViewControllerDoAppear isStructRet:@(NO) addIfNotExistent:NO data:(void *)(long)PDLViewControllerExtensionControllerTypeViewDidAppear];
        ret = ret && [UIViewController pdl_interceptSelector:@selector(viewDidDisappear:) withInterceptorImplementation:(IMP)&PDLViewControllerDoAppear isStructRet:@(NO) addIfNotExistent:NO data:(void *)(long)PDLViewControllerExtensionControllerTypeViewDidDisappear];
        NSAssert(ret, @"UIViewController+PDLExtension");
    });
}

@end
