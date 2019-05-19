//
//  NSObject+PDLPrivate.m
//  Poodle
//
//  Created by Poodle on 14-6-26.
//
//

#import "NSObject+PDLPrivate.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (PDLPrivate)

@dynamic _ivarDescription;
@dynamic _shortMethodDescription;
@dynamic _methodDescription;
@dynamic _copyDescription;
#if !TARGET_IPHONE_SIMULATOR
@dynamic _briefDescription;
@dynamic _rawBriefDescription;
#endif


@end
