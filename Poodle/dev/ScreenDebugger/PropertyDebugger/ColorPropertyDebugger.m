//
//  ColorPropertyDebugger.m
//  Sunzj
//
//  Created by sunzj on 6/11/2016.
//  Copyright © 2016 sunzj. All rights reserved.
//

#import "ColorPropertyDebugger.h"

@interface ColorPropertyDebugger ()

@property (nonatomic, weak) UILabel *redLabel;
@property (nonatomic, weak) UILabel *greenLabel;
@property (nonatomic, weak) UILabel *blueLabel;

@property (nonatomic, weak) UILabel *hueLabel;
@property (nonatomic, weak) UILabel *saturationLabel;
@property (nonatomic, weak) UILabel *brightnessLabel;

@property (nonatomic, weak) UILabel *alphaLabel;

@property (nonatomic, weak) UISlider *redSlider;
@property (nonatomic, weak) UISlider *greenSlider;
@property (nonatomic, weak) UISlider *blueSlider;

@property (nonatomic, weak) UISlider *hueSlider;
@property (nonatomic, weak) UISlider *saturationSlider;
@property (nonatomic, weak) UISlider *brightnessSlider;

@property (nonatomic, weak) UISlider *alphaSlider;

@property (nonatomic, weak) UIView *precastColorsBoard;
@property (nonatomic, weak) UIView *slidersBoard;
@property (nonatomic, weak) UIView *indicatorView;

@end

@implementation ColorPropertyDebugger

- (void)setValue:(id)value {
    [super setValue:value];

    [self refresh];
}

- (void)mainViewDidLoad {
    [super mainViewDidLoad];

    [self.mainView addSubview:self.controlPanel];
    self.controlPanel.frame = CGRectMake(0, self.mainView.frame.size.height - 240, self.mainView.frame.size.width, 240);
    [self setControlPanelFloatingEnabled:YES];

    UIView *precastColorsBoard = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.controlPanel.frame.size.width, 80)];
    precastColorsBoard.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.controlPanel addSubview:precastColorsBoard];
    self.precastColorsBoard = precastColorsBoard;

    CGFloat buttonWidth = (precastColorsBoard.frame.size.width - precastColorsBoard.frame.size.height) / 8;
    CGFloat buttonHeight = precastColorsBoard.frame.size.height / 2;
    CGSize buttonSize = CGSizeMake(30, 30);

    for (NSInteger i = 0; i < self.precastColors.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonSize.width, buttonSize.height)];
        button.tag = i;
        NSInteger column = i % 8;
        NSInteger row = i / 8;
        button.center = CGPointMake((column + 0.5) * buttonWidth, (row + 0.5) * buttonHeight);

        UIColor *color = self.precastColors[i];
        if ((NSNull *)color == [NSNull null]) {
            color = nil;

            CAShapeLayer *border = [CAShapeLayer layer];
            border.strokeColor = [UIColor blackColor].CGColor;
            border.fillColor = nil;
            border.path = [UIBezierPath bezierPathWithRect:button.bounds].CGPath;
            border.frame = button.layer.bounds;
            border.lineWidth = 1;
            border.lineCap = @"square";
            border.lineDashPattern = @[@4, @2];
            [button.layer addSublayer:border];
        } else {
            button.layer.borderColor = [UIColor blackColor].CGColor;
            button.layer.borderWidth = 1;
        }

        button.backgroundColor = color;
        [button addTarget:self action:@selector(precastColorButtonDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [precastColorsBoard addSubview:button];
    }

    CGFloat indicatorSize = buttonSize.height + buttonHeight;

    UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectMake(precastColorsBoard.frame.size.width - precastColorsBoard.frame.size.height + (precastColorsBoard.frame.size.height - indicatorSize) * 0.5, (precastColorsBoard.frame.size.height - indicatorSize) * 0.5, indicatorSize, indicatorSize)];
    [precastColorsBoard addSubview:indicatorView];
    self.indicatorView = indicatorView;

    UIView *slidersBoard = [[UIView alloc] initWithFrame:CGRectMake(0, 90, self.controlPanel.frame.size.width, 150)];
    slidersBoard.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    slidersBoard.backgroundColor = [UIColor clearColor];
    [self.controlPanel addSubview:slidersBoard];
    self.slidersBoard = slidersBoard;

    NSMutableArray *sliders = [NSMutableArray array];
    NSMutableArray *labels = [NSMutableArray array];
    CGFloat width = self.controlPanel.frame.size.width / 7;
    for (NSInteger i = 0; i < 7; i++) {
        UISlider *slider = [self createSlider];
        slider.frame = CGRectMake(width * i, 0, width, 100);
        [slidersBoard addSubview:slider];
        [sliders addObject:slider];

        UILabel *label = [self createLabel];
        label.frame = CGRectMake(width * i, 110, width, 40);
        [slidersBoard addSubview:label];
        [labels addObject:label];
    }
    self.redSlider = sliders[0];
    self.greenSlider = sliders[1];
    self.blueSlider = sliders[2];
    self.hueSlider = sliders[3];
    self.saturationSlider = sliders[4];
    self.brightnessSlider = sliders[5];
    self.alphaSlider = sliders[6];

    self.redLabel = labels[0];
    self.greenLabel = labels[1];
    self.blueLabel = labels[2];
    self.hueLabel = labels[3];
    self.saturationLabel = labels[4];
    self.brightnessLabel = labels[5];
    self.alphaLabel = labels[6];
}

