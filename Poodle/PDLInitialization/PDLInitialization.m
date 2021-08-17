//
//  PDLInitialization.m
//  Poodle
//
//  Created by Poodle on 2020/9/3.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLInitialization.h"
#import <objc/runtime.h>
#import <mach/mach_time.h>
#import <mach-o/getsect.h>
#import <mach-o/dyld.h>
#import <mach-o/ldsyms.h>
#import <dlfcn.h>
#import "NSObject+PDLImplementationInterceptor.h"
#import "PDLDebug.h"
#import "pdl_objc_runtime.h"

@interface PDLInitializationLoader ()

@property (nonatomic, assign) uint64_t diff;
@property (nonatomic, assign) IMP imp;
@property (nonatomic, unsafe_unretained) Class aClass;
@property (nonatomic, assign) const char *category;

@end

@implementation PDLInitializationLoader

- (NSString *)description {
    NSString *durationString = pdl_durationString(self.duration);
    NSString *description = [NSString stringWithFormat:@" [%@ %@, %p, %@]", self.aClass, self.category ? [NSString stringWithFormat:@"(%s)", self.category] : @"", self.imp, durationString];
    return [[super description] stringByAppendingString:description];
}

- (NSTimeInterval)duration {
    return self.diff * [PDLInitialization hostTimeConversion];
}

@end

@interface PDLInitializationInitializer ()

@property (nonatomic, assign) uint64_t diff;
@property (nonatomic, assign) void *function;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *functionName;

@end

@implementation PDLInitializationInitializer

- (NSString *)description {
    NSString *durationString = pdl_durationString(self.duration);
    NSString *description = [NSString stringWithFormat:@" [%@`%@, %p, %@]", self.imageName.lastPathComponent, self.functionName, self.function, durationString];
    return [[super description] stringByAppendingString:description];
}

- (NSTimeInterval)duration {
    return self.diff * [PDLInitialization hostTimeConversion];
}

@end

@implementation PDLInitialization

static NSMutableArray *_loaders = nil;
static NSUInteger _preloadCount = 0;

+ (NSTimeInterval)hostTimeConversion {
    static NSTimeInterval _conversion = 0;
    if (_conversion == 0) {
        mach_timebase_info_data_t info;
        kern_return_t err = mach_timebase_info(&info);
        if (err == 0) {
            _conversion = 1.0 * 1e-9 * info.numer / info.denom;
        }
    }
    return _conversion;
}

static void pdl_load(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    uint64_t begin = mach_absolute_time();
    ((typeof(&pdl_load))_imp)(self, _cmd);
    uint64_t end = mach_absolute_time();
    uint64_t diff = end - begin;
    PDLInitializationLoader *loader = [[PDLInitializationLoader alloc] init];
    loader.diff = diff;
    loader.imp = _imp;
    loader.aClass = self;
    loader.category = _data;
    [_loaders addObject:loader];
}

+ (NSUInteger)preloadCount {
    return _preloadCount;
}

