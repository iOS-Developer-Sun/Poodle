//
//  NSObject+PDLAllocation.m
//  Poodle
//
//  Created by Poodle on 2020/6/18.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "NSObject+PDLAllocation.h"
#import "NSObject+PDLImplementationInterceptor.h"
#import "PDLBacktrace.h"

#if __has_feature(objc_arc)
#error This file must be compiled with flag "-fno-objc-arc"
#endif

static PDLAllocationPolicy _policy;

#pragma mark - trace info

@interface PDLAllocationInfo : NSObject

@property (nonatomic, unsafe_unretained) id object;
@property (nonatomic, unsafe_unretained) Class cls;
@property (nonatomic, strong) PDLBacktrace *backtraceAlloc;
@property (nonatomic, strong) PDLBacktrace *backtraceDealloc;
@property (nonatomic, assign) BOOL live;
@property (nonatomic, assign) unsigned int hiddenCount;

@end

@implementation PDLAllocationInfo

- (instancetype)initWithObject:(__unsafe_unretained id)object {
    self = [super init];
    if (self) {
        _object = object;
        _cls = object_getClass(object);
        _live = YES;
        _hiddenCount = [PDLAllocationInfo pdl_allocationRecordHiddenCount];
    }
    return self;
}

- (void)dealloc {
    [_backtraceAlloc release];
    [_backtraceDealloc release];

    [super dealloc];
}

- (void)recordAlloc {
    PDLBacktrace *bt = [[PDLBacktrace alloc] init];
    bt.name = [NSString stringWithFormat:@"alloc_%s_%p(%s)", class_getName(_cls), _object, class_getName(object_getClass(_object))];
    [bt record:self.hiddenCount];
    self.backtraceAlloc = bt;
    [bt release];
}

- (void)clearAlloc {
    self.backtraceAlloc = nil;
}

- (void)recordDealloc {
    PDLBacktrace *bt = [[PDLBacktrace alloc] init];
    bt.name = [NSString stringWithFormat:@"dealloc_%s_%p(%s)", class_getName(_cls), _object, class_getName(object_getClass(_object))];
    [bt record:self.hiddenCount];
    self.backtraceDealloc = bt;
    [bt release];
}

- (void)clearDealloc {
    self.backtraceDealloc = nil;
}

#pragma mark - debug

+ (NSMutableSet *)uncaughtClassesMap {
    static NSMutableSet *uncaughtClassesMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uncaughtClassesMap = [NSMutableSet set];
#if !__has_feature(objc_arc)
        [uncaughtClassesMap retain];
#endif
    });
    return uncaughtClassesMap;
}

+ (NSMutableSet *)doubleAllocClassesMap {
    static NSMutableSet *doubleAllocClassesMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        doubleAllocClassesMap = [NSMutableSet set];
#if !__has_feature(objc_arc)
        [doubleAllocClassesMap retain];
#endif
    });
    return doubleAllocClassesMap;
}

#pragma mark - storage

+ (NSMutableDictionary *)allocations {
    static NSMutableDictionary *allocations = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allocations = [NSMutableDictionary dictionary];
#if !__has_feature(objc_arc)
        [allocations retain];
#endif
    });
    return allocations;
}

+ (PDLAllocationInfo *)allocationInfoForObject:(__unsafe_unretained id)object {
    if (!object) {
        return nil;
    }

    NSMutableDictionary *allocations = [self allocations];
    PDLAllocationInfo *info = allocations[@((unsigned long)(__bridge void *)object)];
    return info;
}

+ (void)setAllocationInfo:(PDLAllocationInfo *)info forObject:(__unsafe_unretained id)object {
    if (!object) {
        return;
    }

    NSMutableDictionary *allocations = [self allocations];
    allocations[@((unsigned long)(__bridge void *)object)] = info;
}

#pragma mark -

+ (BOOL)isObjectValid:(__unsafe_unretained id)object {
    if (!object) {
        return NO;
    }

    if ([object isKindOfClass:[PDLAllocationInfo class]]) {
        return NO;
    }
    if ([object isKindOfClass:[PDLBacktrace class]]) {
        return NO;
    }

    return YES;
}

+ (void)create:(__unsafe_unretained id)object {
    if (![self isObjectValid:object]) {
        return;
    }

    @synchronized (self) {
        PDLAllocationInfo *info = [self allocationInfoForObject:object];
        if (info) {
            [[PDLAllocationInfo doubleAllocClassesMap] addObject:object_getClass(object)];
        } else {
            info = [[PDLAllocationInfo alloc] initWithObject:object];
            [self setAllocationInfo:info forObject:object];
            [info release];
        }

        [info clearDealloc];
        [info recordAlloc];
    }
}

