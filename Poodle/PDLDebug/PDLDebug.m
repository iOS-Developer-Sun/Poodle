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
#import <mach/mach.h>
#import "NSObject+PDLMethod.h"
#import "pdl_security.h"

__attribute__((used))
void pdl_debugThreadSafe(NSUInteger threadCount, NSUInteger loopCount, void(^action)(NSUInteger threadIndex, NSUInteger loopIndex), void(^completion)(NSTimeInterval duration)) {
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

__attribute__((used))
NSUInteger pdl_randomDigitsNumber(NSUInteger digits) {
    NSUInteger d = digits;
    if (d > 9) {
        d = 9;
    }
    return random_digits_number(d);
}

__attribute__((used))
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

__attribute__((used))
NSTimeInterval pdl_performance(void(^code)(void)) {
    NSTimeInterval begin = CACurrentMediaTime();
    code();
    NSTimeInterval end = CACurrentMediaTime();
    NSTimeInterval diff = end - begin;
    return diff;
}

__attribute__((used))
void pdl_performance_log(void(^code)(void)) {
    NSTimeInterval diff = pdl_performance(code);
    NSLog(@"pdl_performance: %@", pdl_durationString(diff));
}

__attribute__((used))
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

__attribute__((used))
void pdl_debug_halt(void) {
    if (pdl_is_tracing()) {
        @try {
            NSException *e = [NSException exceptionWithName:@"!" reason:nil userInfo:nil];
            [e raise];
        } @catch (NSException *exception) {
            CFBridgingRelease((__bridge CFTypeRef _Nullable)(exception));
        } @finally {
            ;
        }
    }
}

__attribute__((used))
static void pdl_instanceBefore(__unsafe_unretained id self, SEL _cmd, void *sp) {
    PDLImplementationInterceptorRecover(_cmd);
    printf("-[<%s:%p> %s]\n", class_getName(object_getClass(self)), self, sel_getName(_cmd));
}

__attribute__((used))
static void pdl_classBefore(__unsafe_unretained id self, SEL _cmd, void *sp) {
    PDLImplementationInterceptorRecover(_cmd);
    printf("+[<%s:%p> %s]\n", class_getName(object_getClass(self)), self, sel_getName(_cmd));
}

__attribute__((used))
NSInteger pdl_logInstanceMethods(Class aClass) {
    return [aClass pdl_addInstanceMethodsBeforeAction:(PDLMethodAction)&pdl_instanceBefore afterAction:NULL];
}

__attribute__((used))
NSInteger pdl_logClassMethods(Class aClass) {
    return [object_getClass(aClass) pdl_addInstanceMethodsBeforeAction:(PDLMethodAction)&pdl_classBefore afterAction:NULL];
}

static void enumerate_threads(void *data, void(*function)(void *, thread_t)) {
    thread_array_t thread_list = NULL;
    mach_msg_type_number_t thread_count = 0;
    if (task_threads(mach_task_self(), &thread_list, &thread_count) != KERN_SUCCESS) {
        return;
    }

    for (mach_msg_type_number_t i = 0; i < thread_count; i++) {
        function(data, thread_list[i]);
    }

    vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
}

static void suspendOtherThreads(mach_port_t thread, mach_port_t each) {
    if (thread != each) {
        thread_suspend(each);
    }
}

static void resumeOtherThreads(mach_port_t thread, mach_port_t each) {
    if (thread != each) {
        thread_resume(each);
    }
}

static void resumeAllThreads(mach_port_t thread, mach_port_t each) {
    thread_resume(each);
}

__attribute__((used))
void pdl_suspendThread(mach_port_t thread) {
    thread_suspend(thread);
}

__attribute__((used))
void pdl_resumeThread(mach_port_t thread) {
    thread_resume(thread);
}

__attribute__((used))
mach_port_t pdl_suspendOtherThreads(void) {
    mach_port_t thread_self = mach_thread_self();
    enumerate_threads((void *)(unsigned long)thread_self, (void (*)(void *, thread_t))&suspendOtherThreads);
    return thread_self;
}

__attribute__((used))
mach_port_t pdl_resumeOtherThreads(void) {
    mach_port_t thread_self = mach_thread_self();
    enumerate_threads((void *)(unsigned long)thread_self, (void (*)(void *, thread_t))&resumeOtherThreads);
    return thread_self;
}

__attribute__((used))
void pdl_resumeAllThreads(void) {
    enumerate_threads(0, (void (*)(void *, thread_t))&resumeAllThreads);
}
