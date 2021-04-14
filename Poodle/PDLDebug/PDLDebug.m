//
//  PDLDebug.m
//  Poodle
//
//  Created by Poodle on 2020/5/21.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLDebug.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "NSObject+PDLMethod.h"
#import "pdl_security.h"

void PDLDebugThreadSafe(NSUInteger threadCount, NSUInteger loopCount, void(^action)(NSUInteger threadIndex, NSUInteger loopIndex), void(^completion)(NSTimeInterval duration)) {
    if (!action) {
        return;
    }

    NSDate *date = [NSDate date];
    dispatch_group_t group = dispatch_group_create();
    for (NSUInteger i = 0; i < threadCount; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            for (NSUInteger j = 0; j < loopCount; j++) {
                action(i, j);
            };
            dispatch_group_leave(group);
        });
    };
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    if (completion) {
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:date];
        completion(duration);
    }
}

#define random_digits_number(n) ({unsigned int __d = arc4random() % (n) + 1;int __b = 1;while (--__d) {__b *= 10;}(arc4random() % (__b * 9) + __b);})

NSUInteger pdl_randomDigitsNumber(NSUInteger digits) {
    NSUInteger d = digits;
    if (d > 9) {
        d = 9;
    }
    return random_digits_number(d);
}

NSString *pdl_randomLengthString(NSUInteger minLength, NSUInteger maxLength) {
    NSUInteger min = minLength;
    NSUInteger max = maxLength;
    if (max > 10000) {
        max = 10000;
    }
    if (min > max) {
        min = max;
    }
    NSUInteger length = min;
    if (max > min) {
        length += arc4random() % (max - min + 1);
    }

    NSString *string = @"1234567890";
    NSString *ret = nil;
    if (length <= string.length) {
        ret = [string substringWithRange:NSMakeRange(0, length)];
    } else {
        ret = [NSString stringWithFormat:@"[%@]", @(length)];
        NSInteger diff = (length - ret.length);
        if (length <= 100) {
            do {
                if (diff > string.length) {
                    ret = [ret stringByAppendingString:string];
                    diff = (length - ret.length);
                } else {
                    ret = [ret stringByAppendingString:[string substringWithRange:NSMakeRange(0, diff)]];
                    break;
                }
            } while (YES);
        } else {
            char *cString = malloc(diff + 1);
            if (!cString) {
                return nil;
            }
            for (NSInteger i = 0; i < diff; i++) {
                NSInteger c = 'a' + (i % 26);
                cString[i] = c;
            }
            cString[diff] = '\0';
            NSString *s = [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
            ret = [ret stringByAppendingString:s];
            free(cString);
        }
    }
    return ret;
}

NSTimeInterval pdl_performance(void(^code)(void)) {
    NSTimeInterval begin = CACurrentMediaTime();
    code();
    NSTimeInterval end = CACurrentMediaTime();
    NSTimeInterval diff = end - begin;
    return diff;
}

void pdl_performance_log(void(^code)(void)) {
    NSTimeInterval diff = pdl_performance(code);
    NSLog(@"pdl_performance: %@", pdl_durationString(diff));
}

NSString *pdl_durationString(NSTimeInterval duration) {
    NSString *durationString = @"0";
    if (duration >= 1) {
        durationString = [NSString stringWithFormat:@"%.3fs", duration];
    } else {
        duration *= 1000;
        if (duration >= 1) {
            durationString = [NSString stringWithFormat:@"%.3fms", duration];
        } else {
            duration *= 1000;
            if (duration >= 1) {
                durationString = [NSString stringWithFormat:@"%.3fus", duration];
            } else {
                duration *= 1000;
                durationString = [NSString stringWithFormat:@"%.3fns", duration];
            }
        }
    }
    return durationString;
}

void pdl_debug_halt(void) {
    if (pdl_is_tracing()) {
        @try {
            NSException *e = [NSException exceptionWithName:@"!" reason:nil userInfo:nil];
            [e raise];
        } @catch (NSException *exception) {
            ;
        } @finally {
            ;
        }
    }
}

static void pdl_instanceBefore(__unsafe_unretained id self, SEL _cmd) {
    printf("-[<%s:%p> %s]\n", class_getName(object_getClass(self)), self, sel_getName(_cmd));
}

static void pdl_classBefore(__unsafe_unretained id self, SEL _cmd) {
    printf("+[<%s:%p> %s]\n", class_getName(object_getClass(self)), self, sel_getName(_cmd));
}

NSInteger pdl_logInstanceMethods(Class aClass) {
    return [aClass pdl_addInstanceMethodsBeforeAction:(IMP)&pdl_instanceBefore afterAction:NULL];
}

NSInteger pdl_logClassMethods(Class aClass) {
    return [object_getClass(aClass) pdl_addInstanceMethodsBeforeAction:(IMP)&pdl_classBefore afterAction:NULL];
}
