//
//  RectPropertyDebugger.m
//  Sunzj
//
//  Created by sunzj on 5/11/2016.
//  Copyright © 2016 sunzj. All rights reserved.
//

#import "RectPropertyDebugger.h"

@interface RectPropertyDebugger ()

@property (nonatomic, weak) UIView *gestureView;
@property (nonatomic, weak) UILabel *xLabel;
@property (nonatomic, weak) UILabel *yLabel;
@property (nonatomic, weak) UILabel *widthLabel;
@property (nonatomic, weak) UILabel *heightLabel;

@property (nonatomic, assign) CGRect panFrame;
@property (nonatomic, assign) CGRect pinchFrame;
@property (nonatomic, assign) CGPoint location;
@property (nonatomic, assign) CGFloat offsetX;
@property (nonatomic, assign) CGFloat offsetY;

@property (nonatomic, assign) BOOL locksX;
@property (nonatomic, assign) BOOL locksY;
@property (nonatomic, assign) BOOL locksWidth;
@property (nonatomic, assign) BOOL locksHeight;

@end

@implementation RectPropertyDebugger

- (CGRect)frame {
     NSValue *value = self.value;
    CGRect frame = value.CGRectValue;
    return frame;
}

- (void)setFrame:(CGRect)frame {
    NSValue *value = [NSValue valueWithCGRect:frame];
    self.value = value;
    [self refresh];
}

- (void)mainViewDidLoad {
    [super mainViewDidLoad];

    UIView *mainView = self.mainView;
    CGRect frame = mainView.frame;

    UIView *gestureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 66)];
    gestureView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [mainView addSubview:gestureView];
    self.gestureView = gestureView;

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [gestureView addGestureRecognizer:panGestureRecognizer];

    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [gestureView addGestureRecognizer:pinchGestureRecognizer];

    self.controlPanel.frame = CGRectMake(0, frame.size.height - 66, frame.size.width, 66);
    UIView *bottomView = self.controlPanel;
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [mainView addSubview:bottomView];

    UILabel *xLabel = [self createLabel];
    xLabel.frame = CGRectMake(0, 0, frame.size.width / 4, 66);
    xLabel.text = @"X";
    [bottomView addSubview:xLabel];
    _xLabel = xLabel;

    UILabel *yLabel = [self createLabel];
    yLabel.frame = CGRectMake(frame.size.width / 4, 0, frame.size.width / 4, 66);
    yLabel.text = @"Y";
    [bottomView addSubview:yLabel];
    _yLabel = yLabel;

    UILabel *widthLabel = [self createLabel];
    widthLabel.frame = CGRectMake(frame.size.width / 4 * 2, 0, frame.size.width / 4, 66);
    widthLabel.text = @"Width";
    [bottomView addSubview:widthLabel];
    _widthLabel = widthLabel;

    UILabel *heightLabel = [self createLabel];
    heightLabel.frame = CGRectMake(frame.size.width / 4 * 3, 0, frame.size.width / 4, 66);
    heightLabel.text = @"Height";
    [bottomView addSubview:heightLabel];
    _heightLabel = heightLabel;

    [self refresh];
}

- (void)mainViewDidLayoutSubviews {
    [super mainViewDidLayoutSubviews];

    CGRect frame = self.controlPanel.frame;
    self.xLabel.frame = CGRectMake(0, 0, frame.size.width / 4, frame.size.height);
    self.yLabel.frame = CGRectMake(frame.size.width / 4, 0, frame.size.width / 4, frame.size.height);
    self.widthLabel.frame = CGRectMake(frame.size.width / 4 * 2, 0, frame.size.width / 4, frame.size.height);
    self.heightLabel.frame = CGRectMake(frame.size.width / 4 * 3, 0, frame.size.width / 4, frame.size.height);
}

- (UILabel *)createLabel {
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelDidTap:)]];
    [label addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(labelDidLongPress:)]];
    return label;
}

- (CGFloat)integralFloat:(CGFloat)f {
    CGFloat scale = [UIScreen mainScreen].scale;
    return round(f * scale) / scale;
}

- (void)pan:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    CGFloat x = [self integralFloat:translation.x];
    CGFloat y = [self integralFloat:translation.y];
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.panFrame = self.frame;
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateCancelled: {
            if (self.locksX) {
                CGRect panFrame = self.panFrame;
                panFrame.origin.x = self.frame.origin.x - x;
                self.panFrame = panFrame;
            }
            if (self.locksY) {
                CGRect panFrame = self.panFrame;
                panFrame.origin.y = self.frame.origin.y - y;
                self.panFrame = panFrame;
            }
            self.frame = CGRectOffset(self.panFrame, x, y);
        } break;
        default:
            break;
    };
}

