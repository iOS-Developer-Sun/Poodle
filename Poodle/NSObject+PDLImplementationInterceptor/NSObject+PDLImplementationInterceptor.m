//
//  NSObject+PDLImplementationInterceptor.m
//  Poodle
//
//  Created by Poodle on 2017/11/4.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSObject+PDLImplementationInterceptor.h"

extern void PDLImplementationInterceptorEntry(void);
extern void PDLImplementationInterceptorEntry_stret(void);

// generated by rewriting this file to cpp
struct __block_impl {
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;
};

struct NSObjectImplementationInterceptorBlockDesc {
    size_t reserved;
    size_t Block_size;
};

struct NSObjectImplementationInterceptorBlock {
    struct __block_impl impl;
    struct NSObjectImplementationInterceptorBlockDesc *Desc;
    IMP interceptorImplementation;
    struct PDLImplementationInterceptorData data;
};
// end comment

@implementation NSObject (PDLImplementationInterceptor)

BOOL pdl_intercept(Class aClass, SEL selector, NSNumber *isStructRetNumber, IMP(^interceptor)(BOOL exists, NSNumber *isStructRetNumber, Method method, void **data)) {
    Method method = class_getInstanceMethod(aClass, selector);
    IMP implementation = method_getImplementation(method);
    if (implementation == NULL) {
        return NO;
    }

    BOOL exists = YES;
    void *data = NULL;
    const char *typeEncoding = method_getTypeEncoding(method);
    Method superclassMethod = class_getInstanceMethod(class_getSuperclass(aClass), selector);
    IMP superclassImplementation = method_getImplementation(superclassMethod);
    if (implementation == superclassImplementation) {
        exists = NO;
        implementation = NULL;
    }

    BOOL isStret = NO;
    NSNumber *isStructRetNumberToReport = isStructRetNumber;
#if !__arm64__
    if (!isStructRetNumberToReport) {
        @try {
            NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:typeEncoding];
            NSNumber *isHiddenStructRetNumber = [methodSignature valueForKey:@"isHiddenStructRet"];
            assert(isHiddenStructRetNumber);
            isStructRetNumberToReport = isHiddenStructRetNumber;
        } @catch (NSException *exception) {
            isStructRetNumberToReport = nil;
        } @finally {
            ;
        }
    }
    isStret = isStructRetNumberToReport.boolValue;
#else
    isStructRetNumberToReport = @(NO);
#endif

    IMP interceptorImplementation = interceptor(exists, isStructRetNumberToReport, method, &data);
    if (!interceptorImplementation) {
        return NO;
    }

    struct PDLImplementationInterceptorData implementationInterceptorData = {selector, (char *)typeEncoding, implementation, aClass, data};

    id block = nil;
    struct NSObjectImplementationInterceptorBlock *blockPointer = NULL;
    if (!isStret) {
        block = ^(id self) {
            if (interceptorImplementation){};
            if (implementationInterceptorData.method_imp){};
        };

        blockPointer = (struct NSObjectImplementationInterceptorBlock *)(__bridge void *)(block);
        blockPointer->impl.FuncPtr = (void *)&PDLImplementationInterceptorEntry;
    } else {
        block = ^struct __block_impl (id self) {
            struct __block_impl ret;
            memset(&ret, 0, sizeof(ret));
            if (interceptorImplementation){};
            if (implementationInterceptorData.method_imp){};
            return ret;
        };

        blockPointer = (struct NSObjectImplementationInterceptorBlock *)(__bridge void *)(block);
        blockPointer->impl.FuncPtr = (void *)&PDLImplementationInterceptorEntry_stret;
    }

    IMP blockImplementation = imp_implementationWithBlock(block);
    IMP originalImplementation = class_replaceMethod(aClass, selector, blockImplementation, typeEncoding);
    (void)originalImplementation;
    assert((originalImplementation != NULL) == (exists != NO));
    assert(blockPointer->Desc->Block_size == sizeof(struct NSObjectImplementationInterceptorBlock));
    assert(blockPointer->interceptorImplementation == interceptorImplementation);
    assert(blockPointer->data.method_name == implementationInterceptorData.method_name);
    assert(blockPointer->data.method_types == implementationInterceptorData.method_types);
    assert(blockPointer->data.method_imp == implementationInterceptorData.method_imp);
    assert(blockPointer->data.method_class == implementationInterceptorData.method_class);

    return YES;
}

