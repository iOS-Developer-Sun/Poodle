//
//  ScreenDebugger.h
//  Sunzj
//
//  Created by sunzj on 15/10/2016.
//  Copyright © 2016 sunzj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScreenDebugger : NSObject

+ (BOOL)isDebugging;
+ (void)startDebuggingView:(UIView *)view;
+ (void)startDebuggingLayer:(CALayer *)layer;
+ (void)stopDebugging;

+ (UIView *)hitTestView:(UIView *)view x:(CGFloat)x y:(CGFloat)y;

@end
