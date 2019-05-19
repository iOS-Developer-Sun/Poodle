//
//  NSObject+PDLDebugNonArc.m
//  Sun
//
//  Created by Sun on 14-6-26.
//
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
