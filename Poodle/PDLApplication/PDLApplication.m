//
//  PDLApplication.m
//  Poodle
//
//  Created by Poodle on 2021/3/21.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLApplication.h"
#import "NSObject+PDLImplementationInterceptor.h"
#import "CAAnimation+PDLExtension.h"
#import "NSMapTable+PDLExtension.h"

@implementation PDLApplication

static NSDictionary *_launchOptions;
static void(^_developmentToolInitializer)(UIWindow *) = nil;
static CALayer *(^_eventFeedbackLayerInitializer)(CALayer *(^defaultInitializer)(UITouch *), UITouch *touch) = nil;
static UIWindow *_developmentToolWindow = nil;
static __weak UIWindow *_previousKeyWindow = nil;
static BOOL(^_developmentToolAction)(void) = nil;
static NSString *_developmentToolVersion = nil;
static NSString *_developmentToolIdentifier = nil;

+ (void)registerEventFeedbackLayerInitializer:(CALayer *(^)(CALayer * (^)(UITouch *), UITouch *))initializer {
    _eventFeedbackLayerInitializer = [initializer copy];
}

+ (void)registerDevelopmentToolWindowInitializer:(void(^)(UIWindow *window))initializer {
    _developmentToolInitializer = [initializer copy];
}

+ (UIWindow *)developmentToolWindow {
    return _developmentToolWindow;
}

+ (void)showDevelopmentToolWindow:(BOOL)animated completion:(void (^)(UIWindow * _Nonnull))completion {
    if (_developmentToolWindow) {
        if (completion) {
            completion(_developmentToolWindow);
        }
        return;
    }

    UIWindow *window = nil;
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 13) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        UIWindowScene *scene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.anyObject;
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            window = [[UIWindow alloc] initWithWindowScene:scene];
        }
#pragma clang diagnostic pop
    }

    if (!window) {
        window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    window.backgroundColor = [UIColor clearColor];
    window.windowLevel = UIWindowLevelNormal + 1;
    window.alpha = 0.95;

    if (_developmentToolInitializer) {
        _developmentToolInitializer(window);
    }

    _developmentToolWindow = window;
    _previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    [_developmentToolWindow makeKeyAndVisible];

    if (animated) {
        CGRect toFrame = window.frame;
        CGRect fromFrame = toFrame;
        fromFrame.origin.y = fromFrame.size.height;
        window.frame = fromFrame;
        [UIView animateWithDuration:[CATransaction animationDuration] animations:^{
            window.frame = toFrame;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(window);
            }
        }];
    } else {
        if (completion) {
            completion(window);
        }
    }
}

+ (void)hideDevelopmentToolWindow:(BOOL)animated completion:(void (^ _Nullable)(UIWindow * _Nullable))completion {
    UIWindow *window = _developmentToolWindow;
    if (!window) {
        if (completion) {
            completion(nil);
        }
        return;
    }

    void(^action)(void) = ^{
        _developmentToolWindow.hidden = YES;
        _developmentToolWindow = nil;
        [_previousKeyWindow makeKeyWindow];
        _previousKeyWindow = nil;
        if (completion) {
            completion(window);
        }
    };
    if (animated) {
        CGRect toFrame = window.frame;
        toFrame.origin.y = toFrame.size.height;
        [UIView animateWithDuration:[CATransaction animationDuration] animations:^{
            window.frame = toFrame;
        } completion:^(BOOL finished) {
            action();
        }];
    } else {
        action();
    }
}

+ (void)registerVersion:(NSString *)version {
    _developmentToolVersion = [version copy];
}

+ (void)registerIdentifier:(NSString *)identifier {
    _developmentToolIdentifier = [identifier copy];
}

+ (void)registerDevelopmentToolAction:(BOOL(^)(void))action {
    _developmentToolAction = [action copy];
}

#pragma mark -

