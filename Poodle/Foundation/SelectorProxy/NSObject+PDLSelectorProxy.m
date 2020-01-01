//
//  NSObject+PDLSelectorProxy.m
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSObject+PDLSelectorProxy.h"
#import "NSObject+PDLImplementationInterceptor.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <dlfcn.h>

static void *NSObjectSelectorProxyKVOClassKey;
static void *NSObjectSelectorProxyClassKey;
static void *NSObjectSelectorProxyMapTableKey;

@implementation NSObject (SelectorProxy)

static BOOL NSObjectSelectorProxyIsObjectSupported(__unsafe_unretained id object) {
#if TARGET_OS_OSX && __x86_64__
    // 64-bit Mac - tag bit is LSB
#   define OBJC_MSB_TAGGED_POINTERS 0
#else
    // Everything else - tag bit is MSB
#   define OBJC_MSB_TAGGED_POINTERS 1
#endif

#if OBJC_MSB_TAGGED_POINTERS
#   define _OBJC_TAG_MASK (1ULL<<63)
#else
#   define _OBJC_TAG_MASK 1
#endif
    if (((intptr_t)object & _OBJC_TAG_MASK) == _OBJC_TAG_MASK) {
        return NO;
    }

    BOOL isCF = NO;
    static Boolean (*_CF_IsObjC_ptr)(CFTypeID, const void *) = NULL;
    if (!_CF_IsObjC_ptr) {
        void *handle = dlopen(NULL, RTLD_GLOBAL | RTLD_NOW);
        if (handle) {
            char symbol[10] = {0};
            symbol[0] = '_';
            symbol[1] = 'C';
            symbol[2] = 'F';
            symbol[3] = 'I';
            symbol[4] = 's';
            symbol[5] = 'O';
            symbol[6] = 'b';
            symbol[7] = 'j';
            symbol[8] = 'C';
            symbol[9] = '\0';
#ifdef DEBUG
            assert([@(symbol) isEqualToString:@"_CFIsObjC"]);
#endif
            _CF_IsObjC_ptr = dlsym(handle, symbol);
            dlclose(handle);
        }
    }

    if (_CF_IsObjC_ptr) {
        const void *cf = (__bridge const void *)object;
        isCF = !_CF_IsObjC_ptr(CFGetTypeID(cf), cf);
    }

    if (isCF) {
        return NO;
    }

//    extern Boolean _CFIsObjC(CFTypeID typeID, const void *obj);
//    const void *cf = (__bridge const void *)object;
//    CFTypeID typeID = CFGetTypeID(cf);
//    if (!_CFIsObjC(typeID, cf)) {
//        return NO;
//    }

    return YES;
}

static Class NSObjectSelectorProxySubclass(Class aClass) {
    // create a class
    NSString *className = [NSString stringWithFormat:@"%@_%@", @"PDLSelectorProxy", NSStringFromClass(aClass)];
    Class subclass = objc_allocateClassPair(aClass, className.UTF8String, 0);
    if (subclass) {
        // new class not registered
        objc_registerClassPair(subclass);

        // add method -(Class)class;
        SEL classSelector = @selector(class);
        id classBlock = ^Class (__unsafe_unretained id self) {
            return aClass;
        };

        IMP classImp = imp_implementationWithBlock(classBlock);
        class_addMethod(subclass, classSelector, classImp, method_getTypeEncoding(class_getInstanceMethod(aClass, classSelector)));
    } else {
        // class is already registered
        subclass = NSClassFromString(className);
    }
    return subclass;
}

static Class NSObjectSelectorProxyClass(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    Class kvoClass = object_getClass(self);
    Class aClass = objc_getAssociatedObject(kvoClass, &NSObjectSelectorProxyKVOClassKey);
    if (aClass == nil) {
        aClass = ((Class (*)(id, SEL))_imp)(self, _cmd);
    }
    return aClass;
}

