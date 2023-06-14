//
//  PDLNonThreadSafeClusterObserverCluster.m
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeClusterObserverCluster.h"

@interface PDLNonThreadSafeClusterObserverCluster ()

@end

@implementation PDLNonThreadSafeClusterObserverCluster

- (instancetype)init {
    PDLBacktrace *backtrace = [[PDLBacktrace alloc] init];
    [backtrace record:7];
    BOOL(^filter)(PDLBacktrace *, NSString **name) = [self.class filter];
    NSString *name = nil;
    if (filter) {
        BOOL exclusive = filter(backtrace, &name);
        if (exclusive) {
            return nil;
        }
    }

    self = [super init];
    if (self) {
        NSUInteger hash = 0;
        for (NSNumber *frame in backtrace.frames) {
            hash ^= frame.unsignedIntegerValue;
        }
        NSString *identifier = @(hash).stringValue;
        self.identifier = identifier;
        _backtrace = backtrace;
        _name = [name copy];
    }
    return self;
}

- (NSString *)description {
    NSString *description = [super description];
    return [NSString stringWithFormat:@"<%@, name: %@, observer: %p>", description, self.name, self.observer];
}

+ (BOOL)recordsBacktrace {
    return YES;
}

+ (nullable BOOL (^)(PDLBacktrace * _Nonnull __strong, NSString *__autoreleasing * _Nullable))filter {
    return nil;
}

@end
