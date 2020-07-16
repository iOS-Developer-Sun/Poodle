//
//  PDLNonThreadSafePropertyObserver.h
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLNonThreadSafePropertyObserverProperty.h"
#import "PDLNonThreadSafePropertyObserverChecker.h"

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^PDLNonThreadSafePropertyObserver_PropertyFilter)(NSString *propertyName);
typedef BOOL(^PDLNonThreadSafePropertyObserver_ClassFilter)(NSString *className);
typedef _Nullable PDLNonThreadSafePropertyObserver_PropertyFilter(^_Nullable PDLNonThreadSafePropertyObserver_ClassPropertyFilter)(NSString *className);

@interface PDLNonThreadSafePropertyObserver : NSObject

+ (id)observerObjectForObject:(id)object;

+ (BOOL)queueCheckerEnabled; // default NO
+ (void)registerQueueCheckerEnabled:(BOOL)queueEnabled;

+ (void(^)(PDLNonThreadSafePropertyObserverProperty *property))reporter;
+ (void)registerReporter:(void(^)(PDLNonThreadSafePropertyObserverProperty *property))reporter;

+ (Class)checkerClass;
+ (void)registerCheckerClass:(Class)checker; // subclass of PDLNonThreadSafePropertyObserverChecker

+ (void)observerClass:(Class)aClass
       propertyFilter:(PDLNonThreadSafePropertyObserver_PropertyFilter _Nullable)propertyFilter
    propertyMapFilter:(NSArray <NSString *> *_Nullable)propertyMapFilter;

+ (void)observerClassesForImage:(const char *)image
                    classFilter:(PDLNonThreadSafePropertyObserver_ClassFilter _Nullable)classFilter
            classPropertyFilter:(PDLNonThreadSafePropertyObserver_ClassPropertyFilter _Nullable)classPropertyFilter
         classPropertyMapFilter:(NSDictionary <NSString *, NSArray <NSString *> *> * _Nullable)classPropertyMapFilter;

@end

NS_ASSUME_NONNULL_END
