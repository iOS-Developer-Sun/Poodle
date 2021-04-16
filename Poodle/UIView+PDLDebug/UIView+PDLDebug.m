//
//  UIView+PDLDebug.m
//  Poodle
//
//  Created by Poodle on 4/13/16.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "UIView+PDLDebug.h"
#import "NSObject+PDLImplementationInterceptor.h"
#import "NSObject+PDLExtension.h"

/*
@interface UIView (Private)

+ (BOOL)_toolsDebugColorViewBounds;
+ (void)_enableToolsDebugColorViewBounds:(BOOL)enabled;

+ (BOOL)_toolsDebugAlignmentRects;
+ (void)_enableToolsDebugAlignmentRects:(BOOL)enabled;

@end
 */

@implementation UIView (PDLDebug)

static BOOL pdl_debugEnable = NO;

static BOOL _toolsDebugColorViewBounds(void) {
    BOOL colorViewBounds = ((BOOL(*)(id, SEL))objc_msgSend)(objc_getClass("UIView"), sel_registerName("_toolsDebugColorViewBounds"));
    return colorViewBounds;
}

static void _enableToolsDebugColorViewBounds(BOOL enabled) {
    ((void(*)(id, SEL, BOOL))objc_msgSend)(objc_getClass("UIView"), sel_registerName("_enableToolsDebugColorViewBounds:"), enabled);
}

static BOOL _toolsDebugAlignmentRects(void) {
    BOOL alignmentRects = ((BOOL(*)(id, SEL))objc_msgSend)(objc_getClass("UIView"), sel_registerName("_toolsDebugAlignmentRects"));
    return alignmentRects;
}

static void _enableToolsDebugAlignmentRects(BOOL enabled) {
    ((void(*)(id, SEL, BOOL))objc_msgSend)(objc_getClass("UIView"), sel_registerName("_enableToolsDebugAlignmentRects:"), enabled);
}

static void visualEffectViewAddSubviewPositionedRelativeTo(__unsafe_unretained UIVisualEffectView *self, SEL _cmd, __unsafe_unretained UIView *subview, NSInteger position, __unsafe_unretained UIView *relativeView) {
    PDLImplementationInterceptorRecover(_cmd);
    if (_toolsDebugAlignmentRects()) {
        ptrdiff_t offset = [UIVisualEffectView pdl_ivarOffsetForName:"_effectViewFlags"];
        void *ptr = (__bridge void *)(self);
        unsigned int flags = *(unsigned int *)(ptr + offset);
        BOOL layingOutFromConstraints = (flags & (1 << 6));
        if (!layingOutFromConstraints) {
            return;
        }
    }
    ((typeof(&visualEffectViewAddSubviewPositionedRelativeTo))_imp)(self, _cmd, subview, position, relativeView);
}

static CGFloat textViewBaselineOffsetFromBottom(__unsafe_unretained UITextView *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    if (_toolsDebugAlignmentRects()) {
        ptrdiff_t offset = [UIVisualEffectView pdl_ivarOffsetForName:"_viewFlags"];
        void *ptr = (__bridge void *)(self);
        unsigned long long flags = *(unsigned long long *)(ptr + offset);
        BOOL isUpdatingSubviews = (flags & (1ll << 55));
        if (!isUpdatingSubviews) {
            return 0;
        }
    }
    return ((typeof(&textViewBaselineOffsetFromBottom))_imp)(self, _cmd);
}

+ (PDLViewDebugType)pdl_viewDebugType {
    if (!pdl_debugEnable) {
        return PDLViewDebugTypeNone;
    }

    BOOL colorViewBounds = _toolsDebugColorViewBounds();
    if (colorViewBounds) {
        return PDLViewDebugTypeColorViewBounds;
    }

    BOOL alignmentRects = _toolsDebugAlignmentRects();
    if (alignmentRects) {
        return PDLViewDebugTypeAlignmentRects;
    }

    return PDLViewDebugTypeNone;
}

+ (void)pdl_setViewDebugType:(PDLViewDebugType)pdl_viewDebugType {
    if (!pdl_debugEnable) {
        return;
    }

    if (pdl_viewDebugType == PDLViewDebugTypeColorViewBounds) {
        _enableToolsDebugAlignmentRects(NO);
        _enableToolsDebugColorViewBounds(YES);
    } else if (pdl_viewDebugType == PDLViewDebugTypeAlignmentRects) {
        _enableToolsDebugColorViewBounds(NO);
        _enableToolsDebugAlignmentRects(YES);
    } else {
        _enableToolsDebugColorViewBounds(NO);
        _enableToolsDebugAlignmentRects(NO);
    }
}

+ (BOOL)pdl_debugEnable {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL enabled = YES;
        enabled &= [UIVisualEffectView pdl_interceptSelector:sel_registerName("_addSubview:positioned:relativeTo:") withInterceptorImplementation:(IMP)&visualEffectViewAddSubviewPositionedRelativeTo];
        enabled &= [UITextView pdl_interceptSelector:sel_registerName("_baselineOffsetFromBottom") withInterceptorImplementation:(IMP)&textViewBaselineOffsetFromBottom];
        pdl_debugEnable = enabled;
    });
    return pdl_debugEnable;
}

@end
