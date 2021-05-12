//
//  NSObject+PDLWeakifyUnsafeUnretainedProperty.h
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PDLWeakifyUnsafeUnretainedProperty)

+ (BOOL)pdl_weakifyUnsafeUnretainedProperty:(NSString *)propertyName;
+ (BOOL)pdl_weakifyUnsafeUnretainedProperty:(NSString *)propertyName ivarName:(NSString *)ivarName;

/// make an unsafe unretained property weak, implementations of setter and getter will be replaced.
/// @discussion the property must not have custom implementation.
/// @param propertyName propertyName
/// @param ivarName ivar name
/// @param ivarClass class the ivar is in
/// @return YES if succeeded; NO if propertyName or ivarName length is invalid or getter and setter do not exist.
+ (BOOL)pdl_weakifyUnsafeUnretainedProperty:(NSString *)propertyName ivarName:(NSString *)ivarName ivarClass:(Class)ivarClass;

@end
