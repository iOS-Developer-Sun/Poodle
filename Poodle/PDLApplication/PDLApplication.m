//
//  PDLApplication.m
//  Poodle
//
//  Created by Poodle on 2021/3/21.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLApplication.h"
#import <objc/message.h>

@implementation PDLApplication

+ (void)exitApplication {
    [UIView animateWithDuration:[CATransaction animationDuration] animations:^{
        NSArray *windows = [UIApplication sharedApplication].windows;
        for (UIWindow *window in windows) {
            window.alpha = 0;
        }
    } completion:^(BOOL finished) {
        [UIApplication sharedApplication].statusBarHidden = YES;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self terminate];
    });
}

+ (void)terminate {
    static char s[21];
    s[0] = '_';
    s[1] = 't';
    s[2] = 'e';
    s[3] = 'r';
    s[4] = 'm';
    s[5] = 'i';
    s[6] = 'n';
    s[7] = 'a';
    s[8] = 't';
    s[9] = 'e';
    s[10] = 'W';
    s[11] = 'i';
    s[12] = 't';
    s[13] = 'h';
    s[14] = 'S';
    s[15] = 't';
    s[16] = 'a';
    s[17] = 't';
    s[18] = 'u';
    s[19] = 's';
    s[20] = '\0';
    SEL sel = sel_registerName(s);
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:sel]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            exit(0);
        });
        ((void(*)(id, SEL, NSInteger))objc_msgSend)(application, sel, 0);
    } else {
        exit(0);
    }
}

@end