+ (BOOL)parseUrl:(NSURL *)url safeMode:(BOOL *)safeMode {
    if (![url.host isEqualToString:@"debug"]) {
        return NO;
    }

    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    BOOL ret = NO;
    BOOL sm = NO;
    for (NSURLQueryItem *queryItem in components.queryItems) {
        if ([queryItem.name isEqualToString:@"version"]) {
            if ([_developmentToolVersion.lowercaseString isEqualToString:queryItem.value.lowercaseString]) {
                ret = YES;
            }
        }
        if ([queryItem.name isEqualToString:@"id"]) {
            if ([_developmentToolIdentifier.lowercaseString isEqualToString:queryItem.value.lowercaseString]) {
                ret = YES;
            }
        }
        if ([queryItem.name isEqualToString:@"safemode"]) {
            sm = queryItem.value.boolValue;
        }
    }

    if (safeMode) {
        *safeMode = sm;
    }

    return ret;
}

+ (void)tap {
    [self showDevelopmentToolWindow:YES completion:nil];
}

+ (UIWindow *)window:(BOOL)isSafeMode {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIViewController *rootViewController = [[UIViewController alloc] init];
    window.rootViewController = rootViewController;
    UIView *view = rootViewController.view;
    view.backgroundColor = [UIColor whiteColor];
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
    if (isSafeMode) {
        view.backgroundColor = [UIColor blackColor];
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGFloat bottomMargin = 0;
        if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
            bottomMargin = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets.bottom;
#pragma clang diagnostic pop
        }
        CGFloat margin = 5;
        for (NSInteger i = 0; i < 4; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
            label.font = [UIFont systemFontOfSize:10];
            label.textColor = [UIColor whiteColor];
            label.text = @"SAFEMODE";
            [label sizeToFit];
            [view addSubview:label];
            switch (i) {
                case 0:
                    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
                    label.frame = CGRectMake(margin, statusBarHeight, label.bounds.size.width, label.bounds.size.height);
                    break;
                case 1:
                    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
                    label.frame = CGRectMake(view.bounds.size.width - label.bounds.size.width - margin, statusBarHeight, label.bounds.size.width, label.bounds.size.height);
                    break;
                case 2:
                    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
                    label.frame = CGRectMake(margin, view.bounds.size.height - label.bounds.size.height - bottomMargin, label.bounds.size.width, label.bounds.size.height);
                    break;
                case 3:
                    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
                    label.frame = CGRectMake(view.bounds.size.width - label.bounds.size.width - margin, view.bounds.size.height - label.bounds.size.height - bottomMargin, label.bounds.size.width, label.bounds.size.height);
                    break;

                default:
                    break;
            }
        }
    }
    return window;
}

+ (void)setMainWindow:(UIWindow *)mainWindow {
    static UIWindow *_mainWindow = nil;
    _mainWindow = mainWindow;
}

#pragma mark -

+ (void)exitApplication {
    [UIView animateWithDuration:[CATransaction animationDuration] animations:^{
        NSArray *windows = [UIApplication sharedApplication].windows;
        for (UIWindow *window in windows) {
            window.alpha = 0;
        }
    } completion:^(BOOL finished) {
        [UIApplication sharedApplication].statusBarHidden = YES;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self terminate];
    });
}

+ (void)terminate {
    volatile char s[21];
    s[0] = '_';
    s[1] = 't';
    s[2] = 'e';
    s[3] = 'r';
    s[4] = 'm';
    s[5] = 'i';
    s[6] = 'n';
    s[7] = 'a';
    s[8] = 't';
    s[9] = 'e';
    s[10] = 'W';
    s[11] = 'i';
    s[12] = 't';
    s[13] = 'h';
    s[14] = 'S';
    s[15] = 't';
    s[16] = 'a';
    s[17] = 't';
    s[18] = 'u';
    s[19] = 's';
    s[20] = '\0';
    SEL sel = sel_registerName((const char *)s);
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:sel]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            exit(0);
        });
        ((void(*)(id, SEL, NSInteger))objc_msgSend)(application, sel, 0);
    } else {
        exit(0);
    }
}

#pragma mark -

+ (BOOL)isLaunchOptionsSafeMode:(NSDictionary *)launchOptions {
    UIApplicationShortcutItem *shortcutItem = launchOptions[UIApplicationLaunchOptionsShortcutItemKey];
    if ([shortcutItem.type isEqualToString:@"safemode"]) {
        return YES;
    }

    NSURL *url = launchOptions[UIApplicationLaunchOptionsURLKey];
    BOOL safeMode = NO;
    [self parseUrl:url safeMode:&safeMode];
    if (safeMode) {
        return YES;
    }

    return NO;
}