static void NSObjectSelectorProxyAddObserverForKeyPathOptionsContext(__unsafe_unretained id self, SEL _cmd, NSObject *observer, NSString *keyPath, NSKeyValueObservingOptions options, void *context) {
    @synchronized (@"PDLSelectorProxy") {
        PDLImplementationInterceptorRecover(_cmd);
        
        NSObject *object = self;
        if (NSObjectSelectorProxyIsObjectSupported(object) == NO) {
            ((void (*)(id, SEL, NSObject *, NSString *, NSKeyValueObservingOptions, void *))_imp)(self, _cmd, observer, keyPath, options, context);
            return;
        }

        Class aClass = object_getClass(object);
        BOOL isKVO = ((BOOL (*)(id, SEL))objc_msgSend)(object, sel_registerName("_isKVOA"));
        if (isKVO == NO) {
            // check if subclassed
            Class selectorProxyClass = objc_getAssociatedObject(object, &NSObjectSelectorProxyClassKey);
            if (selectorProxyClass == nil) {
                Class selectorProxyClass = NSObjectSelectorProxySubclass(aClass);
                objc_setAssociatedObject(object, &NSObjectSelectorProxyClassKey, selectorProxyClass, OBJC_ASSOCIATION_ASSIGN);
                object_setClass(object, selectorProxyClass);
            }
        }

        ((void (*)(id, SEL, NSObject *, NSString *, NSKeyValueObservingOptions, void *))_imp)(self, _cmd, observer, keyPath, options, context);

        Class kvoClass = object_getClass(object);
        Class baseClass = objc_getAssociatedObject(kvoClass, &NSObjectSelectorProxyKVOClassKey);
        if (baseClass == nil) {
            // rewrite -[NSKVONotifying_SelectorProxy_CLASS Class];
            objc_setAssociatedObject(kvoClass, &NSObjectSelectorProxyKVOClassKey, aClass, OBJC_ASSOCIATION_ASSIGN);
            BOOL ret = [kvoClass pdl_interceptSelector:@selector(class) withInterceptorImplementation:(IMP)NSObjectSelectorProxyClass];
            if (ret == NO) {
                assert(0);
            }
        }
    }
}

