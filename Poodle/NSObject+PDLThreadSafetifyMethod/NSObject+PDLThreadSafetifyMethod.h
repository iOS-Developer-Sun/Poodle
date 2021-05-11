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

#ifndef __i386__

/// hook all instance methods except memory management and thread-safetify them with recursive locks
/// @param filter  return YES if you want to thread-safetify the method with selector.
/// @return methods thread-safetified count
+ (NSInteger)pdl_threadSafetifyMethods:(BOOL(^_Nullable)(SEL selector))filter;

#endif

@end

NS_ASSUME_NONNULL_END
