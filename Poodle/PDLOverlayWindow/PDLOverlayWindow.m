//
//  PDLOverlayWindow.m
//  Poodle
//
//  Created by Poodle on 2021/3/18.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLOverlayWindow.h"
#import <objc/runtime.h>

@implementation PDLOverlayWindow

__attribute__((visibility("hidden")))
static BOOL _canAffectStatusBarAppearance(__unsafe_unretained id self, SEL _cmd) {
    return NO;
}

__attribute__((visibility("hidden")))
static BOOL _canBecomeKeyWindow(__unsafe_unretained id self, SEL _cmd) {
    return NO;
}

+ (void)initialize {
    if (self == [PDLOverlayWindow self]) {
        Method m = class_getInstanceMethod(self, @selector(hitTestSelfEnabled));
        const char *typeEncoding = method_getTypeEncoding(m);
        {
            volatile char s[20];
            s[0] = '_';
            s[1] = 'c';
            s[2] = 'a';
            s[3] = 'n';
            s[4] = 'B';
            s[5] = 'e';
            s[6] = 'c';
            s[7] = 'o';
            s[8] = 'm';
            s[9] = 'e';
            s[10] = 'K';
            s[11] = 'e';
            s[12] = 'y';
            s[13] = 'W';
            s[14] = 'i';
            s[15] = 'n';
            s[16] = 'd';
            s[17] = 'o';
            s[18] = 'w';
            s[19] = '\0';
            class_addMethod(self, sel_registerName((const char *)s), (IMP)&_canAffectStatusBarAppearance, typeEncoding);
        }
        {
            volatile char s[30];
            s[0] = '_';
            s[1] = 'c';
            s[2] = 'a';
            s[3] = 'n';
            s[4] = 'A';
            s[5] = 'f';
            s[6] = 'f';
            s[7] = 'e';
            s[8] = 'c';
            s[9] = 't';
            s[10] = 'S';
            s[11] = 't';
            s[12] = 'a';
            s[13] = 't';
            s[14] = 'u';
            s[15] = 's';
            s[16] = 'B';
            s[17] = 'a';
            s[18] = 'r';
            s[19] = 'A';
            s[20] = 'p';
            s[21] = 'p';
            s[22] = 'e';
            s[23] = 'a';
            s[24] = 'r';
            s[25] = 'a';
            s[26] = 'n';
            s[27] = 'c';
            s[28] = 'e';
            s[29] = '\0';
            class_addMethod(self, sel_registerName((const char *)s), (IMP)&_canBecomeKeyWindow, typeEncoding);
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = CGFLOAT_MAX;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.windowLevel = CGFLOAT_MAX;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        if (!self.hitTestSelfEnabled) {
            view = nil;
        }
    }
    return view;
}

@end