NSUInteger pdl_interceptCluster(Class aClass, SEL selector, NSNumber *isStructRetNumber, IMP(^interceptor)(Class aClass, BOOL exists, NSNumber *isStructRetNumber, Method method, void **data)) {
    CFMutableSetRef classes = CFSetCreateMutable(NULL, 0, NULL);
    unsigned int outCount = 0;
    Class *classList = objc_copyClassList(&outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        Class eachClass = classList[i];
        if (eachClass == aClass) {
            continue;
        } else {
            Class superClass = class_getSuperclass(eachClass);
            while (superClass) {
                if (superClass == aClass) {
                    CFSetAddValue(classes, (__bridge const void *)(eachClass));
                    break;
                } else {
                    superClass = class_getSuperclass(superClass);
                }
            }
        }
    }
    free(classList);

    NSUInteger ret = 0;
    CFIndex count = CFSetGetCount(classes);
    const void *subclasses[count];
    CFSetGetValues(classes, subclasses);

    for (CFIndex i = 0; i < count; i++) {
        Class subclass = (__bridge Class)(subclasses[i]);
        BOOL intercepted = pdl_intercept(subclass, selector, isStructRetNumber, ^IMP(BOOL exists, NSNumber *isStructRetNumber, Method method, void **data) {
            return interceptor(subclass, exists, isStructRetNumber, method, data);
        });
        if (intercepted) {
            ret++;
        }
    }
    BOOL intercepted = pdl_intercept(aClass, selector, isStructRetNumber, ^IMP(BOOL exists, NSNumber *isStructRetNumber, Method method, void **data) {
        return interceptor(aClass, exists, isStructRetNumber, method, data);
    });
    if (intercepted) {
        ret++;
    }

    CFRelease(classes);

    return ret;
}

BOOL pdl_interceptSelector(Class aClass, SEL selector, IMP interceptorImplementation, NSNumber *isStructRetNumber, BOOL addIfNotExistent, void *data) {
    void *d = data;
    return pdl_intercept(aClass, selector, isStructRetNumber, ^IMP(BOOL exists, NSNumber *isStructRetNumber, Method method, void **data) {
        if (!exists && !addIfNotExistent) {
            return NULL;
        }
        *data = d;
        return interceptorImplementation;
    });
}

NSUInteger pdl_interceptClusterSelector(Class aClass, SEL selector, IMP interceptorImplementation, NSNumber *isStructRetNumber, BOOL addIfNotExistent, void *data) {
    void *d = data;
    return pdl_interceptCluster(aClass, selector, isStructRetNumber, ^IMP(__unsafe_unretained Class aClass, BOOL exists, NSNumber *isStructRetNumber, Method method, void **data) {
        if (!exists && !addIfNotExistent) {
            return NULL;
        }
        *data = d;
        return interceptorImplementation;
    });
}

+ (BOOL)pdl_interceptSelector:(SEL)selector withInterceptorImplementation:(IMP)interceptorImplementation {
    return pdl_interceptSelector(self, selector, interceptorImplementation, nil, NO, NULL);
}

+ (BOOL)pdl_interceptSelector:(SEL)selector withInterceptorImplementation:(IMP)interceptorImplementation isStructRet:(NSNumber *)isStructRet addIfNotExistent:(BOOL)addIfNotExistent data:(void *)data {
    return pdl_interceptSelector(self, selector, interceptorImplementation, isStructRet, addIfNotExistent, data);
}

+ (NSUInteger)pdl_interceptClusterSelector:(SEL)selector withInterceptorImplementation:(IMP)interceptorImplementation {
    return pdl_interceptClusterSelector(self, selector, interceptorImplementation, nil, NO, NULL);
}

+ (NSUInteger)pdl_interceptClusterSelector:(SEL)selector withInterceptorImplementation:(IMP)interceptorImplementation isStructRet:(NSNumber *)isStructRet addIfNotExistent:(BOOL)addIfNotExistent data:(void *)data {
    return pdl_interceptClusterSelector(self, selector, interceptorImplementation, isStructRet, addIfNotExistent, data);
}

@end