- (void)pinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    if (pinchGestureRecognizer.numberOfTouches != 2) {
        self.location = CGPointZero;
        self.offsetX = 0;
        self.offsetY = 0;
        return;
    }

    CGPoint location0 = [pinchGestureRecognizer locationOfTouch:0 inView:pinchGestureRecognizer.view];
    CGPoint location1 = [pinchGestureRecognizer locationOfTouch:1 inView:pinchGestureRecognizer.view];
    CGFloat offsetX = [self integralFloat:location0.x - location1.x];
    CGFloat offsetY = [self integralFloat:location0.y - location1.y];
    if (self.offsetX == 0 && self.offsetY == 0) {
        self.location = location0;
        self.offsetX = offsetX;
        self.offsetY = offsetY;
        self.pinchFrame = self.frame;
    } else {
        CGFloat diffWidth = offsetX - self.offsetX;
        if (self.offsetX < 0) {
            diffWidth = -diffWidth;
        }
        CGRect frame = self.frame;
        CGFloat width = self.pinchFrame.size.width + diffWidth;
        if (width < 0) {
            width = -width;
            frame.origin.x = self.pinchFrame.origin.x - width;
        }
        frame.size.width = width;
        if (self.locksWidth) {
            frame.size.width = self.pinchFrame.size.width;
        }

        CGFloat diffHeight = offsetY - self.offsetY;
        if (self.offsetY < 0) {
            diffHeight = -diffHeight;
        }
        CGFloat height = self.pinchFrame.size.height + diffHeight;
        if (height < 0) {
            height = -height;
            frame.origin.y = self.pinchFrame.origin.y - height;
        }
        frame.size.height = height;
        if (self.locksHeight) {
            frame.size.height = self.pinchFrame.size.height;
        }

        CGFloat diffX = location0.x - self.location.x;
        CGFloat diffY = location0.y - self.location.y;

        if (self.locksX) {
            CGRect pinchFrame = self.pinchFrame;
            pinchFrame.origin.x = self.frame.origin.x - diffX;
            self.pinchFrame = pinchFrame;
        }

        if (self.locksY) {
            CGRect pinchFrame = self.pinchFrame;
            pinchFrame.origin.y = self.frame.origin.y - diffY;
            self.pinchFrame = pinchFrame;
        }

        frame.origin.x = self.pinchFrame.origin.x + diffX;
        frame.origin.y = self.pinchFrame.origin.y + diffY;

        self.frame = frame;
    }

    switch (pinchGestureRecognizer.state) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            self.location = CGPointZero;
            self.offsetX = 0;
            self.offsetY = 0;
        } break;
        default:
            break;
    };
}

- (void)labelDidTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    UILabel *label = (typeof(label))tapGestureRecognizer.view;
    if (label == self.xLabel) {
        self.locksX = !self.locksX;
    } else if (label == self.yLabel) {
        self.locksY = !self.locksY;
    } else if (label == self.widthLabel) {
        self.locksWidth = !self.locksWidth;
    } else if (label == self.heightLabel) {
        self.locksHeight = !self.locksHeight;
    }
    [self refresh];
}

- (void)labelDidLongPress:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }

    UILabel *label = (typeof(label))tapGestureRecognizer.view;
    NSString *text = nil;
    NSString *title = nil;
    void(^frameAction)(CGRect *frame, CGFloat doubleValue) = nil;
    if (label == self.xLabel) {
        title = @"x";
        text = [NSString stringWithFormat:@"%.3f", self.frame.origin.x];
        frameAction = ^(CGRect *frame, CGFloat doubleValue) {
            frame->origin.x = doubleValue;
        };
    } else if (label == self.yLabel) {
        title = @"y";
        text = [NSString stringWithFormat:@"%.3f", self.frame.origin.y];
        frameAction = ^(CGRect *frame, CGFloat doubleValue) {
            frame->origin.y = doubleValue;
        };
    } else if (label == self.widthLabel) {
        title = @"width";
        text = [NSString stringWithFormat:@"%.3f", self.frame.size.width];
        frameAction = ^(CGRect *frame, CGFloat doubleValue) {
            frame->size.width = doubleValue;
        };
    } else if (label == self.heightLabel) {
        title = @"height";
        text = [NSString stringWithFormat:@"%.3f", self.frame.size.height];
        frameAction = ^(CGRect *frame, CGFloat doubleValue) {
            frame->size.height = doubleValue;
        };
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak __typeof(self) weakSelf = self;
    __weak __typeof(alertController) weakAlertController = alertController;
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *text = weakAlertController.textFields.firstObject.text;
        CGFloat doubleValue = text.doubleValue;
        CGRect frame = weakSelf.frame;
        frameAction(&frame, [weakSelf integralFloat:doubleValue]);
        weakSelf.frame = frame;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        ;
    }]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = text;
    }];
    [self.mainView.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)refresh {
    CGRect frame = self.frame;
    self.xLabel.text = [NSString stringWithFormat:@"x\n%.3f", frame.origin.x];
    self.yLabel.text = [NSString stringWithFormat:@"y\n%.3f", frame.origin.y];
    self.widthLabel.text = [NSString stringWithFormat:@"width\n%.3f", frame.size.width];
    self.heightLabel.text = [NSString stringWithFormat:@"height\n%.3f", frame.size.height];

    self.xLabel.textColor = self.locksX ? [UIColor blackColor] : [UIColor whiteColor];
    self.yLabel.textColor = self.locksY ? [UIColor blackColor] : [UIColor whiteColor];
    self.widthLabel.textColor = self.locksWidth ? [UIColor blackColor] : [UIColor whiteColor];
    self.heightLabel.textColor = self.locksHeight ? [UIColor blackColor] : [UIColor whiteColor];
}

@end
