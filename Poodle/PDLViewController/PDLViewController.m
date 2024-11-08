//
//  PDLViewController.m
//  Poodle
//
//  Created by Poodle on 2014/12/31.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLViewController.h"
#import "PDLColor.h"

@interface PDLViewController ()

@property (nonatomic, weak) UIView *containerView;

@end

@implementation PDLViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    UIEdgeInsets edgeInsets = self.view.safeAreaInsets;

    UIView *containerView = _containerView;
    if (containerView) {
        containerView.frame = CGRectMake(edgeInsets.left, edgeInsets.top, self.view.frame.size.width - edgeInsets.left - edgeInsets.right, self.view.frame.size.height - edgeInsets.top - edgeInsets.bottom);
    }
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

@end
