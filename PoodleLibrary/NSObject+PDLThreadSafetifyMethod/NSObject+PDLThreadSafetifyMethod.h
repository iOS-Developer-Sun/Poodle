//
//  NSObject+PDLThreadSafetifyMethod.h
//  Poodle
//
//  Created by Poodle on 2020/7/15.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (PDLThreadSafetifyMethod)

+ (NSInteger)pdl_threadSafetifyMethods:(BOOL(^_Nullable)(SEL selector))filter;

@end

NS_ASSUME_NONNULL_END
