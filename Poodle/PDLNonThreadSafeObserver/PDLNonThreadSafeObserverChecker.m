//
//  PDLNonThreadSafeObserverChecker.m
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeObserverChecker.h"
#import "PDLNonThreadSafeObserver.h"

@interface PDLNonThreadSafeObserverChecker () {
    NSMutableSet *_getters;
    NSMutableSet *_setters;
    NSMutableArray *_gettersAndSetters;
}

@end

@implementation PDLNonThreadSafeObserverChecker

- (instancetype)initWithObserverCriticalResource:(PDLNonThreadSafeObserverCriticalResource *)resource {
    self = [super init];
    if (self) {
        _resource = resource;

        NSMutableSet *getters = [NSMutableSet set];
        [PDLNonThreadSafeObserver setIgnored:YES forObject:getters];
        _getters = getters;

        NSMutableSet *setters = [NSMutableSet set];
        [PDLNonThreadSafeObserver setIgnored:YES forObject:setters];
        _setters = setters;

        NSMutableArray *gettersAndSetters = [NSMutableArray array];
        [PDLNonThreadSafeObserver setIgnored:YES forObject:gettersAndSetters];
        _gettersAndSetters = gettersAndSetters;
    }
    return self;
}

- (NSString *)actionString:(PDLNonThreadSafeObserverAction *)action {
    NSString *actionString = @(action.thread).stringValue;
    if (action.queueIdentifier && action.isSerialQueue) {
        actionString = action.queueIdentifier;
    }
    return actionString;
}

- (void)recordAction:(PDLNonThreadSafeObserverAction *)action {
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
