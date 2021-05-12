//
//  NSObject+PDLThreadSafetifyProperty.h
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PDLThreadSafetifyProperty)

/// hook getter and setter methods and thread-safetify them with recursive locks
/// @param propertyName property name
/// @return YES if succeeded; NO if property name length is 0 or property or method does not exist.
+ (BOOL)pdl_threadSafetifyProperty:(NSString *)propertyName;

@end
