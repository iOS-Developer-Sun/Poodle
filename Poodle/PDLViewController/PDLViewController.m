//
//  PDLViewController.m
//  Poodle
//
//  Created by Poodle on 2014/12/31.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLViewController.h"
#import "PDLColor.h"

@interface PDLViewController () {
    BOOL _isViewAppearing;
    CGFloat _keyboardHeight;
}

@property (nonatomic, weak) UIView *containerView;

@end

@implementation PDLViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _adjustContainerViewSizeForKeyboardEventAutomatically = YES;
        
        self.hidesBottomBarWhenPushed = YES;
//        self.extendedLayoutIncludesOpaqueBars = NO;
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wunguarded-availability"
//#pragma clang diagnostic ignored "-Wunguarded-availability-new"
//            self.automaticallyAdjustsScrollViewInsets = YES;
//#pragma clang diagnostic pop
//        } else {
//            self.automaticallyAdjustsScrollViewInsets = NO;
//        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = PDLColorBackgroundColor();
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    _isViewAppearing = YES;

    if (self.adjustContainerViewSizeForKeyboardEventAutomatically) {
        [[PDLKeyboardNotificationObserver observerForDelegate:self] startObserving];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[PDLKeyboardNotificationObserver observerForDelegate:self] stopObserving];

    _isViewAppearing = NO;
}

- (void)layoutContainerView {
    UIEdgeInsets edgeInsets = self.view.safeAreaInsets;
    UIView *containerView = _containerView;
    if (containerView) {
        if (_keyboardHeight > 0) {
            containerView.frame = CGRectMake(edgeInsets.left, edgeInsets.top, self.view.frame.size.width - edgeInsets.left - edgeInsets.right, self.view.frame.size.height - edgeInsets.top - _keyboardHeight);
        } else {
            containerView.frame = CGRectMake(edgeInsets.left, edgeInsets.top, self.view.frame.size.width - edgeInsets.left - edgeInsets.right, self.view.frame.size.height - edgeInsets.top - edgeInsets.bottom);
        }
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self layoutContainerView];
}

- (UIView *)containerView {
    UIView *containerView = _containerView;
    if (!containerView) {
        containerView = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:containerView];
        _containerView = containerView;
    }
    return containerView;
}

- (void)setAdjustContainerViewSizeForKeyboardEventAutomatically:(BOOL)adjustContainerViewSizeForKeyboardEventAutomatically {
    if (_adjustContainerViewSizeForKeyboardEventAutomatically == adjustContainerViewSizeForKeyboardEventAutomatically) {
        return;
    }


    if (_isViewAppearing) {
        if (adjustContainerViewSizeForKeyboardEventAutomatically) {
            [[PDLKeyboardNotificationObserver observerForDelegate:self] startObserving];
        } else {
            [[PDLKeyboardNotificationObserver observerForDelegate:self] stopObserving];
        }
    }
}

- (void)keyboardShowAnimation:(PDLKeyboardNotificationObserver *)observer withKeyboardHeight:(CGFloat)keyboardHeight {
    _keyboardHeight = keyboardHeight;
    [self layoutContainerView];
}

- (void)keyboardHideAnimation:(PDLKeyboardNotificationObserver *)observer withKeyboardHeight:(CGFloat)keyboardHeight {
    _keyboardHeight = 0;
    [self layoutContainerView];
}

@end
