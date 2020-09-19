//
//  PDLNonThreadSafePropertyObserverChecker.m
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafePropertyObserverChecker.h"

@interface PDLNonThreadSafePropertyObserverChecker () {
    NSMutableSet *_getters;
    NSMutableSet *_setters;
    NSMutableArray *_gettersAndSetters;
}

@end

@implementation PDLNonThreadSafePropertyObserverChecker

- (instancetype)initWithObserverProperty:(PDLNonThreadSafePropertyObserverProperty *)property {
    self = [super init];
    if (self) {
        _property = property;

        _getters = [NSMutableSet set];
        _setters = [NSMutableSet set];
        _gettersAndSetters = [NSMutableArray array];
    }
    return self;
}

- (NSString *)actionString:(PDLNonThreadSafePropertyObserverAction *)action {
    NSString *actionString = @(action.thread).stringValue;
    if (action.queueIdentifier && action.isSerialQueue) {
        actionString = action.queueIdentifier;
    }
    return actionString;
}

- (void)recordAction:(PDLNonThreadSafePropertyObserverAction *)action {
    if (!action.isInitializing) {
        NSString *actionString = [self actionString:action];
        if (action.isSetter) {
            [_setters addObject:actionString];
        } else {
            [_getters addObject:actionString];
        }
        if (![_gettersAndSetters.lastObject isEqual:actionString]) {
            [_gettersAndSetters addObject:actionString];
        }
    }
}

- (BOOL)isThreadSafe {
    if (_setters.count > 1) {
        return NO;
    }

    if (_setters.count == 1) {
        if (_getters.count > 1) {
            return NO;
        }
        if (![_getters isSubsetOfSet:_setters]) {
            return NO;
        }
    }
    return YES;
}

- (NSSet *)getters {
    return [_getters copy];
}

- (NSSet *)setters {
    return [_setters copy];
}

- (NSArray *)gettersAndSetters {
    return [_gettersAndSetters copy];
}

@end
