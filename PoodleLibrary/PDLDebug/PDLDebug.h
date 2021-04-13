//
//  PDLDebug.h
//  Poodle
//
//  Created by Poodle on 2020/5/21.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

#if defined (__cplusplus)
extern "C" {
#endif

NS_ASSUME_NONNULL_BEGIN

extern void pdl_debugThreadSafe(NSUInteger threadCount, NSUInteger loopCount, void(^action)(NSUInteger threadIndex, NSUInteger loopIndex), void(^completion)(NSTimeInterval duration));

extern NSUInteger pdl_randomDigitsNumber(NSUInteger digits);
extern NSString *pdl_randomLengthString(NSUInteger minLength, NSUInteger maxLength);
extern NSTimeInterval pdl_performance(void(^code)(void));
extern void pdl_performance_log(void(^code)(void));
extern NSString *pdl_durationString(NSTimeInterval duration);
extern void pdl_debug_halt(void);
extern void pdl_logInstanceMethods(Class aClass);
extern void pdl_logClassMethods(Class aClass);

NS_ASSUME_NONNULL_END

#if defined (__cplusplus)
}
#endif
