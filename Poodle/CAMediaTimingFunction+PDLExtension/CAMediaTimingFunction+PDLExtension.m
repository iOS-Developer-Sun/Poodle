//
//  CAMediaTimingFunction+PDLExtension.m
//  Poodle
//
//  Created by Poodle on 2019/2/20.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "CAMediaTimingFunction+PDLExtension.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation CAMediaTimingFunction (PDLExtension)

#ifdef DEBUG
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault] pdl_solve:0.5];
    });
}
#endif

static SEL pdl_solveForInputSelector(void) {
    static SEL sel = NULL;
    if (sel == NULL) {
        char sel_str[] = {'_', 's', 'o', 'l', 'v', 'e', 'F', 'o', 'r', 'I', 'n', 'p', 'u', 't', ':', '\0'};
        sel = sel_registerName(sel_str);
#ifdef DEBUG
        assert(sel_isEqual(sel, sel_registerName("_solveForInput:")));
#endif
    }
    return sel;
}

- (NSArray *)pdl_controlPoints {
    NSMutableArray *controlPoints = [NSMutableArray array];
    for (NSInteger i = 0; i < 4; i++) {
        float value[2];
        [self getControlPointAtIndex:i values:value];
        CGPoint controlPoint = CGPointMake(value[0], value[1]);
        [controlPoints addObject:@(controlPoint)];
    }
    return controlPoints.copy;
}

- (float)pdl_solve:(float)input {
    SEL sel = pdl_solveForInputSelector();
    float result = ((float(*)(id, SEL, float))objc_msgSend)(self, sel, input);
    return result;
}

- (float)pdl_velocity:(float)input {
    float from = input;
    float to = input;
    float xOffset = 0.001;
    if (input + xOffset > 1) {
        from = input - xOffset;
    } else {
        to = input + xOffset;
    }
    float yOffset = [self pdl_solve:to] - [self pdl_solve:from];
    float velocity = yOffset / xOffset;
    return velocity;
}

@end
