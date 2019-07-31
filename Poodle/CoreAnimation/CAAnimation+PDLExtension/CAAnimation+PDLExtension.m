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

@property (atomic, copy) void (^beginning)(CAAnimation *animation);
@property (atomic, copy) void (^completion)(CAAnimation *animation, BOOL finished);

@end

@implementation PDLCAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim {
    void (^beginning)(CAAnimation *animation) = self.beginning;
    if (beginning) {
        beginning(anim);
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    void (^completion)(CAAnimation *animation, BOOL finished) = self.completion;
    if (completion) {
        completion(anim, flag);
    }
}

@end

@implementation CAAnimation (PDLExtension)

static void *CAAnimationDelegateKey = NULL;

- (void (^)(CAAnimation *))pdl_beginning {
    PDLCAAnimationDelegate *delegate = objc_getAssociatedObject(self, &CAAnimationDelegateKey);
    return delegate.beginning;
}

- (void)setPdl_beginning:(void (^)(CAAnimation *))pdl_beginning {
    PDLCAAnimationDelegate *delegate = objc_getAssociatedObject(self, &CAAnimationDelegateKey);
    if (delegate == nil) {
        delegate = [[PDLCAAnimationDelegate alloc] init];
        objc_setAssociatedObject(self, &CAAnimationDelegateKey, delegate, OBJC_ASSOCIATION_RETAIN);
        self.delegate = delegate;
    }
    delegate.beginning = pdl_beginning;
}

- (void (^)(CAAnimation *, BOOL))pdl_completion {
    PDLCAAnimationDelegate *delegate = objc_getAssociatedObject(self, &CAAnimationDelegateKey);
    return delegate.completion;
}

- (void)setPdl_completion:(void (^)(CAAnimation *, BOOL))pdl_completion {
    PDLCAAnimationDelegate *delegate = objc_getAssociatedObject(self, &CAAnimationDelegateKey);
    if (delegate == nil) {
        delegate = [[PDLCAAnimationDelegate alloc] init];
        objc_setAssociatedObject(self, &CAAnimationDelegateKey, delegate, OBJC_ASSOCIATION_RETAIN);
        self.delegate = delegate;
    }
    delegate.completion = pdl_completion;
}

@end