+ (NSUInteger)preload:(const void *)header filter:(BOOL(^)(Class aClass, const char *categoryName, IMP imp))filter {
    assert(_loaders == nil);

    _loaders = [NSMutableArray array];
    NSMutableSet *set = [NSMutableSet set];

    SEL loadSelector = sel_registerName("load");
    IMP loadImp = (IMP)&pdl_load;
    NSUInteger count = 0;

    size_t categoryCount = 0;
    pdl_objc_runtime_category *categories = pdl_objc_runtime_nonlazy_categories(header, &categoryCount);
    for (size_t i = 0; i < categoryCount; i++) {
        pdl_objc_runtime_category *category = categories[i];
        if (!category) {
            continue;
        }

        const char *name = pdl_objc_runtime_category_get_name(category);
        Class aClass = pdl_objc_runtime_category_get_class(category);
        pdl_objc_runtime_method_list method_list = pdl_objc_runtime_category_get_class_method_list(category);
        if (!method_list) {
            continue;
        }

        uint32_t method_list_count = pdl_objc_runtime_method_list_get_count(method_list);
        SEL loadSel = sel_registerName("load");
        for (uint32_t j = 0; j < method_list_count; j++) {
            Method method = pdl_objc_runtime_method_list_get_method(method_list, j);
            SEL sel = method_getName(method);
            if (!sel) {
                continue;
            }

            if ((!sel_isEqual(loadSel, sel)) && (strcmp(sel_getName(sel), sel_getName(loadSel)) != 0)) {
                continue;
            }

            [set addObject:@((unsigned long)(void *)method)];

            IMP imp = method_getImplementation(method);

            BOOL shouldAdd = YES;
            if (filter) {
                shouldAdd = filter(aClass, name, imp);
            }
            if (!shouldAdd) {
                continue;
            }

            BOOL ret = pdl_interceptMethod(aClass, method, @(NO), ^IMP(NSNumber *__autoreleasing *isStructRetNumber, void **data) {
                *data = (void *)name;
                return loadImp;
            });
            if (ret) {
                count++;
            } else {
                assert(ret);
            }
        }
    }

    size_t classCount = 0;
    Class *classes = pdl_objc_runtime_nonlazy_classes(header, &classCount);
    for (unsigned int i = 0; i < classCount; i++) {
        Class aClass = classes[i];
        assert(aClass);
        unsigned int methodCount = 0;
        Method *methodList = class_copyMethodList(object_getClass(aClass), &methodCount);
        for (unsigned int i = 0; i < methodCount; i++) {
            Method method = methodList[i];
            SEL sel = method_getName(method);
            if (sel != loadSelector) {
                continue;
            }

            if ([set containsObject:@((unsigned long)(void *)method)]) {
                continue;;
            }

            IMP imp = method_getImplementation(method);
            BOOL shouldAdd = YES;
            if (filter) {
                shouldAdd = filter(aClass, NULL, imp);
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
static NSMutableArray *_initializerFunctions = nil;
static NSUInteger _preinitializeCount = 0;

struct ProgramVars;
static void pdl_initialize(int argc, const char **argv, const char **envp, const char **apple, struct ProgramVars *pvars) {
    uintptr_t value = [_initializerFunctions.firstObject integerValue];
    [_initializerFunctions removeObjectAtIndex:0];
    if (_initializerFunctions.count == 0) {
        _initializerFunctions = nil;
    }
    void *function = (void *)value;
    uint64_t begin = mach_absolute_time();
    ((typeof(&pdl_initialize))function)(argc, argv, envp, apple, pvars);
    uint64_t end = mach_absolute_time();
    uint64_t diff = end - begin;
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
    initializer.diff = diff;
    initializer.function = function;
    initializer.imageName = imageName;
    initializer.functionName = functionName;
    [_initializers addObject:initializer];
}

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
    if (outBytes) {
        *outBytes = byteCount;
    }
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

+ (NSUInteger)preinitialize:(const void *)header filter:(BOOL(^_Nullable)(NSString *imageName, NSString *functionName, void *function))filter {
    assert(_initializers == nil);

    _initializers = [NSMutableArray array];
    _initializerFunctions = [NSMutableArray array];

    NSInteger count = 0;
    size_t initializersCount = 0;
    void **initializers = pdl_initializers(header, &initializersCount);
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

        [_initializerFunctions addObject:@((uintptr_t)initializer)];
        initializers[i] = (IMP)&pdl_initialize;
        count++;
    }

    _preinitializeCount = count;
    return count;
}

+ (NSArray *)initializers {
    return [_initializers copy];
}

+ (NSArray *)topInitializers {
    return [_initializers sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        PDLInitializationInitializer *i1 = obj1;
        PDLInitializationInitializer *i2 = obj2;
        return [@(i2.duration) compare:@(i1.duration)];
    }];
}

@end