static BOOL applicationDidFinishLaunchingWithOptions(__unsafe_unretained id <UIApplicationDelegate> self, SEL _cmd, __unsafe_unretained UIApplication *application, NSDictionary *launchOptions) {
    PDLImplementationInterceptorRecover(_cmd);
    BOOL succeeded = [PDLApplication application:application didFinishLaunchingWithOptions:launchOptions];
    if (succeeded) {
        return YES;
    }

    return ((typeof(&applicationDidFinishLaunchingWithOptions))_imp)(self, _cmd, application, launchOptions);
}

static BOOL applicationOpenURLOptions(__unsafe_unretained id <UIApplicationDelegate> self, SEL _cmd, __unsafe_unretained UIApplication *application, __unsafe_unretained NSURL *url, __unsafe_unretained NSDictionary<UIApplicationOpenURLOptionsKey,id> *options) {
    PDLImplementationInterceptorRecover(_cmd);
    BOOL ret = applicationOpenURLOptionsAdded(self, _cmd, application, url, options);
    if (_imp) {
        ret = ((typeof(&applicationOpenURLOptions))_imp)(self, _cmd, application, url, options);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        ret = ((BOOL (*)(struct objc_super *, SEL, __unsafe_unretained UIApplication *, __unsafe_unretained NSURL *, __unsafe_unretained NSDictionary<UIApplicationOpenURLOptionsKey,id> *))objc_msgSendSuper)(&su, _cmd, application, url, options);
    }
    return ret;
}

static BOOL applicationOpenURLOptionsAdded(__unsafe_unretained id <UIApplicationDelegate> self, SEL _cmd, __unsafe_unretained UIApplication *application, __unsafe_unretained NSURL *url, __unsafe_unretained NSDictionary<UIApplicationOpenURLOptionsKey,id> *options) {
    return [PDLApplication handleUrl:url];
}

static void applicationPerformActionForShortcutItemCompletionHandler(__unsafe_unretained id <UIApplicationDelegate> self, SEL _cmd, __unsafe_unretained UIApplication *application, __unsafe_unretained UIApplicationShortcutItem *shortcutItem, void (^completionHandler)(BOOL)) {
    PDLImplementationInterceptorRecover(_cmd);
    applicationPerformActionForShortcutItemCompletionHandlerAdded(self, _cmd, application, shortcutItem, completionHandler);
    if (_imp) {
        ((typeof(&applicationPerformActionForShortcutItemCompletionHandler))_imp)(self, _cmd, application, shortcutItem, completionHandler);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        ((BOOL (*)(struct objc_super *, SEL, __unsafe_unretained UIApplication *, __unsafe_unretained UIApplicationShortcutItem *, void (^)(BOOL)))objc_msgSendSuper)(&su, _cmd, application, shortcutItem, completionHandler);
    }
}

static void applicationPerformActionForShortcutItemCompletionHandlerAdded(__unsafe_unretained id <UIApplicationDelegate> self, SEL _cmd, __unsafe_unretained UIApplication *application, __unsafe_unretained UIApplicationShortcutItem *shortcutItem, void (^completionHandler)(BOOL)) {
    [PDLApplication handleShortcutItem:shortcutItem];
}

static BOOL applicationOpenURLSourceApplicationAnnotation(__unsafe_unretained id <UIApplicationDelegate> self, SEL _cmd, __unsafe_unretained UIApplication *application, __unsafe_unretained NSURL *url, __unsafe_unretained NSString *sourceApplication, __unsafe_unretained id annotation) {
    PDLImplementationInterceptorRecover(_cmd);
    BOOL ret = [PDLApplication handleUrl:url];
    if (_imp) {
        ret = ((typeof(&applicationOpenURLSourceApplicationAnnotation))_imp)(self, _cmd, application, url, sourceApplication, annotation);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        ret = ((BOOL (*)(struct objc_super *, SEL, __unsafe_unretained UIApplication *, __unsafe_unretained NSURL *, __unsafe_unretained NSString *, __unsafe_unretained id))objc_msgSendSuper)(&su, _cmd, application, url, sourceApplication, annotation);
    }
    return ret;
}

