//
//  PDLBoolPropertyDebugger.m
//  Poodle
//
//  Created by Poodle on 6/11/2016.
//  Copyright © 2016 Poodle. All rights reserved.
//

#import "PDLBoolPropertyDebugger.h"

@interface PDLBoolPropertyDebugger ()

@property (nonatomic, weak) UISwitch *aSwitch;

@end

@implementation PDLBoolPropertyDebugger

- (void)setValue:(id)value {
    [super setValue:value];

    [self refresh];
}

- (void)mainViewDidLoad {
    [super mainViewDidLoad];

    [self.mainView addSubview:self.controlPanel];
    self.controlPanel.frame = CGRectMake(0, self.mainView.frame.size.height - 50, self.mainView.frame.size.width, 50);
    [self setControlPanelFloatingEnabled:YES];

    UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:self.controlPanel.bounds];
    aSwitch.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.controlPanel addSubview:aSwitch];
    [aSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.aSwitch = aSwitch;
}

- (void)mainViewDidLayoutSubviews {
    [super mainViewDidLayoutSubviews];

    self.aSwitch.center = CGPointMake(self.controlPanel.frame.size.width / 2, self.controlPanel.frame.size.height / 2);
    [self refresh];
}

- (void)switchValueChanged:(UISwitch *)aSwitch {
    id value = @(aSwitch.isOn);
    self.value = value;
}

- (void)refresh {
    id value = self.value;
    self.aSwitch.on = [value boolValue];
}

@end
