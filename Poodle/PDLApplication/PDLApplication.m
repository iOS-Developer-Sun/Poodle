//
//  PDLApplication.m
//  Poodle
//
//  Created by Poodle on 2021/3/21.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLApplication.h"
#import "NSObject+PDLImplementationInterceptor.h"

@implementation PDLApplication

static void(^_developmentToolInitializer)(UIWindow *) = nil;
static UIWindow *_developmentToolWindow = nil;
static __weak UIWindow *_previousKeyWindow = nil;
static void(^_developmentToolAction)(void) = nil;
static NSString *_developmentToolVersion = nil;
static NSString *_developmentToolIdentifier = nil;

+ (void)registerDevelopmentToolWindowInitializer:(void(^)(UIWindow *window))initializer {
    _developmentToolInitializer = [initializer copy];
}

+ (BOOL)isShowingDevelopmentToolWindow {
    return (_developmentToolWindow != nil);
}

+ (void)showDevelopmentToolWindow:(void(^ _Nullable)(UIWindow *window))completion {
    if (_developmentToolWindow) {
        if (completion) {
            completion(_developmentToolWindow);
        }
        return;
    }

    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.backgroundColor = [UIColor clearColor];
    window.windowLevel = UIWindowLevelNormal + 1;
    window.alpha = 0.95;

    if (_developmentToolInitializer) {
        _developmentToolInitializer(window);
    }

    _developmentToolWindow = window;
    _previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    [_developmentToolWindow makeKeyAndVisible];
    [UIView animateWithDuration:[CATransaction animationDuration] animations:^{
    } completion:^(BOOL finished) {
        if (completion) {
            completion(window);
        }
    }];
}

+ (void)hideDevelopmentToolWindow:(void(^ _Nullable)(UIWindow *window))completion {
    UIWindow *window = _developmentToolWindow;
    if (!window) {
        if (completion) {
            completion(nil);
        }
        return;
    }

    [UIView animateWithDuration:[CATransaction animationDuration] animations:^{
        ;
    } completion:^(BOOL finished) {
        _developmentToolWindow.hidden = YES;
        _developmentToolWindow = nil;
        [_previousKeyWindow makeKeyWindow];
        _previousKeyWindow = nil;
        if (completion) {
            completion(window);
        }
    }];
}

+ (void)registerVersion:(NSString *)version {
    _developmentToolVersion = [version copy];
}

+ (void)registerIdentifier:(NSString *)identifier {
    _developmentToolIdentifier = [identifier copy];
}

+ (void)registerDevelopmentToolAction:(void(^)(void))action {
    _developmentToolAction = [action copy];
}

#pragma mark -

+ (BOOL)handleUrl:(NSURL *)url {
    BOOL safeMode = NO;
    BOOL ret = [self parseUrl:url safeMode:&safeMode];
    if (ret) {
        if (!safeMode && _developmentToolAction) {
            _developmentToolAction();
        } else {
            if (![self isShowingDevelopmentToolWindow]) {
                [self showDevelopmentToolWindow:nil];
            }
        }
    }
    return ret;
}

