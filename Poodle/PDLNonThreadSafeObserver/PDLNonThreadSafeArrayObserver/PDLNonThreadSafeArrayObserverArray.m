//
//  PDLNonThreadSafeArrayObserverArray.m
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeArrayObserverArray.h"
#import "PDLNonThreadSafeArrayObserver.h"

@interface PDLNonThreadSafeArrayObserverArray ()

@end

@implementation PDLNonThreadSafeArrayObserverArray

- (instancetype)initWithObserver:(PDLNonThreadSafeObserverObject *)observer identifier:(NSString *)identifier {
    NSString *validIdentifier = identifier;
    PDLBacktrace *backtrace = [[PDLBacktrace alloc] init];
    [backtrace record:6];
    BOOL(^filter)(PDLBacktrace *, NSString **name) = [PDLNonThreadSafeArrayObserver filter];
    NSString *name = nil;
    if (filter) {
        BOOL exclusive = filter(backtrace, &name);
        if (exclusive) {
            return nil;
        }
    }

    if (!validIdentifier) {
        NSUInteger hash = 0;
        for (NSNumber *frame in backtrace.frames) {
            hash ^= frame.unsignedIntegerValue;
        }
        validIdentifier = @(hash).stringValue;
    }
    self = [super init];
    if (self) {
        self.observer = observer;
        self.identifier = validIdentifier;
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

@end
