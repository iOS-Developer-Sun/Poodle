//
//  PDLNonThreadSafeSwiftObjectObserverSwiftObject.m
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeSwiftObjectObserverSwiftObject.h"

@interface PDLNonThreadSafeSwiftObjectObserverSwiftObject ()

@end

@implementation PDLNonThreadSafeSwiftObjectObserverSwiftObject

- (instancetype)init {
    PDLBacktrace *backtrace = [[PDLBacktrace alloc] init];
    [backtrace record:6];
    self = [super init];
    if (self) {
        NSUInteger hash = 0;
        for (NSNumber *frame in backtrace.frames) {
            hash ^= frame.unsignedIntegerValue;
        }
        NSString *identifier = @(hash).stringValue;
        self.identifier = identifier;
        _backtrace = backtrace;
//        _name = [name copy];
    }
    return self;
}

- (NSString *)description {
    NSString *description = [super description];
    return [NSString stringWithFormat:@"%@, observer: %p\n%@\n%@", description, self.observer, self.identifier, self.actions];
}

+ (BOOL)recordsBacktrace {
    return YES;
}

@end
