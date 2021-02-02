//
//  PDLViewController.m
//  Poodle
//
//  Created by Poodle on 2014/12/31.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLViewController.h"

@interface PDLViewController ()

@end

@implementation PDLViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
            self.automaticallyAdjustsScrollViewInsets = YES;
#pragma clang diagnostic pop
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIColor *backgroundColor = nil;
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 13) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        backgroundColor = [UIColor systemBackgroundColor];
#pragma clang diagnostic pop
    } else {
        backgroundColor = [UIColor whiteColor];
    }
    self.view.backgroundColor = backgroundColor;
}

@end
