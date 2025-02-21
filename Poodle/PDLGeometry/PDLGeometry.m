//
//  PDLGeometry.h
//  Poodle
//
//  Created by Poodle on 28/06/2015.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLGeometry.h"

CGFloat pdl_integralFloat(CGFloat floatNumber) {
    CGFloat scale = [UIScreen mainScreen].scale;
#if defined(__LP64__) && __LP64__
    CGFloat ret = round(floatNumber * scale) / scale;
#else
    CGFloat ret = roundf(floatNumber * scale) / scale;
#endif
    return ret;
}

CGFloat pdl_lineWidth(void) {
    static CGFloat lineWidth = 1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lineWidth = 1 / [UIScreen mainScreen].scale;
    });
    return lineWidth;
}

@implementation UIView (PDLGeometry)

- (CGFloat)pdl_left {
    return self.frame.origin.x;
}

- (void)pdl_setLeft:(CGFloat)left {
    CGRect rect = self.frame;
    rect.origin.x = left;
    self.frame = rect;
}

- (CGFloat)pdl_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)pdl_setRight:(CGFloat)right {
    CGRect rect = self.frame;
    rect.origin.x = right - self.frame.size.width;
    self.frame = rect;
}

- (CGFloat)pdl_top {
    return self.frame.origin.y;
}

- (void)pdl_setTop:(CGFloat)top {
    CGRect rect = self.frame;
    rect.origin.y = top;
    self.frame = rect;
}

- (CGFloat)pdl_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)pdl_setBottom:(CGFloat)bottom {
    CGRect rect = self.frame;
    rect.origin.y = bottom - self.frame.size.height;
    self.frame = rect;
}

- (CGFloat)pdl_width {
    return self.frame.size.width;
}

- (void)pdl_setWidth:(CGFloat)width {
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}

- (CGFloat)pdl_height {
    return self.frame.size.height;
}

- (void)pdl_setHeight:(CGFloat)height {
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}

- (CGPoint)pdl_origin {
    return self.frame.origin;
}

- (void)pdl_setOrigin:(CGPoint)origin {
    CGRect rect = self.frame;
    rect.origin = origin;
    self.frame = rect;
}

- (CGSize)pdl_size {
    return self.frame.size;
}

- (void)pdl_setSize:(CGSize)size {
    CGRect rect = self.frame;
    rect.size = size;
    self.frame = rect;
}

- (CGFloat)pdl_centerX {
    return self.center.x;
}

- (void)pdl_setCenterX:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)pdl_centerY {
    return self.center.y;
}

- (void)pdl_setCenterY:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGPoint)pdl_boundsCenter {
    return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
}

- (CGFloat)pdl_boundsCenterX {
    return self.bounds.size.width / 2;
}

- (CGFloat)pdl_boundsCenterY {
    return self.bounds.size.height / 2;
}

- (void)pdl_align {
    CGFloat top = self.pdl_top;
    CGFloat left = self.pdl_left;
    CGFloat width = self.pdl_width;
    CGFloat height = self.pdl_height;

    self.pdl_top = pdl_integralFloat(top);
    self.pdl_left = pdl_integralFloat(left);
    self.pdl_width = pdl_integralFloat(width);
    self.pdl_height = pdl_integralFloat(height);
}

- (CGSize)pdl_sizeThatFitsHeight:(CGSize)size {
    CGFloat width = size.width;
    CGSize sizeThatFits = [self sizeThatFits:size];
    sizeThatFits.width = width;
    return sizeThatFits;
}

- (CGSize)pdl_sizeThatFitsMaxHeight:(CGFloat)maxHeight size:(CGSize)size {
    CGSize sizeThatFits = [self pdl_sizeThatFitsHeight:size];
    if (sizeThatFits.height > maxHeight) {
        sizeThatFits.height = maxHeight;
    }
    return sizeThatFits;
}

- (CGSize)pdl_sizeThatFitsMinHeight:(CGFloat)minHeight size:(CGSize)size {
    CGSize sizeThatFits = [self pdl_sizeThatFitsHeight:size];
    if (sizeThatFits.height < minHeight) {
        sizeThatFits.height = minHeight;
    }
    return sizeThatFits;
}

- (CGSize)pdl_sizeThatSpreads {
    CGSize sizeThatFits = [self sizeThatFits:CGSizeMake(4000, 4000)];
    return sizeThatFits;
}

- (void)pdl_sizeToFitHeight {
    CGFloat width = self.pdl_width;
    [self sizeToFit];
    self.pdl_width = width;
}

