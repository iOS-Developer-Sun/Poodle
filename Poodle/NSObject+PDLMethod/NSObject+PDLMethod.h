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

+ (NSInteger)pdl_addInstanceMethodsBeforeAction:(IMP _Nullable)beforeAction afterAction:(IMP _Nullable)afterAction;
+ (NSInteger)pdl_addInstanceMethodsBeforeAction:(IMP _Nullable)beforeAction afterAction:(IMP _Nullable)afterAction methodFilter:(BOOL(^_Nullable)(SEL selector))methodFilter;

@end

NS_ASSUME_NONNULL_END