- (NSArray *)precastColors {
    static NSArray *precastColors = nil;
    if (precastColors == nil) {
        precastColors = @[
                          [NSNull null],
                          [UIColor clearColor],
                          [UIColor blackColor],
                          [UIColor darkGrayColor],
                          [UIColor grayColor],
                          [UIColor lightGrayColor],
                          [UIColor whiteColor],
                          [UIColor redColor],
                          [UIColor greenColor],
                          [UIColor blueColor],
                          [UIColor cyanColor],
                          [UIColor magentaColor],
                          [UIColor yellowColor],
                          [UIColor orangeColor],
                          [UIColor purpleColor],
                          [UIColor brownColor],
                          ];
    }
    return precastColors;
}

- (UISlider *)createSlider {
    UISlider *slider = [[UISlider alloc] init];
    slider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    slider.maximumValue = 1;
    slider.minimumValue = 0;
    [slider addTarget:self action:@selector(slide:) forControlEvents:UIControlEventValueChanged];
    slider.transform = CGAffineTransformMakeRotation(- M_PI / 2);

    return slider;
}

- (UILabel *)createLabel {
    UILabel *label = [[UILabel alloc] init];
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:12];

    return label;
}

//- (NSString *)valueDescription:(id)value {
//    NSString *string = nil;
//    UIColor *color = (UIColor *)value;
//    CGFloat white = 0;
//    CGFloat alpha = 0;
//    BOOL ret = [color getWhite:&white alpha:&alpha];
//
//    return [NSString stringWithFormat:@"%.2f", [value floatValue]];
//}

- (void)precastColorButtonDidTouchUpInside:(UIButton *)button {
    UIColor *color = self.precastColors[button.tag];
    if ((NSNull *)color == [NSNull null]) {
        color = nil;
    }

    self.value = color;
}

- (void)slide:(UISlider *)slider {
    UIColor *color = nil;
    if (slider == self.redSlider || slider == self.greenSlider || slider == self.blueSlider) {
        color = [UIColor colorWithRed:self.redSlider.value green:self.greenSlider.value blue:self.blueSlider.value alpha:self.alphaSlider.value];
    } else {
        color = [UIColor colorWithHue:self.hueSlider.value saturation:self.saturationSlider.value brightness:self.brightnessSlider.value alpha:self.alphaSlider.value];
    }
    self.value = color;
}

- (void)mainViewDidLayoutSubviews {
    [super mainViewDidLayoutSubviews];

    [self refresh];
}

- (void)refresh {
    UIColor *color = self.value;
    self.indicatorView.backgroundColor = color;
    for (CALayer *layer in self.indicatorView.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
    if (color == nil) {
        CAShapeLayer *border = [CAShapeLayer layer];
        border.strokeColor = [UIColor blackColor].CGColor;
        border.fillColor = nil;
        border.path = [UIBezierPath bezierPathWithRect:self.indicatorView.bounds].CGPath;
        border.frame = self.indicatorView.layer.bounds;
        border.lineWidth = 1;
        border.lineCap = @"square";
        border.lineDashPattern = @[@4, @2];
        [self.indicatorView.layer addSublayer:border];

        self.indicatorView.layer.borderColor = nil;
        self.indicatorView.layer.borderWidth = 0;
    } else {
        self.indicatorView.layer.borderColor = [UIColor blackColor].CGColor;
        self.indicatorView.layer.borderWidth = 1;
    }

    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat hue = 0;
    CGFloat saturation = 0;
    CGFloat brightness = 0;
    CGFloat alpha = 0;

    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];

    self.redSlider.value = red;
    self.greenSlider.value = green;
    self.blueSlider.value = blue;
    self.hueSlider.value = hue;
    self.saturationSlider.value = saturation;
    self.brightnessSlider.value = brightness;
    self.alphaSlider.value = alpha;

    if (color) {
        self.redLabel.text = [NSString stringWithFormat:@"red\n%@", @((NSInteger)(red * 255)).stringValue];
        self.greenLabel.text = [NSString stringWithFormat:@"green\n%@", @((NSInteger)(green * 255)).stringValue];
        self.blueLabel.text = [NSString stringWithFormat:@"blue\n%@", @((NSInteger)(blue * 255)).stringValue];
        self.hueLabel.text = [NSString stringWithFormat:@"hue\n%@", @((NSInteger)(hue * 255)).stringValue];
        self.saturationLabel.text = [NSString stringWithFormat:@"sat\n%@", @((NSInteger)(saturation * 255)).stringValue];
        self.brightnessLabel.text = [NSString stringWithFormat:@"bri\n%@", @((NSInteger)(brightness * 255)).stringValue];
        self.alphaLabel.text = [NSString stringWithFormat:@"alpha\n%@", @((NSInteger)(alpha * 255)).stringValue];
    } else {
        self.redLabel.text = @"";
        self.greenLabel.text = @"";
        self.blueLabel.text = @"";
        self.hueLabel.text = @"";
        self.saturationLabel.text = @"";
        self.brightnessLabel.text = @"";
        self.alphaLabel.text = @"";
    }
}

@end