+ (BOOL)parseUrl:(NSURL *)url safeMode:(BOOL *)safeMode {
    if (![url.host isEqualToString:@"debug"]) {
        return NO;
    }

    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    BOOL ret = NO;
    BOOL sm = NO;
    for (NSURLQueryItem *queryItem in components.queryItems) {
        if ([queryItem.name isEqualToString:@"version"]) {
            if ([queryItem.value.lowercaseString isEqualToString:_developmentToolVersion]) {
                ret = YES;
            }
        }
        if ([queryItem.name isEqualToString:@"uuid"]) {
            if ([queryItem.value.lowercaseString isEqualToString:_developmentToolIdentifier]) {
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
    [self showDevelopmentToolWindow:nil];
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
        if (@available(iOS 11.0, *)) {
            bottomMargin = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets.bottom;
        }
        CGFloat margin = 5;
        for (NSInteger i = 0; i < 4; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
            label.font = [UIFont systemFontOfSize:10];
            label.textColor = [UIColor whiteColor];
            label.text = @"安全模式";
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
    static char s[21];
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
    SEL sel = sel_registerName(s);
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
    BOOL isSafeMode = [PDLApplication isLaunchOptionsSafeMode:launchOptions];
    if (isSafeMode == NO) {
        return ((typeof(&applicationDidFinishLaunchingWithOptions))_imp)(self, _cmd, application, launchOptions);
    } else {
        UIWindow *window = [PDLApplication window:isSafeMode];
        [PDLApplication setMainWindow:window];
        [window makeKeyAndVisible];
        return YES;
    }
}

static BOOL applicationOpenURLOptions(__unsafe_unretained UIApplication *self, SEL _cmd, __unsafe_unretained UIApplication *application, __unsafe_unretained NSURL *url, __unsafe_unretained NSDictionary<UIApplicationOpenURLOptionsKey,id> *options) {
    PDLImplementationInterceptorRecover(_cmd);
    BOOL ret = [PDLApplication handleUrl:url];
    if (_imp) {
        return ((typeof(&applicationOpenURLOptions))_imp)(self, _cmd, application, url, options);
    }
    return ret;
}

static BOOL applicationOpenURLOptionsAdded(__unsafe_unretained UIApplication *self, SEL _cmd, __unsafe_unretained UIApplication *application, __unsafe_unretained NSURL *url, __unsafe_unretained NSDictionary<UIApplicationOpenURLOptionsKey,id> *options) {
    return [PDLApplication handleUrl:url];
}

static BOOL applicationOpenURLSourceApplicationAnnotation(__unsafe_unretained id <UIApplicationDelegate> self, SEL _cmd, __unsafe_unretained UIApplication *application, __unsafe_unretained NSURL *url, __unsafe_unretained NSString *sourceApplication, __unsafe_unretained id annotation) {
    PDLImplementationInterceptorRecover(_cmd);
    BOOL ret = [PDLApplication handleUrl:url];
    if (_imp) {
        return ((typeof(&applicationOpenURLSourceApplicationAnnotation))_imp)(self, _cmd, application, url, sourceApplication, annotation);
    }
    return ret;
}

static BOOL applicationHandleOpenURL(__unsafe_unretained id <UIApplicationDelegate> self, SEL _cmd, __unsafe_unretained UIApplication *application, __unsafe_unretained NSURL *url) {
    PDLImplementationInterceptorRecover(_cmd);
    BOOL ret = [PDLApplication handleUrl:url];
    if (_imp) {
        return ((typeof(&applicationHandleOpenURL))_imp)(self, _cmd, application, url);
    }
    return ret;
}

+ (void)setApplicationDelegate:(id<UIApplicationDelegate>)delegate {
    if (delegate == nil) {
        return;
    }

    Class aClass = object_getClass(delegate);
    [aClass pdl_interceptSelector:@selector(application:didFinishLaunchingWithOptions:) withInterceptorImplementation:(IMP)&applicationDidFinishLaunchingWithOptions];
    BOOL ret = [aClass pdl_interceptSelector:@selector(application:openURL:options:) withInterceptorImplementation:(IMP)&applicationOpenURLOptions];
    if (!ret) {
        ret = [aClass pdl_interceptSelector:@selector(application:openURL:sourceApplication:annotation:) withInterceptorImplementation:(IMP)&applicationOpenURLSourceApplicationAnnotation];
    }
    if (!ret) {
        ret = [aClass pdl_interceptSelector:@selector(application:handleOpenURL:) withInterceptorImplementation:(IMP)&applicationHandleOpenURL];
    }
    if (!ret) {
        ret = class_addMethod(aClass, @selector(application:openURL:options:), (IMP)&applicationOpenURLOptionsAdded, NULL);
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

static void applicationSetShortcutItems(__unsafe_unretained UIApplication *self, SEL _cmd, NSArray *shortcutItems) {
    PDLImplementationInterceptorRecover(_cmd);
    UIApplicationShortcutItem *sm = [[UIApplicationShortcutItem alloc] initWithType:@"safemode" localizedTitle:@"安全模式" localizedSubtitle:nil icon:nil userInfo:nil];
    NSArray *items = shortcutItems ?: @[];
    items = [items arrayByAddingObject:sm];
    ((typeof(&applicationSetShortcutItems))_imp)(self, _cmd, items);
}

+ (BOOL)enable {
    static BOOL enabled = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL ret = [UIApplication pdl_interceptSelector:@selector(setDelegate:) withInterceptorImplementation:(IMP)&applicationSetDelegate];
        ret &= [UIApplication pdl_interceptSelector:@selector(setShortcutItems:) withInterceptorImplementation:(IMP)&applicationSetShortcutItems];
        enabled = ret;
    });
    return enabled;
}

@end
