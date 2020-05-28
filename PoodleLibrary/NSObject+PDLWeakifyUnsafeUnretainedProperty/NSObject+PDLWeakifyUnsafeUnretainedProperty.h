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
+ (BOOL)pdl_weakifyUnsafeUnretainedProperty:(NSString *)propertyName ivarName:(NSString *)ivarName ivarClass:(Class)ivarClass;

@end
