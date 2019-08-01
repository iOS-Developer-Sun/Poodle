//
//  PDLScreenDebugger.h
//  Poodle
//
//  Created by Poodle on 15/10/2016.
//  Copyright © 2016 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDLScreenDebugger : NSObject

+ (BOOL)isDebugging;
+ (void)startDebuggingView:(UIView *)view;
+ (void)startDebuggingLayer:(CALayer *)layer;
+ (void)stopDebugging;

+ (UIView *)hitTestView:(UIView *)view x:(CGFloat)x y:(CGFloat)y;

@end
