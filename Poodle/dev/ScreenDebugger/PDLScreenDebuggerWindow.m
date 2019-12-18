//
//  PDLScreenDebuggerWindow.m
//  Poodle
//
//  Created by Poodle on 15/10/2016.
//  Copyright © 2016 Poodle. All rights reserved.
//

#import "PDLScreenDebuggerWindow.h"

@interface PDLScreenDebuggerWindowComponentsView : UIView

@end

@implementation PDLScreenDebuggerWindowComponentsView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return nil;
    }
    return view;
}

@end

@interface PDLScreenDebuggerWindow ()

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) PDLScreenDebuggerWindowComponentsView *componentsView;
@property (nonatomic, weak) UIView *arrow;
@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, weak) UIWindow *previousKeyWindow;
@property (nonatomic, weak) UIView *detailView;
@property (nonatomic, weak) UIButton *closeButton;

@property (nonatomic, assign) CGPoint touchPoint;
@property (nonatomic, assign) CGRect lastFrame;

@end

@implementation PDLScreenDebuggerWindow

static NSString *closeImageDataBase64String = @"iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAAlwSFlzAAAWJQAAFiUBSVIk8AAAABxpRE9UAAAAAgAAAAAAAAAUAAAAKAAAABQAAAAUAAABepLTgvsAAAFGSURBVFgJ7JVhkYNADIUrAQknoRJOAhJwgoRKWAlIQEIlVMJJ4L7MbDo726QsS3q/LjOZtNnkvUcIcLn8W+AEtm274mv2hTgEwrtQ8IyZcyW+56VgxtVWFzXoACIZyo8SEr93oSlKRUPabegsgKMWNzVD0SyjVrs1NzYWAjzgdyUgtosTjtMAb4Qa2H13yQA6dpWOSHDLu9MnTrEBK/dElvmqZz2R/oSr3XswXnpACxEJzqzKiLJ/ca8xwMYC/HEUnPrpTP/L1KxERdI8AfrKizu9Jpa2Zw6yWzGJ5Xng/KA2ZD0ceDsNaSpEuk9hJU5aJhvxA1nIVmHMNtcU5Adc1kDt78SJGFhdAcZZ+JeoHoj5Pwt5ENXGLH7RBNFdARM0OomA+iEoxe0+RNF6TLxKpA5P9i/uRWwyH0giJqmyHL8OtLulvwAAAP//NVs+cwAAAVRJREFU7ZRhEYMwDEYnAQmTgIRJmIQ6mQQkIGESkDAJkzAJ7H13zS3Xo4O2jF/LXS5Aki+vBXo67WDzPAc8tQcPuh3k2ySA6PFXpFO8x2uFR5t6YzcAHk5AQZLEUTfRxsYxde0M7/BnhFAIXon7SQ+jHQvJUMHpGzMbPJyuSaQ1Ia352T3DJyMjZneH3PGQAsLNprVdoLDH7SdS32WtpzqP+KAJ0fSKNx0j1HlIwfbVELlGRP1ZtxnO9Oi/4maCPFuuOSLm4ap3INEpXuTiQhDd9fWgd8PN2iBR8XASvS6uovAhOqPEomVPga+yNHf4M4oohK8NhUn07k67DJJGwWn7zW6F81fLEa6fQfNkZMSy1a2ifQrQTiHDJ5u5EhBu9jM4G8+gM/6ygcT8d05ycIV6xZsOYhtWG5nT4wapuHyQk7g4PwTOFsVc7aTNXwa04n8s2IE3S6awERNb0SAAAAAASUVORK5CYII=";

+ (UIImage *)closeImage {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:closeImageDataBase64String options:0];
    UIImage *rawImage = [UIImage imageWithData:data];
    UIImage *closeImage = [UIImage imageWithCGImage:rawImage.CGImage scale:2 orientation:rawImage.imageOrientation];
    return closeImage;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert;

        _currentPoint = self.center;
        _lastFrame = CGRectZero;

        self.rootViewController = [[UIViewController alloc] init];
        UIView *view = self.rootViewController.view;
        view.backgroundColor = [UIColor clearColor];

        UIView *contentView = [[UIView alloc] initWithFrame:view.bounds];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view addSubview:contentView];
        _contentView = contentView;

        PDLScreenDebuggerWindowComponentsView *componentsView = [[PDLScreenDebuggerWindowComponentsView alloc] initWithFrame:view.bounds];
        componentsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view addSubview:componentsView];
        _componentsView = componentsView;

        CGFloat verticalMargin = 0;
        if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
            verticalMargin = self.safeAreaInsets.top + self.safeAreaInsets.bottom;
