//
//  PDLGeometry.h
//  Poodle
//
//  Created by Poodle on 28/06/2015.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat pdl_integralFloat(CGFloat floatNumber);
extern CGFloat pdl_lineWidth(void);

@interface UIView (PDLGeometry)

@property (setter=pdl_setLeft:) CGFloat pdl_left;
@property (setter=pdl_setRight:) CGFloat pdl_right;
@property (setter=pdl_setTop:) CGFloat pdl_top;
@property (setter=pdl_setBottom:) CGFloat pdl_bottom;
@property (setter=pdl_setWidth:) CGFloat pdl_width;
@property (setter=pdl_setHeight:) CGFloat pdl_height;
@property (setter=pdl_setOrigin:) CGPoint pdl_origin;
@property (setter=pdl_setSize:) CGSize pdl_size;
@property (setter=pdl_setCenterX:) CGFloat pdl_centerX;
@property (setter=pdl_setCenterY:) CGFloat pdl_centerY;

@property (readonly) CGPoint pdl_boundsCenter;
@property (readonly) CGFloat pdl_boundsCenterX;
@property (readonly) CGFloat pdl_boundsCenterY;

- (void)pdl_align;

- (CGSize)pdl_sizeThatFitsHeight:(CGSize)size;
- (CGSize)pdl_sizeThatFitsMaxHeight:(CGFloat)maxHeight size:(CGSize)size;
- (CGSize)pdl_sizeThatFitsMinHeight:(CGFloat)minHeight size:(CGSize)size;
- (CGSize)pdl_sizeThatSpreads;

- (void)pdl_sizeToFitHeight;
- (void)pdl_sizeToFitMaxHeight:(CGFloat)maxHeight;
- (void)pdl_sizeToFitMinHeight:(CGFloat)minHeight;
- (void)pdl_sizeToSpread;

+ (CGPoint)pdl_convertPoint:(CGPoint)point fromView:(UIView *)fromView toView:(UIView *)toView;
+ (CGRect)pdl_convertRect:(CGRect)rect fromView:(UIView *)fromView toView:(UIView *)toView;

@end

@interface CALayer (Frame)

@property (setter=pdl_setLeft:) CGFloat pdl_left;
@property (setter=pdl_setRight:) CGFloat pdl_right;
@property (setter=pdl_setTop:) CGFloat pdl_top;
@property (setter=pdl_setBottom:) CGFloat pdl_bottom;
@property (setter=pdl_setWidth:) CGFloat pdl_width;
@property (setter=pdl_setHeight:) CGFloat pdl_height;
@property (setter=pdl_setSize:) CGSize pdl_size;
@property (setter=pdl_setPositionX:) CGFloat pdl_positionX;
@property (setter=pdl_setPositionY:) CGFloat pdl_positionY;

@property (readonly) CGPoint pdl_boundsPosition;
@property (readonly) CGFloat pdl_boundsPositionX;
@property (readonly) CGFloat pdl_boundsPositionY;

- (void)pdl_align;

+ (CGPoint)pdl_convertPoint:(CGPoint)point fromLayer:(CALayer *)fromLayer toLayer:(CALayer *)toLayer;
+ (CGRect)pdl_convertRect:(CGRect)rect fromLayer:(CALayer *)fromLayer toLayer:(CALayer *)toLayer;

@end
