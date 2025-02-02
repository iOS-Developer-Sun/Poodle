//
//  PDLColor.m
//  Poodle
//
//  Created by Poodle on 10/07/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLColor.h"

UIColor *PDLColorTextColor(void) {
    UIColor *textColor = nil;
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 13) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        textColor = [UIColor labelColor];
#pragma clang diagnostic pop
    } else {
        textColor = [UIColor blackColor];
    }
    return textColor;
}

UIColor *PDLColorBackgroundColor(void) {
    UIColor *backgroundColor = nil;
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 13) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        backgroundColor = [UIColor systemBackgroundColor];
#pragma clang diagnostic pop
    } else {
        backgroundColor = [UIColor whiteColor];
    }
    return backgroundColor;
}

UIColor *PDLColorRandomColor(void) {
    CGFloat r = arc4random() % 256 / 255.0;
    CGFloat g = arc4random() % 256 / 255.0;
    CGFloat b = arc4random() % 256 / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}
