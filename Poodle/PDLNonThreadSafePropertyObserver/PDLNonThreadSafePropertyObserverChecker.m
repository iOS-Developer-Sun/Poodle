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
    NSMutableArray *_gettersAndsetters;
}

@end

@implementation PDLNonThreadSafePropertyObserverChecker

- (instancetype)initWithObserverProperty:(PDLNonThreadSafePropertyObserverProperty *)property {
    self = [super init];
    if (self) {
        _property = property;

        _getters = [NSMutableSet set];
        _setters = [NSMutableSet set];
        _gettersAndsetters = [NSMutableArray array];

        [self setupCustom];
    }
    return self;
}

- (void)setupCustom {
    ;
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
        if (![_gettersAndsetters.lastObject isEqual:actionString]) {
            [_gettersAndsetters addObject:actionString];
        }
    }

    if ([self.custom respondsToSelector:@selector(recordAction:)]) {
        [self.custom recordAction:action];
    }
}

- (BOOL)check {
    if ([self.custom respondsToSelector:@selector(isThreadSafe)]) {
        return [self.custom isThreadSafe];
    } else {
        return [self isThreadSafe];
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
    return _getters.copy;
}

- (NSSet *)setters {
    return _setters.copy;
}

- (NSArray *)gettersAndsetters {
    return _gettersAndsetters.copy;
}

@end