static BOOL applicationHandleOpenURL(__unsafe_unretained id <UIApplicationDelegate> self, SEL _cmd, __unsafe_unretained UIApplication *application, __unsafe_unretained NSURL *url) {
    PDLImplementationInterceptorRecover(_cmd);
    BOOL ret = [PDLApplication handleUrl:url];
    if (_imp) {
        ret = ((typeof(&applicationHandleOpenURL))_imp)(self, _cmd, application, url);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        ret = ((BOOL (*)(struct objc_super *, SEL, __unsafe_unretained UIApplication *, __unsafe_unretained NSURL *))objc_msgSendSuper)(&su, _cmd, application, url);
    }
    return ret;
}

+ (void)setApplicationDelegate:(id<UIApplicationDelegate>)delegate {
    if (delegate == nil) {
        return;
    }

    Class aClass = object_getClass(delegate);
    [aClass pdl_interceptSelector:@selector(application:didFinishLaunchingWithOptions:) withInterceptorImplementation:(IMP)&applicationDidFinishLaunchingWithOptions];
    BOOL ret = [aClass pdl_interceptSelector:@selector(application:openURL:options:) withInterceptorImplementation:(IMP)&applicationOpenURLOptions isStructRet:nil addIfNotExistent:YES data:NULL];
    if (!ret) {
        ret = [aClass pdl_interceptSelector:@selector(application:openURL:sourceApplication:annotation:) withInterceptorImplementation:(IMP)&applicationOpenURLSourceApplicationAnnotation isStructRet:nil addIfNotExistent:YES data:NULL];
    }
    if (!ret) {
        ret = [aClass pdl_interceptSelector:@selector(application:handleOpenURL:) withInterceptorImplementation:(IMP)&applicationHandleOpenURL isStructRet:nil addIfNotExistent:YES data:NULL];
    }
    if (!ret) {
        ret = class_addMethod(aClass, @selector(application:openURL:options:), (IMP)&applicationOpenURLOptionsAdded, NULL);
    }

    ret = [aClass pdl_interceptSelector:@selector(application:performActionForShortcutItem:completionHandler:) withInterceptorImplementation:(IMP)&applicationPerformActionForShortcutItemCompletionHandler isStructRet:nil addIfNotExistent:YES data:NULL];
    if (!ret) {
        ret = class_addMethod(aClass, @selector(application:performActionForShortcutItem:completionHandler:), (IMP)&applicationPerformActionForShortcutItemCompletionHandlerAdded, NULL);
    }
}

static void applicationSetDelegate(__unsafe_unretained UIApplication *self, SEL _cmd, id <UIApplicationDelegate> delegate) {
    PDLImplementationInterceptorRecover(_cmd);
    [PDLApplication setApplicationDelegate:delegate];
    ((typeof(&applicationSetDelegate))_imp)(self, _cmd, delegate);

    if (self.shortcutItems.count == 0) {
        self.shortcutItems = @[];
    }
}

static void sceneOpenURLContextsAdded(__unsafe_unretained id self, SEL _cmd, id scene, NSSet *openURLContexts) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
    for (UIOpenURLContext *context in openURLContexts) {
        [PDLApplication handleUrl:context.URL];
    }
#pragma clang diagnostic pop
}

static void sceneOpenURLContexts(__unsafe_unretained id self, SEL _cmd, id scene, NSSet *openURLContexts) {
    PDLImplementationInterceptorRecover(_cmd);
    sceneOpenURLContextsAdded(self, _cmd, scene, openURLContexts);
    if (_imp) {
        ((typeof(&sceneOpenURLContexts))_imp)(self, _cmd, scene, openURLContexts);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        ((BOOL (*)(struct objc_super *, SEL, id, NSSet *))objc_msgSendSuper)(&su, _cmd, scene, openURLContexts);
    }
}

static void windowScenePerformActionForShortcutItemCompletionHandler(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id windowScene, __unsafe_unretained UIApplicationShortcutItem *shortcutItem, void (^completionHandler)(BOOL)) {
    PDLImplementationInterceptorRecover(_cmd);
    windowScenePerformActionForShortcutItemCompletionHandlerAdded(self, _cmd, windowScene, shortcutItem, completionHandler);
    if (_imp) {
        ((typeof(&windowScenePerformActionForShortcutItemCompletionHandler))_imp)(self, _cmd, windowScene, shortcutItem, completionHandler);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        ((void (*)(struct objc_super *, SEL, id, __unsafe_unretained UIApplicationShortcutItem *, void(^)(BOOL)))objc_msgSendSuper)(&su, _cmd, windowScene, shortcutItem, completionHandler);
    }
}

