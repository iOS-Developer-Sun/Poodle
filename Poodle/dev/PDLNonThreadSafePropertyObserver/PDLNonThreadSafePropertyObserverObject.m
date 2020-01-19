//
//  PDLNonThreadSafePropertyObserverObject.m
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafePropertyObserverObject.h"
#import "PDLNonThreadSafePropertyObserverProperty.h"
#import "NSObject+PDLDebug.h"
#import "NSObject+PDLPrivate.h"
#import <mach/mach.h>
#import <objc/runtime.h>

@interface PDLNonThreadSafePropertyObserverProperty (PDLNonThreadSafePropertyObserverObject)

- (instancetype)initWithObserver:(PDLNonThreadSafePropertyObserverObject *)observer identifier:(NSString *)identifier;
- (void)recordIsSetter:(BOOL)isSetter isInitializing:(BOOL)isInitializing;

@end

@interface PDLNonThreadSafePropertyObserverInitilizing : NSObject

@property (nonatomic, assign) mach_port_t thread;

@end

@implementation PDLNonThreadSafePropertyObserverInitilizing

@end

@interface PDLNonThreadSafePropertyObserverObject ()

@property (weak, readonly) id object;
@property (weak, readonly) PDLNonThreadSafePropertyObserverInitilizing *initializing;
@property (strong, readonly) NSMutableDictionary *properties;

@end

@implementation PDLNonThreadSafePropertyObserverObject

- (instancetype)initWithObject:(id)object {
    self = [super init];
    if (self) {
        _object = object;
        _properties = [NSMutableDictionary dictionary];
        PDLNonThreadSafePropertyObserverInitilizing *initializing = [[[PDLNonThreadSafePropertyObserverInitilizing alloc] init] objectAutoreleaseRetained];
        initializing.thread = mach_thread_self();
        _initializing = initializing;
    }
    return self;
}

- (NSString *)description {
    NSString *description = [super description];
    return [NSString stringWithFormat:@"%@, object: %p, isInitializing: %@\n%@", description, self.object, @(self.isInitializing), self.properties];
}

#pragma mark - initializing tag

- (BOOL)isInitializing {
    BOOL isInitializing = self.initializing && self.initializing.thread == mach_thread_self();
    return isInitializing;
}

#pragma mark - class.property

- (PDLNonThreadSafePropertyObserverProperty *)propertyWithClass:(Class)aClass propertyName:(NSString *)propertyName {
    NSString *identifier = [NSString stringWithFormat:@"%@.%@", NSStringFromClass(aClass), propertyName];
    @synchronized (self) { // one object to multiple class.property
        PDLNonThreadSafePropertyObserverProperty *property = _properties[identifier];
        if (!property) {
            property = [[PDLNonThreadSafePropertyObserverProperty alloc] initWithObserver:self identifier:identifier];
            _properties[identifier] = property;
        }
        return property;
    }
}

- (void)recordClass:(Class)aClass propertyName:(NSString *)propertyName isSetter:(BOOL)isSetter {
    PDLNonThreadSafePropertyObserverProperty *property = [self propertyWithClass:aClass propertyName:propertyName];
    [property recordIsSetter:isSetter isInitializing:self.isInitializing];
}

#pragma mark - object observer association

static void *PDLNonThreadSafePropertyObserverObjectObjectKey = NULL;

+ (void)registerObject:(id)object {
    PDLNonThreadSafePropertyObserverObject *observer = [[self alloc] initWithObject:object];
    objc_setAssociatedObject(object, &PDLNonThreadSafePropertyObserverObjectObjectKey, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (instancetype)observerObjectForObject:(id)object {
    BOOL isDeallocating = [object _isDeallocating];
    if (isDeallocating) {
        return nil;
    }

    PDLNonThreadSafePropertyObserverObject *observer = objc_getAssociatedObject(object, &PDLNonThreadSafePropertyObserverObjectObjectKey);
    return observer;
}

@end
