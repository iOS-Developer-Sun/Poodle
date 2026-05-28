//
//  PDLProcessInfo.m
//  Poodle
//
//  Created by Poodle on 2021/2/1.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLProcessInfo.h"
#import <sys/sysctl.h>
#import <sys/types.h>
#import <QuartzCore/QuartzCore.h>
#import "NSObject+PDLImplementationInterceptor.h"

@interface PDLProcessInfo ()

@property (copy) NSDictionary<NSString *, NSString *> *_environment;
@property (copy) NSArray<NSString *> *_arguments;

@end

@implementation PDLProcessInfo

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        pid_t pid = [[NSProcessInfo processInfo] processIdentifier];
        int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, pid };
        struct kinfo_proc proc;
        size_t size = sizeof(proc);
        int ret = sysctl(mib, 4, &proc, &size, NULL, 0);
        NSDate *now = [NSDate date];
        NSTimeInterval current = CACurrentMediaTime();
        NSTimeInterval processStartMediaTime = 0;
        NSDate *processStartDate = nil;
        if (ret == 0) {
            NSTimeInterval timeInterval = proc.kp_proc.p_starttime.tv_sec + proc.kp_proc.p_starttime.tv_usec * 1e-6;
            processStartDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            NSTimeInterval diff = [now timeIntervalSinceDate:processStartDate];
            processStartMediaTime = current - diff;
        } else {
            processStartDate = now;
            processStartMediaTime = current;
        }
        _processStartDate = processStartDate;
        _processStartMediaTime = processStartMediaTime;
    }
    return self;
}

static id NSProcessInfoEnvironment(__unsafe_unretained NSProcessInfo *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    NSDictionary *dictionary = ((typeof(&NSProcessInfoEnvironment))_imp)(self, _cmd);
    NSDictionary *extra = [PDLProcessInfo sharedInstance].environment;
    if (extra.count > 0) {
        NSMutableDictionary *m = [dictionary ?: @{} mutableCopy];
        [m addEntriesFromDictionary:extra];
        dictionary = [m copy];
    }
    return dictionary;
}

static id NSProcessInfoArgments(__unsafe_unretained NSProcessInfo *self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    NSArray *array = ((typeof(&NSProcessInfoArgments))_imp)(self, _cmd);
    NSArray *extra = [PDLProcessInfo sharedInstance].arguments;
    if (extra.count > 0) {
        NSMutableArray *m = [array ?: @[] mutableCopy];
        [m addObjectsFromArray:extra];
        array = [m copy];
    }
    return array;
}

- (void)setup {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id processInfo = object_getClass([NSProcessInfo processInfo]);
        BOOL ret = [processInfo pdl_interceptSelector:@selector(environment) withInterceptorImplementation:(IMP)&NSProcessInfoEnvironment];
        ret = ret && [processInfo pdl_interceptSelector:@selector(arguments) withInterceptorImplementation:(IMP)&NSProcessInfoArgments];
        NSAssert(ret, @"NSProcessInfo");
    });
}

- (NSDictionary<NSString *,NSString *> *)environment {
    return self._environment;
}

- (void)setEnvironment:(NSDictionary<NSString *,NSString *> *)environment
{
    [self setup];
    self._environment = environment;
}

- (NSArray<NSString *> *)arguments {
    return self._arguments;
}

- (void)setArguments:(NSArray<NSString *> *)arguments {
    [self setup];
    self._arguments = arguments;
}

@end