+ (void)destroy:(__unsafe_unretained id)object {
    if (![self isObjectValid:object]) {
        return;
    }

    @synchronized (self) {
        PDLAllocationInfo *info = [self allocationInfoForObject:object];
        if (info) {
            if (info.live == false) {
                [info clearAlloc];
                [[PDLAllocationInfo uncaughtClassesMap] addObject:object_getClass(object)];
            }
            info.live = false;
            switch (_policy) {
                case PDLAllocationPolicyLiveAllocations:
                    [self setAllocationInfo:nil forObject:object];
                    break;
                case PDLAllocationPolicyAllocationAndFree:
                    [info recordDealloc];
                    break;

                default:
                    break;
            }
        } else {
            [[PDLAllocationInfo uncaughtClassesMap] addObject:object_getClass(object)];
        }
    }
}

@end

@implementation NSObject (PDLAllocation)

#pragma mark - hook

__unused static id pdl_alloc(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    id object = nil;
    if (_imp) {
        object = ((id (*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
    [PDLAllocationInfo create:object];
    return object;
}


__unused static id pdl_allocWithZone(__unsafe_unretained id self, SEL _cmd, struct _NSZone *zone) {
    PDLImplementationInterceptorRecover(_cmd);
    id object = nil;
    if (_imp) {
        object = ((id (*)(id, SEL, struct _NSZone *))_imp)(self, _cmd, zone);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((id (*)(struct objc_super *, SEL, struct _NSZone *))objc_msgSendSuper)(&su, _cmd, zone);
    }
    [PDLAllocationInfo create:object];
    return object;
}

__unused static id pdl_new(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    id object = nil;
    if (_imp) {
        object = ((id (*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
    [PDLAllocationInfo create:object];
    return object;
}

__unused static id pdl_init(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    id object = nil;
    if (_imp) {
        object = ((id (*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
    [PDLAllocationInfo create:object];
    return object;
}

__unused static void pdl_dealloc(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    __unsafe_unretained id object = self;
    [PDLAllocationInfo destroy:object];
    if (_imp) {
        ((void (*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        ((void (*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
}

#pragma mark - record hidden count

static bool _pdl_allocationRecordHiddenCount = 0;
+ (unsigned int)pdl_allocationRecordHiddenCount {
    return _pdl_allocationRecordHiddenCount;
}

+ (void)setPdl_allocationRecordHiddenCount:(unsigned int)pdl_allocationRecordHiddenCount {
    _pdl_allocationRecordHiddenCount = pdl_allocationRecordHiddenCount;
}


+ (PDLBacktrace *)pdl_allocationBacktrace:(__unsafe_unretained id)object {
    PDLAllocationInfo *info = [PDLAllocationInfo allocationInfoForObject:object];
    return info.backtraceAlloc;
}

+ (PDLBacktrace *)pdl_deallocationBacktrace:(__unsafe_unretained id)object {
    PDLAllocationInfo *info = [PDLAllocationInfo allocationInfoForObject:object];
    return info.backtraceDealloc;
}

+ (BOOL)pdl_enableAllocation:(PDLAllocationPolicy)policy {
    _policy = policy;

    static BOOL ret = YES;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [NSObject class];
        id meta = object_getClass(cls);
//        ret &= [meta pdl_interceptSelector:@selector(alloc) withInterceptorImplementation:(IMP)&pdl_alloc isStructRet:NO addIfNotExistent:YES data:NULL];
        ret &= [meta pdl_interceptSelector:@selector(allocWithZone:) withInterceptorImplementation:(IMP)&pdl_allocWithZone isStructRet:NO addIfNotExistent:YES data:NULL];
        ret &= [meta pdl_interceptSelector:@selector(new) withInterceptorImplementation:(IMP)&pdl_new isStructRet:NO addIfNotExistent:YES data:NULL];
//        ret = [cls pdl_interceptSelector:@selector(init) withInterceptorImplementation:(IMP)&pdl_init isStructRet:NO addIfNotExistent:YES data:NULL];
        ret &= [cls pdl_interceptSelector:sel_registerName("dealloc") withInterceptorImplementation:(IMP)&pdl_dealloc isStructRet:NO addIfNotExistent:YES data:NULL];
    });
    return ret;
}

@end
