//
//  PDLScreenDebugger.m
//  Poodle
//
//  Created by Poodle on 15/10/2016.
//  Copyright © 2016 Poodle. All rights reserved.
//

#import "PDLScreenDebugger.h"
#import "PDLScreenDebuggerWindow.h"
#import "PDLViewDebuggerWindow.h"
#import "PDLLayerDebuggerWindow.h"

@interface PDLScreenDebugger ()

@end

@implementation PDLScreenDebugger

static PDLScreenDebuggerWindow *PDLScreenDebuggerDebuggerWindow;

+ (BOOL)isDebugging {
    return (PDLScreenDebuggerDebuggerWindow != nil);
}

+ (void)startDebuggingView:(UIView *)view {
    if ([self isDebugging]) {
        return;
    }

    PDLViewDebuggerWindow *viewDebuggerWindow = [[PDLViewDebuggerWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    viewDebuggerWindow.debuggingView = view;

    [viewDebuggerWindow makeKeyAndVisible];

    PDLScreenDebuggerDebuggerWindow = viewDebuggerWindow;

    [PDLScreenDebuggerDebuggerWindow.closeButton addTarget:self action:@selector(stopDebugging) forControlEvents:UIControlEventTouchUpInside];
}

+ (void)startDebuggingLayer:(CALayer *)layer {
    if ([self isDebugging]) {
        return;
    }

    PDLLayerDebuggerWindow *layerDebuggerWindow = [[PDLLayerDebuggerWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    layerDebuggerWindow.debuggingLayer = layer;

    [layerDebuggerWindow makeKeyAndVisible];

    PDLScreenDebuggerDebuggerWindow = layerDebuggerWindow;

    [PDLScreenDebuggerDebuggerWindow.closeButton addTarget:self action:@selector(stopDebugging) forControlEvents:UIControlEventTouchUpInside];
}

+ (void)stopDebugging {
    if ([self isDebugging] == NO) {
        return;
    }

    PDLScreenDebuggerDebuggerWindow.hidden = YES;
    PDLScreenDebuggerDebuggerWindow = nil;
}

+ (UIView *)hitTestView:(UIView *)view x:(CGFloat)x y:(CGFloat)y {
    UIView *hitTestView = [view hitTest:CGPointMake(x, y) withEvent:nil];
    return hitTestView;
}

@end