#pragma clang diagnostic pop
        }
        UIView *detailView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, floor(contentView.bounds.size.width * 0.9), floor((contentView.bounds.size.height - verticalMargin) * 0.45))];
        detailView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        detailView.layer.cornerRadius = 10;
        detailView.hidden = YES;
        [componentsView addSubview:detailView];
        _detailView = detailView;

        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        closeButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        closeButton.layer.cornerRadius = 10;
        UIImage *image = [self.class closeImage];
        [closeButton setImage:image forState:UIControlStateNormal];
        [componentsView addSubview:closeButton];
        _closeButton = closeButton;

        UIView *arrow = [[UIView alloc] initWithFrame:CGRectZero];
        arrow.backgroundColor = [UIColor blackColor];
        CGFloat lineWidth = 1 / [UIScreen mainScreen].scale;
        UIView *v1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, lineWidth)];
        [arrow addSubview:v1];
        UIView *v2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lineWidth, 30)];
        [arrow addSubview:v2];
        arrow.clipsToBounds = NO;
        CGPoint center = CGPointMake(0, 0);
        v1.center = center;
        v2.center = center;
        [componentsView addSubview:arrow];
        _arrow = arrow;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat verticalMargin = 0;
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        verticalMargin = self.safeAreaInsets.top + self.safeAreaInsets.bottom;
#pragma clang diagnostic pop
    }
    self.detailView.frame = CGRectMake(self.detailView.frame.origin.x, self.detailView.frame.origin.y, floor(self.detailView.superview.bounds.size.width * 0.9), floor((self.detailView.superview.bounds.size.height - verticalMargin) * 0.45));

    for (UIView *subview in self.arrow.subviews) {
        subview.backgroundColor = self.arrow.backgroundColor;
    }

    if (!CGRectEqualToRect(self.frame, self.lastFrame)) {
        self.lastFrame = self.frame;
        [self debugPoint];
    }
}

- (void)makeKeyWindow {
    UIWindow *previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    if (previousKeyWindow != self) {
        if (previousKeyWindow == nil) {
            previousKeyWindow = [UIApplication sharedApplication].windows.firstObject;
        }
        self.previousKeyWindow = previousKeyWindow;
    }

    [super makeKeyWindow];

    [self sendSubviewToBack:self.rootViewController.view];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    UITouch *touch = [touches anyObject];
    self.touchPoint = [touch locationInView:self];

    [self debugPoint];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];

    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    CGPoint originalPoint = self.touchPoint;
    CGPoint point = self.currentPoint;
    point.x += (touchPoint.x - originalPoint.x);
    if (point.x < 0) {
        point.x = 0;
    }
    if (point.x > self.bounds.size.width) {
        point.x = self.bounds.size.width;
    }
    point.y += (touchPoint.y - originalPoint.y);
    if (point.y < 0) {
        point.y = 0;
    }
    if (point.y > self.bounds.size.height) {
        point.y = self.bounds.size.height;
    }
    self.touchPoint = touchPoint;
    self.currentPoint = point;

    [self debugPoint];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    self.touchPoint = touchPoint;

    [self debugPoint];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];

    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    self.touchPoint = touchPoint;

    [self debugPoint];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [self.previousKeyWindow motionBegan:motion withEvent:event];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [self.previousKeyWindow motionEnded:motion withEvent:event];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [self.previousKeyWindow motionCancelled:motion withEvent:event];
}

- (void)debugPoint {
    self.arrow.frame = CGRectMake(self.currentPoint.x, self.currentPoint.y, self.arrow.frame.size.width, self.arrow.frame.size.height);
    CGPoint point = self.currentPoint;
    CGRect detailViewFrame = self.detailView.frame;
    CGRect closeButtonFrame = self.closeButton.frame;
    if (point.x <= self.bounds.size.width / 2) {
        detailViewFrame.origin.x = self.contentView.bounds.size.width - detailViewFrame.size.width;
        closeButtonFrame.origin.x = self.contentView.bounds.size.width - closeButtonFrame.size.width;
    } else {
        detailViewFrame.origin.x = 0;
        closeButtonFrame.origin.x = 0;
    }

    CGFloat top = 0;
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        top = self.safeAreaInsets.top;
#pragma clang diagnostic pop
    }
    CGFloat bottom = 0;
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        bottom = self.safeAreaInsets.bottom;
#pragma clang diagnostic pop
    }
    if (point.y <= top + (self.bounds.size.height - top - bottom) / 2) {
        detailViewFrame.origin.y = self.contentView.bounds.size.height - bottom - detailViewFrame.size.height;
        closeButtonFrame.origin.y = top;
    } else {
        detailViewFrame.origin.y = top;
        closeButtonFrame.origin.y = self.contentView.bounds.size.height - bottom - closeButtonFrame.size.height;
    }

    self.detailView.frame = detailViewFrame;
    self.closeButton.frame = closeButtonFrame;
}

@end