static void windowScenePerformActionForShortcutItemCompletionHandlerAdded(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id windowScene, __unsafe_unretained UIApplicationShortcutItem *shortcutItem, void (^completionHandler)(BOOL)) {
    [PDLApplication handleShortcutItem:shortcutItem];
}

static void sceneWillConnectToSessionOptions(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id scene, __unsafe_unretained id session, id options) {
    PDLImplementationInterceptorRecover(_cmd);
    sceneWillConnectToSessionOptionsAdded(self, _cmd, scene, session, options);
    if (_imp) {
        ((typeof(&sceneWillConnectToSessionOptions))_imp)(self, _cmd, scene, session, options);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        ((void (*)(struct objc_super *, SEL, id, id, id))objc_msgSendSuper)(&su, _cmd, scene, session, options);
    }
}

static void sceneWillConnectToSessionOptionsAdded(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id scene, __unsafe_unretained id session, id options) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
    UISceneConnectionOptions *op = options;
    BOOL isSafeMode = [op.shortcutItem.type isEqualToString:@"safemode"];
    if (isSafeMode && PDLApplicationSafemodeEnabled) {
        UIWindowScene *windowScene = scene;
        if ([windowScene isKindOfClass:[UIWindowScene class]]) {
            UIWindow *sceneWindow = windowScene.windows.firstObject;
            UIWindow *window = [PDLApplication window:isSafeMode];
            [PDLApplication setMainWindow:sceneWindow];
            sceneWindow.rootViewController = window.rootViewController;
        }
    }
#pragma clang diagnostic pop
}

static void applicationSetShortcutItems(__unsafe_unretained UIApplication *self, SEL _cmd, NSArray *shortcutItems) {
    PDLImplementationInterceptorRecover(_cmd);
    UIApplicationShortcutItem *safeModeShortcutItem = [PDLApplication safeModeShortcutItem];
    NSArray *items = shortcutItems ?: @[];
    items = [items arrayByAddingObject:safeModeShortcutItem];
    ((typeof(&applicationSetShortcutItems))_imp)(self, _cmd, items);
}

+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _launchOptions = launchOptions;

    BOOL isSafeMode = [PDLApplication isLaunchOptionsSafeMode:launchOptions];
    if (isSafeMode && PDLApplicationSafemodeEnabled) {
        UIWindow *window = [PDLApplication window:isSafeMode];
        [PDLApplication setMainWindow:window];
        [window makeKeyAndVisible];
        return YES;
    }
    return NO;
}

+ (BOOL)handleUrl:(NSURL *)url {
    BOOL safeMode = NO;
    BOOL ret = [self parseUrl:url safeMode:&safeMode];
    if (ret) {
        if (!safeMode && _developmentToolAction) {
            BOOL handled = _developmentToolAction();
            if (!handled) {
                if (!_developmentToolWindow) {
                    [self showDevelopmentToolWindow:YES completion:nil];
                }
            }
        } else {
            if (!_developmentToolWindow) {
                [self showDevelopmentToolWindow:YES completion:nil];
            }
        }
    }
    return ret;
}

+ (void)handleShortcutItem:(UIApplicationShortcutItem *)shortcutItem {
    if ([shortcutItem.type isEqualToString:@"safemode"]) {
        if (_developmentToolAction) {
            BOOL handled = _developmentToolAction();
            if (!handled) {
                if (!_developmentToolWindow) {
                    [self showDevelopmentToolWindow:YES completion:nil];
                }
            }
        } else {
            if (!_developmentToolWindow) {
                [self showDevelopmentToolWindow:YES completion:nil];
            }
        }
    }
}

+ (UIApplicationShortcutItem *)safeModeShortcutItem {
    UIApplicationShortcutItem *safeModeShortcutItem = [[UIApplicationShortcutItem alloc] initWithType:@"safemode" localizedTitle:@"SAFEMODE" localizedSubtitle:nil icon:nil userInfo:nil];
    return safeModeShortcutItem;
}

