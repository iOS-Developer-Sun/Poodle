//
//  PDLNonThreadSafePropertyObserverObject.m
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafePropertyObserverObject.h"
#import <mach/mach.h>
#import <objc/runtime.h>
#import "PDLNonThreadSafePropertyObserverProperty.h"
#import "NSObject+PDLPrivate.h"
#import "PDLNonThreadSafeObserver.h"

@interface PDLNonThreadSafePropertyObserverObject ()

@property (strong, readonly) NSMutableDictionary *properties;

@end

@implementation PDLNonThreadSafePropertyObserverObject

- (instancetype)initWithObject:(id)object {
    self = [super initWithObject:object];
    if (self) {
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        [PDLNonThreadSafeObserver setIgnored:YES forObject:properties];
        _properties = properties;
    }
    return self;
}

- (NSString *)description {
    NSString *description = [super description];
    return [NSString stringWithFormat:@"%@\n%@", description, self.properties];
}

#pragma mark - class.property

- (PDLNonThreadSafePropertyObserverProperty *)propertyWithClass:(Class)aClass propertyName:(NSString *)propertyName {
    NSString *identifier = [NSString stringWithFormat:@"%@.%@", NSStringFromClass(aClass), propertyName];
    @synchronized (self) { // one object to multiple class.property
        PDLNonThreadSafePropertyObserverProperty *property = _properties[identifier];
        if (!property) {
            property = [[PDLNonThreadSafePropertyObserverProperty alloc] init];
            property.observer = self;
            property.identifier = identifier;
            _properties[identifier] = property;
        }
        return property;
    }
}

- (void)recordClass:(Class)aClass propertyName:(NSString *)propertyName isSetter:(BOOL)isSetter {
    PDLNonThreadSafePropertyObserverProperty *property = [self propertyWithClass:aClass propertyName:propertyName];
    [property record:isSetter];
}

@end