static NSMapTable *NSObjectSelectorProxySelectorImplementationMapTableOfObject(__unsafe_unretained id object) {
    NSMapTable *selectorImplementationMapTableOfObject = objc_getAssociatedObject(object, &NSObjectSelectorProxyMapTableKey);
    if (selectorImplementationMapTableOfObject == nil) {
        selectorImplementationMapTableOfObject = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsCStringPersonality valueOptions:NSPointerFunctionsOpaquePersonality capacity:0];
        objc_setAssociatedObject(object, &NSObjectSelectorProxyMapTableKey, selectorImplementationMapTableOfObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return selectorImplementationMapTableOfObject;
}

static IMP NSObjectSelectorProxyAssociatedImplementationWithObjectAndSelector(__unsafe_unretained id object, SEL sel) {
    NSMapTable *selectorImplementationMapTableOfObject = NSObjectSelectorProxySelectorImplementationMapTableOfObject(object);
    return (IMP)(__bridge void *)[selectorImplementationMapTableOfObject objectForKey:(__bridge id)(void *)sel];
}

static void NSObjectSelectorProxySetAssociatedImplementationWithObjectAndSelector(__unsafe_unretained id object, SEL sel, IMP imp) {
    NSMapTable *selectorImplementationMapTableOfObject = NSObjectSelectorProxySelectorImplementationMapTableOfObject(object);
    [selectorImplementationMapTableOfObject setObject:(__bridge id)(void *)imp forKey:(__bridge id)(void *)sel];
}

static IMP NSObjectSelectorProxySelectorProxyImplementation(__unsafe_unretained id object, SEL selector) {
    @synchronized (@"PDLSelectorProxy") {
        Class aClass = objc_getAssociatedObject(object, &NSObjectSelectorProxyClassKey);
        Class superclass = class_getSuperclass(aClass);
        IMP imp = method_getImplementation(class_getInstanceMethod(superclass, selector));
        return imp;
    }
}

static BOOL NSObjectSelectorProxySetSelectorProxy(__unsafe_unretained id object, SEL selector, IMP implemetation, NSNumber *isStructRetNumber) {
    @synchronized (@"PDLSelectorProxy") {
        if (NSObjectSelectorProxyIsObjectSupported(object) == NO) {
            return NO;
        }

        Class aClass = object_getClass(object);
        Method method = class_getInstanceMethod(aClass, selector);
        const char *typeEncoding = method_getTypeEncoding(method);
        BOOL isStret = NO;

#if !__arm64__
        if (isStructRetNumber) {
            isStret = isStructRetNumber.boolValue;
        } else {
            @try {
                NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:typeEncoding];
                NSNumber *isHiddenStructRetNumber = [methodSignature valueForKey:@"isHiddenStructRet"];
                assert(isHiddenStructRetNumber);
                isStret = isHiddenStructRetNumber.boolValue;
            } @catch (NSException *exception) {
                return NO;
            } @finally {
                ;
            }
        }
#endif

        BOOL shouldChangeClass = NO;
        // check if subclassed
        Class selectorProxyClass = objc_getAssociatedObject(object, &NSObjectSelectorProxyClassKey);
        if (selectorProxyClass == nil) {
            selectorProxyClass = NSObjectSelectorProxySubclass(aClass);
            objc_setAssociatedObject(object, &NSObjectSelectorProxyClassKey, selectorProxyClass, OBJC_ASSOCIATION_ASSIGN);
            shouldChangeClass = YES;
        }

        // change imp to global entry
        extern void NSObjectSelectorProxyEntry(void);
        extern void NSObjectSelectorProxyEntry_stret(void);
        IMP entry = isStret ? NSObjectSelectorProxyEntry_stret : NSObjectSelectorProxyEntry;
        class_replaceMethod(selectorProxyClass, selector, entry, typeEncoding);

        // map custom implementation to selector for object
        NSObjectSelectorProxySetAssociatedImplementationWithObjectAndSelector(object, selector, implemetation);

        // set class when all is ready in order not to crash while other thread is calling the method
        if (shouldChangeClass) {
            object_setClass(object, selectorProxyClass);
        }
        return YES;
    }
}

IMP NSObjectSelectorProxyForwarding(__unsafe_unretained id self, SEL _cmd) {
    @synchronized (@"PDLSelectorProxy") {
        IMP imp = NSObjectSelectorProxyAssociatedImplementationWithObjectAndSelector(self, _cmd);
        if (imp == nil) {
            imp = NSObjectSelectorProxySelectorProxyImplementation(self, _cmd);
        }
        return imp;
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL ret = [[NSObject class] pdl_interceptSelector:@selector(addObserver:forKeyPath:options:context:) withInterceptorImplementation:(IMP)NSObjectSelectorProxyAddObserverForKeyPathOptionsContext];
        (void)ret;
        NSAssert(ret, @"addObserver:forKeyPath:options:context: not hooked");
    });
}

- (BOOL)pdl_setSelectorProxyForSelector:(SEL)selector withImplementation:(IMP)implemetation {
    return NSObjectSelectorProxySetSelectorProxy(self, selector, implemetation, nil);
}

- (BOOL)pdl_setSelectorProxyForSelector:(SEL)selector withImplementation:(IMP)implemetation isStructRet:(BOOL)isStructRet {
    return NSObjectSelectorProxySetSelectorProxy(self, selector, implemetation, @(isStructRet));
}

- (IMP)pdl_selectorProxyImplementationForSelector:(SEL)selector {
    return NSObjectSelectorProxySelectorProxyImplementation(self, selector);
}

@end
