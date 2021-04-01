//
//  CAAnimation+PDLExtension.m
//  Poodle
//
//  Created by Poodle on 2019/2/20.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "CAAnimation+PDLExtension.h"
#import <objc/runtime.h>

@interface PDLCAAnimationDelegate : NSObject <CAAnimationDelegate>

@property (atomic, copy) void (^didStartAction)(CAAnimation *animation);
@property (atomic, copy) void (^didStopAction)(CAAnimation *animation, BOOL finished);

@end

@implementation PDLCAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim {
    void (^beginning)(CAAnimation *animation) = self.didStartAction;
    if (beginning) {
        beginning(anim);
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    void (^completion)(CAAnimation *animation, BOOL finished) = self.didStopAction;
    if (completion) {
        completion(anim, flag);
    }
}

@end

@implementation CAAnimation (PDLExtension)

static void *CAAnimationDelegateKey = NULL;

- (void (^)(CAAnimation *))pdl_didStartAction {
    PDLCAAnimationDelegate *delegate = objc_getAssociatedObject(self, &CAAnimationDelegateKey);
    return delegate.didStartAction;
}

- (void)pdl_setDidStartAction:(void (^)(CAAnimation *))pdl_didStartAction {
    PDLCAAnimationDelegate *delegate = objc_getAssociatedObject(self, &CAAnimationDelegateKey);
    if (delegate == nil) {
        delegate = [[PDLCAAnimationDelegate alloc] init];
        objc_setAssociatedObject(self, &CAAnimationDelegateKey, delegate, OBJC_ASSOCIATION_RETAIN);
        self.delegate = delegate;
    }
    delegate.didStartAction = pdl_didStartAction;
}

- (void (^)(CAAnimation *, BOOL))pdl_didStopAction {
    PDLCAAnimationDelegate *delegate = objc_getAssociatedObject(self, &CAAnimationDelegateKey);
    return delegate.didStopAction;
}

- (void)pdl_setDidStopAction:(void (^)(CAAnimation *, BOOL))pdl_didStopAction {
    PDLCAAnimationDelegate *delegate = objc_getAssociatedObject(self, &CAAnimationDelegateKey);
    if (delegate == nil) {
        delegate = [[PDLCAAnimationDelegate alloc] init];
        objc_setAssociatedObject(self, &CAAnimationDelegateKey, delegate, OBJC_ASSOCIATION_RETAIN);
        self.delegate = delegate;
    }
    delegate.didStopAction = pdl_didStopAction;
}

@end
