//
//  NSObject+PDLPrivate.m
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSObject+PDLPrivate.h"
#import <objc/runtime.h>
#import <objc/message.h>

#if !TARGET_OS_OSX
__unused __attribute__((visibility("hidden"))) void the_table_of_contents_is_empty(void) {}
#endif

@implementation NSObject (PDLPrivate)

@dynamic _ivarDescription;
@dynamic _shortMethodDescription;
@dynamic _methodDescription;
@dynamic _copyDescription;
#if !TARGET_IPHONE_SIMULATOR
@dynamic _briefDescription;
@dynamic _rawBriefDescription;
#endif

@dynamic _isDeallocating;

@end
