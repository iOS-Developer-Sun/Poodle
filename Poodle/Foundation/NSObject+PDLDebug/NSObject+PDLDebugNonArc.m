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

- (NSUInteger)objectRetainCount {
    return [self retainCount];
}

NSUInteger objc_retainCount(id object) {
    return [object retainCount];
}

@end
