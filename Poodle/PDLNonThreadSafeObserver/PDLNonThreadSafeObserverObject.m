//
//  PDLNonThreadSafeObserverObject.m
//  Poodle
//
//  Created by Poodle on 2021/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeObserverObject.h"
#import <mach/mach.h>
#import <objc/runtime.h>
#import "NSObject+PDLDebug.h"
#import "NSObject+PDLPrivate.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafeObserverInitializing : NSObject

@property (nonatomic, assign) mach_port_t thread;

@end

@implementation PDLNonThreadSafeObserverInitializing

@end

@interface PDLNonThreadSafeObserverObject ()

@property (unsafe_unretained, readonly) id object;
@property (weak, readonly) PDLNonThreadSafeObserverInitializing *initializing;

@end

@implementation PDLNonThreadSafeObserverObject

- (instancetype)initWithObject:(id)object {
    self = [super init];
    if (self) {
        _object = object;
        PDLNonThreadSafeObserverInitializing *initializing = [[[PDLNonThreadSafeObserverInitializing alloc] init] pdl_autoreleaseRetained];
        initializing.thread = mach_thread_self();
        _initializing = initializing;
    }
    return self;
}

- (NSString *)description {
    NSString *description = [super description];
    return [NSString stringWithFormat:@"%@, object: %p, isInitializing: %@", description, self.object, @(self.isInitializing)];
}

- (BOOL)isInitializing {
    BOOL isInitializing = self.initializing && self.initializing.thread == mach_thread_self();
    return isInitializing;
}

static void *PDLNonThreadSafePropertyObserverObjectObjectKey = &PDLNonThreadSafePropertyObserverObjectObjectKey;

+ (void)registerObject:(id _Nullable)object {
    if (!object) {
        return;
    }

    PDLNonThreadSafeObserverObject *observer = objc_getAssociatedObject(object, PDLNonThreadSafePropertyObserverObjectObjectKey);
    if (observer) {
        return;
    }

    observer = [[self alloc] initWithObject:object];
    objc_setAssociatedObject(object, PDLNonThreadSafePropertyObserverObjectObjectKey, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (instancetype)observerObjectForObject:(id)object {
    BOOL isDeallocating = [object _isDeallocating];
    if (isDeallocating) {
        return nil;
    }

    PDLNonThreadSafeObserverObject *observer = objc_getAssociatedObject(object, &PDLNonThreadSafePropertyObserverObjectObjectKey);
    return observer;
}

@end


NS_ASSUME_NONNULL_END
