//
//  PDLNonThreadSafePropertyObserverObject.h
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafePropertyObserverObject : NSObject

@property (readonly) BOOL isInitializing;

- (void)recordClass:(Class)aClass propertyName:(NSString *)propertyName isSetter:(BOOL)isSetter;

+ (void)registerObject:(id)object;
+ (instancetype)observerObjectForObject:(id)object;

@end

NS_ASSUME_NONNULL_END
