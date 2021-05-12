//
//  NSObject+PDLMethod.h
//  Poodle
//
//  Created by Poodle on 2020/7/15.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (PDLMethod)


/// hook all instance methods for class self
/// @param beforeAction IMP like static void beforeAction(__unsafe_unretained id self, SEL _cmd);
/// @param afterAction IMP like static void beforeAction(__unsafe_unretained id self, SEL _cmd);
/// @return count added
+ (NSInteger)pdl_addInstanceMethodsBeforeAction:(IMP _Nullable)beforeAction afterAction:(IMP _Nullable)afterAction;

/// hook all instance methods for class self
/// @param beforeAction IMP like static void beforeAction(__unsafe_unretained id self, SEL _cmd);
/// @param afterAction IMP like static void beforeAction(__unsafe_unretained id self, SEL _cmd);
/// @param methodFilter  return YES if you want to add.
/// @return count added
+ (NSInteger)pdl_addInstanceMethodsBeforeAction:(IMP _Nullable)beforeAction afterAction:(IMP _Nullable)afterAction methodFilter:(BOOL(^_Nullable)(SEL selector))methodFilter;

@end

NS_ASSUME_NONNULL_END