- (void)pdl_sizeToFitMaxHeight:(CGFloat)maxHeight {
    [self pdl_sizeToFitHeight];
    if (self.pdl_height > maxHeight) {
        self.pdl_height = maxHeight;
    }
}

- (void)pdl_sizeToFitMinHeight:(CGFloat)minHeight {
    [self pdl_sizeToFitHeight];
    if (self.pdl_height < minHeight) {
        self.pdl_height = minHeight;
    }
}

- (void)pdl_sizeToSpread {
    CGSize size = [self sizeThatFits:CGSizeMake(4000, 4000)];
    self.pdl_size = size;
}

+ (CGPoint)pdl_convertPoint:(CGPoint)point fromView:(UIView *)fromView toView:(UIView *)toView {
    UIView *fromSuper = fromView;
    while (fromSuper) {
        UIView *view = fromSuper.superview;
        if (view) {
            fromSuper = view;
        } else {
            break;
        }
    }
    UIView *toSuper = toView;
    while (toSuper) {
        UIView *view = toSuper.superview;
        if (view) {
            toSuper = view;
        } else {
            break;
        }
    }

    UIWindow *fromWindow = (UIWindow *)fromSuper;
    UIWindow *toWindow = (UIWindow *)toSuper;

    if (fromWindow == nil && toWindow == nil) {
        return point;
    }

    if (fromWindow == toWindow) {
        CGPoint convertedPoint = [toView convertPoint:point fromView:fromView];
        return convertedPoint;
    }

    if (![fromWindow isKindOfClass:[UIWindow class]] || ![toWindow isKindOfClass:[UIWindow class]]) {
        return CGPointMake(INFINITY, INFINITY);
    }

    CGPoint fromWindowPoint = point;
    if (fromWindow != nil) {
        fromWindowPoint = [fromWindow convertPoint:point fromView:fromView];
    }

    CGPoint toWindowPoint = fromWindowPoint;
    if (toWindow != nil) {
        toWindowPoint = [toWindow convertPoint:fromWindowPoint fromWindow:fromWindow];
    } else {
        if (fromWindow != nil) {
            toWindowPoint = [fromWindow convertPoint:fromWindowPoint toWindow:toWindow];
        }
    }

    CGPoint toViewPoint = toWindowPoint;
    if (toWindow != nil) {
        toViewPoint = [toWindow convertPoint:toWindowPoint toView:toView];
    }

    return toViewPoint;
}

+ (CGRect)pdl_convertRect:(CGRect)rect fromView:(UIView *)fromView toView:(UIView *)toView {
    UIView *fromSuper = fromView;
    while (fromSuper) {
        UIView *view = fromSuper.superview;
        if (view) {
            fromSuper = view;
        } else {
            break;
        }
    }
    UIView *toSuper = toView;
    while (toSuper) {
        UIView *view = toSuper.superview;
        if (view) {
            toSuper = view;
        } else {
            break;
        }
    }

    UIWindow *fromWindow = (UIWindow *)fromSuper;
    UIWindow *toWindow = (UIWindow *)toSuper;

    if (fromWindow == nil && toWindow == nil) {
        return rect;
    }

    if (fromWindow == toWindow) {
        CGRect convertedRect = [toView convertRect:rect fromView:fromView];
        return convertedRect;
    }

    if (![fromWindow isKindOfClass:[UIWindow class]] || ![toWindow isKindOfClass:[UIWindow class]]) {
        return CGRectNull;
    }

    CGRect fromWindowRect = rect;
    if (fromWindow != nil) {
        fromWindowRect = [fromWindow convertRect:rect fromView:fromView];
    }

    CGRect toWindowRect = fromWindowRect;
    if (toWindow != nil) {
        toWindowRect = [toWindow convertRect:fromWindowRect fromWindow:fromWindow];
    } else {
        if (fromWindow != nil) {
            toWindowRect = [fromWindow convertRect:fromWindowRect toWindow:toWindow];
        }
    }

    CGRect toViewRect = toWindowRect;
    if (toWindow != nil) {
        toViewRect = [toWindow convertRect:toWindowRect toView:toView];
    }
    
    return toViewRect;
}

@end

@implementation CALayer (PDLGeometry)

- (CGFloat)pdl_left {
    return self.frame.origin.x;
}

- (void)pdl_setLeft:(CGFloat)left {
    CGRect rect = self.frame;
    rect.origin.x = left;
    self.frame = rect;
}

- (CGFloat)pdl_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)pdl_setRight:(CGFloat)right {
    CGRect rect = self.frame;
    rect.origin.x = right - self.frame.size.width;
    self.frame = rect;
}

