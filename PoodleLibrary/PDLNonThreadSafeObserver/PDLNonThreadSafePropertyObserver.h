//
//  PDLNonThreadSafePropertyObserver.h
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLNonThreadSafePropertyObserverProperty.h"

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^PDLNonThreadSafePropertyObserver_PropertyFilter)(NSString *propertyName);
typedef BOOL(^PDLNonThreadSafePropertyObserver_ClassFilter)(NSString *className);
typedef _Nullable PDLNonThreadSafePropertyObserver_PropertyFilter(^_Nullable PDLNonThreadSafePropertyObserver_ClassPropertyFilter)(NSString *className);

@interface PDLNonThreadSafePropertyObserver : NSObject

+ (id)observerObjectForObject:(id)object;

+ (void)observeClass:(Class)aClass
       propertyFilter:(PDLNonThreadSafePropertyObserver_PropertyFilter _Nullable)propertyFilter;

+ (void)observeClassesForImage:(const char *)image classFilter:(PDLNonThreadSafePropertyObserver_ClassFilter _Nullable)classFilter classPropertyFilter:(PDLNonThreadSafePropertyObserver_ClassPropertyFilter _Nullable)classPropertyFilter;

@end

NS_ASSUME_NONNULL_END
