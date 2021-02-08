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
#import <mach-o/getsect.h>
#import <mach-o/dyld.h>
#import <mach-o/ldsyms.h>
#import <dlfcn.h>
#import <objc/runtime.h>

static NSString *PDLInitializationDurationString(CFTimeInterval duration) {
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

@interface PDLInitializationLoader ()

@property (nonatomic, assign) CFTimeInterval duration;
@property (nonatomic, assign) IMP imp;
@property (nonatomic, unsafe_unretained) Class aClass;

@end

@implementation PDLInitializationLoader

- (NSString *)description {
    NSString *durationString = PDLInitializationDurationString(self.duration);
    NSString *description = [NSString stringWithFormat:@" [%@, %p, %@]", self.aClass, self.imp, durationString];
    return [[super description] stringByAppendingString:description];
}

@end

@interface PDLInitializationInitializer ()

@property (nonatomic, assign) CFTimeInterval duration;
@property (nonatomic, assign) void *function;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *functionName;

@end

@implementation PDLInitializationInitializer

- (NSString *)description {
    NSString *durationString = PDLInitializationDurationString(self.duration);
    NSString *description = [NSString stringWithFormat:@" [%@`%@, %p, %@]", self.imageName.lastPathComponent, self.functionName, self.function, durationString];
    return [[super description] stringByAppendingString:description];
}

@end

@implementation PDLInitialization

static NSMutableArray *_loaders = nil;
static NSUInteger _preloadCount = 0;

static void pdl_load(id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    CFTimeInterval begin = CACurrentMediaTime();
    ((typeof(&pdl_load))_imp)(self, _cmd);
    CFTimeInterval end = CACurrentMediaTime();
    CFTimeInterval diff = end - begin;
    PDLInitializationLoader *loader = [[PDLInitializationLoader alloc] init];
    loader.duration = diff;
    loader.imp = _imp;
    loader.aClass = self;
    [_loaders addObject:loader];
}

+ (NSUInteger)preloadCount {
    return _preloadCount;
}

+ (NSUInteger)preload:(BOOL(^)(Class aClass, IMP imp))filter {
    assert(_loaders == nil);

    _loaders = [NSMutableArray array];

    NSInteger count = 0;
    unsigned int classCount = 0;
    Class *classList = objc_copyClassList(&classCount);
    SEL loadSelector = sel_registerName("load");
    IMP loadImp = (IMP)&pdl_load;
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

            IMP imp = method_getImplementation(method);
            BOOL shouldAdd = YES;
            if (filter) {
                shouldAdd = filter(aClass, imp);
            }
            if (!shouldAdd) {
                continue;
            }

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
    _preloadCount = count;
    return count;
}

+ (NSArray *)loaders {
    return [_loaders copy];
}

+ (NSArray *)topLoaders {
    return [_loaders sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        PDLInitializationLoader *i1 = obj1;
        PDLInitializationLoader *i2 = obj2;
        return [@(i2.duration) compare:@(i1.duration)];
    }];
}

#pragma mark -

static NSMutableArray *_initializers = nil;
static NSMutableDictionary *_initializersMap = nil;
static NSUInteger _preinitializeCount = 0;

#if defined(__x86_64__) || defined(__arm64__)

struct ProgramVars;
static void pdl_initialize(int argc, const char **argv, const char **envp, const char **apple, struct ProgramVars *pvars) {
    CFTimeInterval begin = CACurrentMediaTime();
#ifdef __x86_64__
    size_t offset = 320;
    uintptr_t rbx = 0;
    uintptr_t rbp = 0;
    __asm__ volatile("movq %%rbx, %0" : "=r"(rbx));//0x10aeb1478
    __asm__ volatile("movq %%rbp, %0" : "=r"(rbp));
    uintptr_t addr = *(uintptr_t *)(rbp + offset);
    uintptr_t index = rbx;
    uintptr_t key = addr + index * sizeof(void *);
#endif
#ifdef __arm64__
    uintptr_t x23 = 0;
    __asm__ volatile("mov %0, x23" : "=r"(x23));
    uintptr_t key = x23;
#endif
    uintptr_t value = [_initializersMap[@(key)] integerValue];
    void *function = (void *)value;
    ((typeof(&pdl_initialize))function)(argc, argv, envp, apple, pvars);
    CFTimeInterval end = CACurrentMediaTime();
    CFTimeInterval diff = end - begin;
    NSString *imageName = nil;
    NSString *functionName = nil;
    Dl_info info;
    int ret = dladdr(function, &info);
    if (ret) {
        if (info.dli_fname) {
            imageName = @(info.dli_fname);
        }
        if (info.dli_sname) {
            functionName = @(info.dli_sname);
        }
    }
    PDLInitializationInitializer *initializer = [[PDLInitializationInitializer alloc] init];
    initializer.duration = diff;
    initializer.function = function;
    initializer.imageName = imageName;
    initializer.functionName = functionName;
    [_initializers addObject:initializer];
}

#endif

+ (NSUInteger)preinitializeCount {
    return _preinitializeCount;
}

static uint8_t *getDataSection(const void *mhdr, const char *sectname, size_t *outBytes) {
    unsigned long byteCount = 0;
    uint8_t *data = getsectiondata(mhdr, "__DATA", sectname, &byteCount);
    if (!data) {
        data = getsectiondata(mhdr, "__DATA_CONST", sectname, &byteCount);
    }
    if (!data) {
        data = getsectiondata(mhdr, "__DATA_DIRTY", sectname, &byteCount);
    }
    if (outBytes) *outBytes = byteCount;
    return data;
}

void **pdl_initializers(const void *header, size_t *count) {
    size_t size = 0;
    void **data = (void **)getDataSection(header, "__mod_init_func", &size);
    if (count) {
        *count = size / sizeof(void *);
    }
    return data;
}

+ (NSUInteger)preinitialize:(BOOL(^_Nullable)(NSString *imageName, NSString *functionName, void *function))filter {
    assert(_initializers == nil);

    _initializers = [NSMutableArray array];
    _initializersMap = [NSMutableDictionary dictionary];

    NSInteger count = 0;
#if defined(__x86_64__) || defined(__arm64__)
    size_t initializersCount = 0;
    void **initializers = pdl_initializers(&_mh_execute_header, &initializersCount);
    for (size_t i = 0; i < initializersCount; i++) {
        void *initializer = initializers[i];
        BOOL shouldAdd = YES;
        if (filter) {
            NSString *imageName = nil;
            NSString *functionName = nil;
            Dl_info info;
            int ret = dladdr(initializer, &info);
            if (ret) {
                if (info.dli_fname) {
                    imageName = @(info.dli_fname);
                }
                if (info.dli_sname) {
                    functionName = @(info.dli_sname);
                }
            }
            shouldAdd = filter(imageName, functionName, initializer);
        }
        if (!shouldAdd) {
            continue;
        }

        uintptr_t key = (uintptr_t)&initializers[i];
        uintptr_t value = (uintptr_t)initializer;
        _initializersMap[@(key)] = @(value);
        initializers[i] = (IMP)&pdl_initialize;
    }
#endif

    _preinitializeCount = count;
    return count;
}

+ (NSArray *)initializes {
    return [_initializers copy];
}

+ (NSArray *)topInitializes {
    return [_initializers sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        PDLInitializationInitializer *i1 = obj1;
        PDLInitializationInitializer *i2 = obj2;
        return [@(i2.duration) compare:@(i1.duration)];
    }];
}

@end