+ (BOOL)enableDevelopmentTool {
    static BOOL enabled = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        enabled = [UIApplication pdl_interceptSelector:@selector(setDelegate:) withInterceptorImplementation:(IMP)&applicationSetDelegate];
        if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 13) {
            NSDictionary *infoDictionary = [NSBundle mainBundle].infoDictionary;
            NSDictionary *sceneManifest = infoDictionary[@"UIApplicationSceneManifest"];
            NSDictionary *sceneConfigurations = sceneManifest[@"UISceneConfigurations"];
            NSArray *configurations = sceneConfigurations[@"UIWindowSceneSessionRoleApplication"];
            NSMutableSet *classNames = [NSMutableSet set];
            for (NSDictionary *configuration in configurations) {
                NSString *className = configuration[@"UISceneDelegateClassName"];
                if (!className) {
                    continue;
                }
                [classNames addObject:className];
            }
            if (classNames.count > 0) {
                for (NSString *className in classNames) {
                    Class aClass = NSClassFromString(className);
                    SEL sel = @selector(scene:openURLContexts:);
                    BOOL ret = [aClass pdl_interceptSelector:sel withInterceptorImplementation:(IMP)&sceneOpenURLContexts isStructRet:nil addIfNotExistent:YES data:NULL];
                    if (!ret) {
                        ret = class_addMethod(aClass, sel, (IMP)&sceneOpenURLContextsAdded, NULL);
                    }

                    sel = @selector(windowScene:performActionForShortcutItem:completionHandler:);
                    ret = [aClass pdl_interceptSelector:sel withInterceptorImplementation:(IMP)&windowScenePerformActionForShortcutItemCompletionHandler isStructRet:nil addIfNotExistent:YES data:NULL];
                    if (!ret) {
                        ret = class_addMethod(aClass, sel, (IMP)&windowScenePerformActionForShortcutItemCompletionHandlerAdded, NULL);
                    }

                    sel = @selector(scene:willConnectToSession:options:);
                    ret = [aClass pdl_interceptSelector:sel withInterceptorImplementation:(IMP)&sceneWillConnectToSessionOptions isStructRet:nil addIfNotExistent:YES data:NULL];
                    if (!ret) {
                        ret = class_addMethod(aClass, sel, (IMP)&sceneWillConnectToSessionOptionsAdded, NULL);
                    }
                }
            }
        }
    });
    return enabled;
}

static BOOL PDLApplicationSafemodeEnabled = NO;
+ (BOOL)enableSafemode {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL ret = [UIApplication pdl_interceptSelector:@selector(setShortcutItems:) withInterceptorImplementation:(IMP)&applicationSetShortcutItems];
        PDLApplicationSafemodeEnabled = ret;
    });
    return PDLApplicationSafemodeEnabled;
}

#pragma mark -

static BOOL PDLApplicationEventFeedbackEnabled = NO;
static void(^_shakeAction)(void) = nil;

static NSMapTable *pdl_touchColors(void) {
    static NSMapTable *touchColors = nil;
    if (!touchColors) {
        touchColors = [NSMapTable weakToStrongObjectsMapTable];
    }
    return touchColors;
}

static NSMutableArray *pdl_colors(void) {
    static NSMutableArray *colors = nil;
    if (!colors) {
        colors = [NSMutableArray array];
        [colors addObject:[UIColor redColor]];
        [colors addObject:[UIColor orangeColor]];
        [colors addObject:[UIColor yellowColor]];
        [colors addObject:[UIColor greenColor]];
        [colors addObject:[UIColor cyanColor]];
        [colors addObject:[UIColor blueColor]];
        [colors addObject:[UIColor purpleColor]];
    }
    return colors;
}

static UIColor *pdl_colorForTouch(UITouch *touch) {
    NSMapTable *touchColors = pdl_touchColors();
    UIColor *color = touchColors[touch];
    NSMutableArray *colors = pdl_colors();
    if (touch.phase == UITouchPhaseBegan) {
        if (!color) {
            NSInteger index = 0;
            color = colors[index];
            [colors removeObjectAtIndex:index];
            touchColors[touch] = color;
        }
    } else {
        if ((touch.phase == UITouchPhaseEnded) || (touch.phase == UITouchPhaseCancelled)) {
            if (color) {
                touchColors[touch] = nil;
                [colors addObject:color];
            }
        }
    }
    return color;
}

