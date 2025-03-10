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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

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

#pragma clang diagnostic pop
