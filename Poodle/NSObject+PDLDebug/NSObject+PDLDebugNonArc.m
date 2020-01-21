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

- (instancetype)objectRetain {
    return [self retain];
}

- (oneway void)objectRelease {
    [self release];
}

- (instancetype)objectAutorelease {
    return [self autorelease];
}

- (NSUInteger)objectRetainCount {
    return [self retainCount];
}

- (instancetype)objectAutoreleaseRetained {
    [[self retain] autorelease];
    return self;
}

id objectRetain(id object) {
    return [object retain];
}

void objectRelease(id object) {
    return [object release];
}

id objectAutorelease(id object) {
    return [object autorelease];
}

NSUInteger objectRetainCount(id object) {
    return [object retainCount];
}

id objectAutoreleaseRetained(id object) {
    [[object retain] autorelease];
    return object;
}

@end