- (CGFloat)pdl_top {
    return self.frame.origin.y;
}

- (void)pdl_setTop:(CGFloat)top {
    CGRect rect = self.frame;
    rect.origin.y = top;
    self.frame = rect;
}

- (CGFloat)pdl_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)pdl_setBottom:(CGFloat)bottom {
    CGRect rect = self.frame;
    rect.origin.y = bottom - self.frame.size.height;
    self.frame = rect;
}

- (CGFloat)pdl_width {
    return self.frame.size.width;
}

- (void)pdl_setWidth:(CGFloat)width {
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}

- (CGFloat)pdl_height {
    return self.frame.size.height;
}

- (void)pdl_setHeight:(CGFloat)height {
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}

- (CGPoint)pdl_origin {
    return self.frame.origin;
}

- (void)pdl_setOrigin:(CGPoint)origin {
    CGRect rect = self.frame;
    rect.origin = origin;
    self.frame = rect;
}

- (CGSize)pdl_size {
    return self.frame.size;
}

- (void)pdl_setSize:(CGSize)size {
    CGRect rect = self.frame;
    rect.size = size;
    self.frame = rect;
}

- (CGFloat)pdl_positionX {
    return self.position.x;
}

- (void)pdl_setPositionX:(CGFloat)positionX {
    CGPoint position = self.position;
    position.x = positionX;
    self.position = position;
}

- (CGFloat)pdl_positionY {
    return self.position.y;
}

- (void)pdl_setPositionY:(CGFloat)positionY {
    CGPoint position = self.position;
    position.y = positionY;
    self.position = position;
}

- (CGPoint)pdl_boundsPosition {
    return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
}

- (CGFloat)pdl_boundsPositionX {
    return self.bounds.size.width / 2;
}

- (CGFloat)pdl_boundsPositionY {
    return self.bounds.size.height / 2;
}

- (void)pdl_align {
    CGFloat top = self.pdl_top;
    CGFloat left = self.pdl_left;
    CGFloat width = self.pdl_width;
    CGFloat height = self.pdl_height;

    self.pdl_top = pdl_integralFloat(top);
    self.pdl_left = pdl_integralFloat(left);
    self.pdl_width = pdl_integralFloat(width);
    self.pdl_height = pdl_integralFloat(height);
}

+ (CGPoint)pdl_convertPoint:(CGPoint)point fromLayer:(CALayer *)fromLayer toLayer:(CALayer *)toLayer {
    CALayer *fromWindowLayer = fromLayer;
    while (fromWindowLayer) {
        CALayer *windowLayer = fromWindowLayer.superlayer;
        if (windowLayer) {
            fromWindowLayer = windowLayer;
        } else {
            break;
        }
    }

    CGPoint fromWindowPoint = point;
    if (fromWindowLayer) {
        fromWindowPoint = [fromWindowLayer convertPoint:point fromLayer:fromLayer];
    }

    CGPoint toWindowPoint = fromWindowPoint;

    CALayer *toWindowLayer = toLayer;
    while (toWindowLayer) {
        CALayer *windowLayer = toWindowLayer.superlayer;
        if (windowLayer) {
            toWindowLayer = windowLayer;
        } else {
            break;
        }
    }

    CGPoint toLayerPoint = toWindowPoint;
    if (toWindowLayer) {
        toLayerPoint = [toWindowLayer convertPoint:toWindowPoint toLayer:toLayer];
    }

    return toLayerPoint;
}

+ (CGRect)pdl_convertRect:(CGRect)rect fromLayer:(CALayer *)fromLayer toLayer:(CALayer *)toLayer {
    CALayer *fromWindowLayer = fromLayer;
    while (fromWindowLayer) {
        CALayer *windowLayer = fromWindowLayer.superlayer;
        if (windowLayer) {
            fromWindowLayer = windowLayer;
        } else {
            break;
        }
    }

    CGRect fromWindowRect = rect;
    if (fromWindowLayer) {
        fromWindowRect = [fromWindowLayer convertRect:rect fromLayer:fromLayer];
    }

    CGRect toWindowRect = fromWindowRect;

    CALayer *toWindowLayer = toLayer;
    while (toWindowLayer) {
        CALayer *windowLayer = toWindowLayer.superlayer;
        if (windowLayer) {
            toWindowLayer = windowLayer;
        } else {
            break;
        }
    }

    CGRect toLayerRect = toWindowRect;
    if (toWindowLayer) {
        toLayerRect = [toWindowLayer convertRect:toWindowRect toLayer:toLayer];
    }

    return toLayerRect;
}

@end