static void pdl_handleMotion(__unsafe_unretained UIEvent *event) {
    if (event.subtype != UIEventSubtypeMotionShake) {
        return;
    }

    SEL sel = sel_registerName("shakeState");
    int state = ((int(*)(id, SEL))objc_msgSend)(event, sel);
    if (state != 0) {
        return;
    }

    if (_shakeAction) {
        _shakeAction();
    }
}

static void pdl_handleTouches(__unsafe_unretained UIEvent *event) {
    if (!PDLApplicationEventFeedbackEnabled) {
        return;
    }

    CALayer *(^defaultInitializer)(UITouch *) = ^CALayer *(UITouch *touch) {
        CGFloat length = 20;
        UIColor *color = pdl_colorForTouch(touch);
        CALayer *layer = [[CALayer alloc] init];
        layer.bounds = CGRectMake(0, 0, length * 2, length * 2);
        layer.borderColor = color.CGColor;
        layer.borderWidth = 2;
        layer.cornerRadius = length;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOffset = CGSizeZero;
        layer.shadowRadius = 1;
        layer.shadowOpacity = 1;

        layer.transform = CATransform3DMakeScale(0, 0, 1);

        NSTimeInterval duration = 1;

        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.duration = duration;
        group.fillMode = kCAFillModeForwards;
        group.removedOnCompletion = NO;

        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scale.fromValue = @(0);
        scale.toValue = @(1);

        CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacity.fromValue = @(1);
        opacity.toValue = @(0);

        group.animations = @[scale, opacity];
        group.pdl_didStopAction = ^(CAAnimation *animation, BOOL finished) {
            [layer removeFromSuperlayer];
        };

        [layer addAnimation:group forKey:nil];
        return layer;
    };

    NSSet *allTouches = [event allTouches];
    for (UITouch *touch in allTouches) {
        UIWindow *window = touch.window;
        CGPoint locationInWindow = [touch locationInView:window];
        CALayer *rootLayer = [window valueForKeyPath:@"_rootLayer"];

        CALayer *layer = nil;
        if (_eventFeedbackLayerInitializer) {
            layer = _eventFeedbackLayerInitializer(defaultInitializer, touch);
        } else {
            layer = defaultInitializer(touch);
        }
        if (layer) {
            if (layer.superlayer != rootLayer) {
                [rootLayer addSublayer:layer];
            }

            CGPoint position = [window.layer convertPoint:locationInWindow toLayer:rootLayer];
            layer.position = position;
            [layer removeAnimationForKey:@"position"];
        }
    }
}

static void pdl_handleEvent(__unsafe_unretained UIEvent *event) {
    if ([event isKindOfClass:objc_getClass("UIMotionEvent")]) {
        pdl_handleMotion(event);
    } else if ([event isKindOfClass:objc_getClass("UITouchesEvent")]) {
        pdl_handleTouches(event);
    } // UIPhysicalKeyboardEvent
}

static void applicationSendEvent(__unsafe_unretained UIApplication *self, SEL _cmd, __unsafe_unretained UIEvent *event) {
    PDLImplementationInterceptorRecover(_cmd);
    ((typeof(&applicationSendEvent))_imp)(self, _cmd, event);
    pdl_handleEvent(event);
}

static void pdl_prepareSendEvent(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __unused BOOL ret = [UIApplication pdl_interceptSelector:@selector(sendEvent:) withInterceptorImplementation:(IMP)&applicationSendEvent];
    });
}

+ (NSDictionary *)launchOptions {
    return _launchOptions;
}

+ (BOOL)eventFeedbackEnabled {
    return PDLApplicationEventFeedbackEnabled;
}

+ (void)setEventFeedbackEnabled:(BOOL)eventFeedbackEnabled {
    if (eventFeedbackEnabled) {
        pdl_prepareSendEvent();
    }
    PDLApplicationEventFeedbackEnabled = eventFeedbackEnabled;
}

+ (BOOL)registerShakeAction:(void(^)(void))shakeAction {
    if (![objc_getClass("UIMotionEvent") instancesRespondToSelector:sel_registerName("shakeState")]) {
        return NO;
    }

    _shakeAction = shakeAction;
    if (shakeAction) {
        pdl_prepareSendEvent();
    }
    return YES;
}

@end
