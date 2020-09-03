//
//  PDLInitialization.m
//  Poodle
//
//  Created by Poodle on 2020/9/3.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLInitialization.h"
#import "NSObject+PDLImplementationInterceptor.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

@interface PDLInitialization ()

@property (nonatomic, assign) CFTimeInterval duration;
@property (nonatomic, unsafe_unretained) Class aClass;
@property (nonatomic, assign) IMP imp;

@end

@implementation PDLInitialization

- (NSString *)description {
    NSString *durationString = @"0";
    CFTimeInterval duration = self.duration;
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
    NSString *description = [NSString stringWithFormat:@"[%@, %p, %@]", self.aClass, self.imp, durationString];
    return [[super description] stringByAppendingString:description];
}

static NSMutableArray *_loaders = nil;
static NSUInteger _count = 0;

static void pdl_initializeLoad(id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    CFTimeInterval begin = CACurrentMediaTime();
    ((typeof(&pdl_initializeLoad))_imp)(self, _cmd);
    CFTimeInterval end = CACurrentMediaTime();
    CFTimeInterval diff = end - begin;
    PDLInitialization *initialization = [[PDLInitialization alloc] init];
    initialization.duration = diff;
    initialization.aClass = self;
    initialization.imp = _imp;
    [_loaders addObject:initialization];
}

+ (NSUInteger)count {
    return _count;
}

+ (NSUInteger)preload {
    assert(_loaders == nil);

    _loaders = [NSMutableArray array];

    NSInteger count = 0;
    unsigned int classCount = 0;
    Class *classList = objc_copyClassList(&classCount);
    SEL loadSelector = sel_registerName("load");
    IMP loadImp = (IMP)&pdl_initializeLoad;
    for (unsigned int i = 0; i < classCount; i++) {
        Class aClass = classList[i];
        unsigned int methodCount = 0;
        Method *methodList = class_copyMethodList(object_getClass(aClass), &methodCount);
        for (unsigned int i = 0; i < methodCount; i++) {
            Method method = methodList[i];
            SEL sel = method_getName(method);
            if (sel != loadSelector) {
                continue;
            }
            assert(method_getImplementation(method) != loadImp);
            BOOL ret = pdl_interceptMethod(aClass, method, @(NO), ^IMP(NSNumber *__autoreleasing *isStructRetNumber, void **data) {
                return loadImp;
            });
            if (ret) {
                count++;
            } else {
                assert(ret);
            }
        }
        free(methodList);
    }
    free(classList);
    _count = count;
    return count;
}

+ (NSArray *)loaders {
    return _loaders.copy;
}

@end
