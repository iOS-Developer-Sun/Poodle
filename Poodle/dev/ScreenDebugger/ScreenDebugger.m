//
//  ScreenDebugger.m
//  Sunzj
//
//  Created by sunzj on 15/10/2016.
//  Copyright © 2016 sunzj. All rights reserved.
//

#import "ScreenDebugger.h"
#import "ScreenDebuggerWindow.h"
#import "ViewDebuggerWindow.h"
#import "LayerDebuggerWindow.h"

@interface ScreenDebugger ()

@end

@implementation ScreenDebugger

static ScreenDebuggerWindow *ScreenDebuggerDebuggerWindow;

+ (BOOL)isDebugging {
    return (ScreenDebuggerDebuggerWindow != nil);
}

+ (void)startDebuggingView:(UIView *)view {
    if ([self isDebugging]) {
        return;
    }

    ViewDebuggerWindow *viewDebuggerWindow = [[ViewDebuggerWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    viewDebuggerWindow.debuggingView = view;

    [viewDebuggerWindow makeKeyAndVisible];

    ScreenDebuggerDebuggerWindow = viewDebuggerWindow;

    [ScreenDebuggerDebuggerWindow.closeButton addTarget:self action:@selector(stopDebugging) forControlEvents:UIControlEventTouchUpInside];
}

+ (void)startDebuggingLayer:(CALayer *)layer {
    if ([self isDebugging]) {
        return;
    }

    LayerDebuggerWindow *layerDebuggerWindow = [[LayerDebuggerWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    layerDebuggerWindow.debuggingLayer = layer;

    [layerDebuggerWindow makeKeyAndVisible];

    ScreenDebuggerDebuggerWindow = layerDebuggerWindow;

    [ScreenDebuggerDebuggerWindow.closeButton addTarget:self action:@selector(stopDebugging) forControlEvents:UIControlEventTouchUpInside];
}

+ (void)stopDebugging {
    if ([self isDebugging] == NO) {
        return;
    }

    ScreenDebuggerDebuggerWindow.hidden = YES;
    ScreenDebuggerDebuggerWindow = nil;
}

+ (UIView *)hitTestView:(UIView *)view x:(CGFloat)x y:(CGFloat)y {
    UIView *hitTestView = [view hitTest:CGPointMake(x, y) withEvent:nil];
    return hitTestView;
}

@end
