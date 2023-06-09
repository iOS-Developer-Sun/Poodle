//
//  PDLNonThreadSafeArrayObserverObject.m
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeArrayObserverObject.h"
#import "PDLNonThreadSafeArrayObserverArray.h"
#import "PDLBacktrace.h"

@interface  PDLNonThreadSafeArrayObserverObject () {
    PDLNonThreadSafeArrayObserverArray *_array;
    PDLBacktrace *_backtrace;
}

@end

@implementation PDLNonThreadSafeArrayObserverObject

- (instancetype)initWithObject:(id)object {
    self = [super initWithObject:object];
    if (self) {
        PDLNonThreadSafeArrayObserverArray *array = [[PDLNonThreadSafeArrayObserverArray alloc] initWithObserver:self identifier:nil];
        if (!array) {
            return nil;
        }
        _array = array;
    }
    return self;
}

- (void)recordClass:(Class)aClass selectorString:(NSString *)selectorString isSetter:(BOOL)isSetter {
    PDLNonThreadSafeObserverAction *action = [_array recordIsSetter:isSetter isInitializing:self.isInitializing];
    action.detail = selectorString;
}

@end
