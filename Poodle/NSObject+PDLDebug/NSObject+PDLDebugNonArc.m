//
//  NSObject+PDLDebugNonArc.m
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSObject+PDLDebug.h"

#if __has_feature(objc_arc)
#error This file must be compiled with flag "-fno-objc-arc"
#endif

@implementation NSObject (PDLDebugNonArc)

- (instancetype)pdl_retain {
    return [self retain];
}

- (oneway void)pdl_release {
    [self release];
}

- (instancetype)pdl_autorelease {
    return [self autorelease];
}

- (NSUInteger)pdl_retainCount {
    return [self retainCount];
}

- (instancetype)pdl_autoreleaseRetained {
    [[self retain] autorelease];
    return self;
}

id pdl_objectRetain(id object) {
    return [object retain];
}

void pdl_objectRelease(id object) {
    return [object release];
}

id pdl_objectAutorelease(id object) {
    return [object autorelease];
}

NSUInteger pdl_objectRetainCount(id object) {
    return [object retainCount];
}

id pdl_objectAutoreleaseRetained(id object) {
    [[object retain] autorelease];
    return object;
}

@end
