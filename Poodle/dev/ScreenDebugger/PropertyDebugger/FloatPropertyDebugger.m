//
//  FloatPropertyDebugger.m
//  Sunzj
//
//  Created by sunzj on 6/11/2016.
//  Copyright © 2016 sunzj. All rights reserved.
//

#import "FloatPropertyDebugger.h"

@interface FloatPropertyDebugger ()

@property (nonatomic, weak) UILabel *label;
@property (nonatomic, weak) UISlider *slider;

@end

@implementation FloatPropertyDebugger

- (instancetype)init {
    self =  [super init];
    if (self) {
        _maximumValue = 1;
        _minimumValue = 0;
    }
    return self;
}

- (void)mainViewDidLoad {
    [super mainViewDidLoad];

    [self.mainView addSubview:self.controlPanel];
    self.controlPanel.frame = CGRectMake(0, self.mainView.frame.size.height - 66, self.mainView.frame.size.width, 66);
    [self setControlPanelFloatingEnabled:YES];

    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 0, self.controlPanel.frame.size.width - 100, self.controlPanel.frame.size.height)];
    slider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    slider.minimumValue = self.minimumValue;
    slider.maximumValue = self.maximumValue;
    [slider addTarget:self action:@selector(slide:) forControlEvents:UIControlEventValueChanged];
    [self.controlPanel addSubview:slider];
    self.slider = slider;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.controlPanel.frame.size.width - 80, 0, 80, self.controlPanel.frame.size.height)];
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.controlPanel addSubview:label];
    self.label = label;
}

- (NSString *)valueDescription:(id)value {
    return [NSString stringWithFormat:@"%.2f", [value floatValue]];
}

- (void)slide:(UISlider *)slider {
    id value = @(slider.value);
    self.value = value;
    self.label.text = [self valueDescription:value];
}

- (void)mainViewDidLayoutSubviews {
    [super mainViewDidLayoutSubviews];

    id value = self.value;
    self.slider.value = [value floatValue];
    self.label.text = [self valueDescription:value];
}

@end
