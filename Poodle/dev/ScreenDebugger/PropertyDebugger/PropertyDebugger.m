//
//  PropertyDebugger.m
//  Sunzj
//
//  Created by sunzj on 6/11/2016.
//  Copyright © 2016 sunzj. All rights reserved.
//

#import "PropertyDebugger.h"

@interface PropertyDebuggerMainView : UIView

@property (nonatomic, weak) PropertyDebugger *propertyDebugger;

@end

@implementation PropertyDebuggerMainView

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.propertyDebugger mainViewDidLayoutSubviews];
}

@end

@interface PropertyDebugger ()

@property (nonatomic, strong) PropertyDebuggerMainView *mainView;
@property (nonatomic, strong) UIView *controlPanel;
@property (nonatomic, assign) CGRect propertyDebuggerControlPanePanFrame;

@end


@implementation PropertyDebugger

- (id)value {
    if (self.getter) {
        return self.getter(self);
    } else {
        return [self.object valueForKeyPath:self.keyPath];
    }
}

- (void)setValue:(id)value {
    if (self.setter) {
        self.setter(self, value);
    } else {
        [self.object setValue:value forKeyPath:self.keyPath];
    }
}

- (UIView *)controlPanel {
    if (_controlPanel == nil) {
        UIView *controlPanel = [[UIView alloc] init];
        controlPanel.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];

        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(propertyDebuggerControlPanelDidPan:)];
        panGestureRecognizer.enabled = NO;
        [controlPanel addGestureRecognizer:panGestureRecognizer];

        _controlPanel = controlPanel;
    }
    return _controlPanel;
}

- (void)propertyDebuggerControlPanelDidPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.propertyDebuggerControlPanePanFrame = self.controlPanel.frame;\
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateCancelled: {
            CGRect frame = CGRectOffset(self.propertyDebuggerControlPanePanFrame, translation.x, translation.y);
            if (frame.origin.x < 0) {
                CGRect propertyDebuggerControlPanePanFrame = self.propertyDebuggerControlPanePanFrame;
                propertyDebuggerControlPanePanFrame.origin.x -= frame.origin.x;
                self.propertyDebuggerControlPanePanFrame = propertyDebuggerControlPanePanFrame;
                frame.origin.x = 0;
            }
            if (frame.origin.y < 0) {
                CGRect propertyDebuggerControlPanePanFrame = self.propertyDebuggerControlPanePanFrame;
                propertyDebuggerControlPanePanFrame.origin.y -= frame.origin.y;
                self.propertyDebuggerControlPanePanFrame = propertyDebuggerControlPanePanFrame;
                frame.origin.y = 0;
            }
            CGFloat maxX = self.controlPanel.superview.frame.size.width - frame.size.width;
            if (frame.origin.x > maxX) {
                CGRect propertyDebuggerControlPanePanFrame = self.propertyDebuggerControlPanePanFrame;
                propertyDebuggerControlPanePanFrame.origin.x -= (frame.origin.x - maxX);
                self.propertyDebuggerControlPanePanFrame = propertyDebuggerControlPanePanFrame;
                frame.origin.x = maxX;
            }
            CGFloat maxY = self.controlPanel.superview.frame.size.height - frame.size.height;
            if (frame.origin.y > maxY) {
                CGRect propertyDebuggerControlPanePanFrame = self.propertyDebuggerControlPanePanFrame;
                propertyDebuggerControlPanePanFrame.origin.y -= (frame.origin.y - maxY);
                self.propertyDebuggerControlPanePanFrame = propertyDebuggerControlPanePanFrame;
                frame.origin.y = maxY;
            }
            self.controlPanel.frame = frame;
        } break;
        default:
            break;
    };
}

- (void)mainViewDidLoad {
    ;
}

- (void)mainViewDidLayoutSubviews {
    ;
}

- (void)setControlPanelFloatingEnabled:(BOOL)isEnabled {
    self.controlPanel.gestureRecognizers.lastObject.enabled = isEnabled;
}

- (UIView *)mainViewWithFrame:(CGRect)frame {
    if (self.mainView == nil) {
        PropertyDebuggerMainView *mainView = [[PropertyDebuggerMainView alloc] initWithFrame:frame];
        mainView.propertyDebugger = self;
        mainView.backgroundColor = [UIColor clearColor];
        mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.mainView = mainView;

        [self mainViewDidLoad];
    }
    self.mainView.frame = frame;

    return self.mainView;
}


@end
