//
//  NSObject+PDLPrivate.h
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PDLPrivate)

@property (readonly) NSString *_ivarDescription;
@property (readonly) NSString *_shortMethodDescription;
@property (readonly) NSString *_methodDescription;
@property (readonly) NSString *_copyDescription;
#if !TARGET_IPHONE_SIMULATOR
@property (readonly) NSString *_briefDescription;
@property (readonly) NSString *_rawBriefDescription;
#endif

@property (readonly) BOOL _isDeallocating;

extern id objc_retain(__unsafe_unretained id object);
extern void objc_release(__unsafe_unretained id object);
extern id objc_autorelease(__unsafe_unretained id object);

extern void _objc_autoreleasePoolPrint(void);

extern id objc_storeStrong(__unsafe_unretained id *location, __unsafe_unretained id object);
extern id objc_loadWeakRetained(__unsafe_unretained id *location);

extern id objc_getProperty(__unsafe_unretained id self, SEL _cmd, ptrdiff_t offset, BOOL atomic);
extern void objc_setProperty_nonatomic(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id newValue, ptrdiff_t offset);
extern void objc_setProperty(__unsafe_unretained id self, SEL _cmd, ptrdiff_t offset, __unsafe_unretained id newValue, BOOL atomic, char shouldCopy);

extern void objc_setProperty_atomic(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id newValue, ptrdiff_t offset);
extern void objc_setProperty_nonatomic_copy(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id newValue, ptrdiff_t offset);
extern void objc_setProperty_atomic_copy(__unsafe_unretained id self, SEL _cmd, __unsafe_unretained id newValue, ptrdiff_t offset);

extern void objc_copyStruct(void *dest, const void *src, ptrdiff_t size, BOOL atomic, BOOL hasStrong __unused);

OBJC_EXPORT void
objc_msgSendSuper2(void /* struct objc_super *super, SEL op, ... */ )
OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0, 2.0);

#ifndef __arm64__
OBJC_EXPORT void
objc_msgSendSuper2_stret(void /* struct objc_super *super, SEL op, ... */ )
OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0, 2.0)
OBJC_ARM64_UNAVAILABLE;

#endif

@end
