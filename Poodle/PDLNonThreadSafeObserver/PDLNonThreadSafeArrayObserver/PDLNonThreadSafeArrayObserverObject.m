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

@interface PDLNonThreadSafeArrayObserverObject ()

@property (nonatomic, strong, readonly) PDLNonThreadSafeArrayObserverArray *array;

@end

@implementation PDLNonThreadSafeArrayObserverObject

- (instancetype)initWithObject:(id)object {
    PDLNonThreadSafeArrayObserverArray *array = [[PDLNonThreadSafeArrayObserverArray alloc] init];
    if (!array) {
        return nil;
    }

    self = [super initWithObject:object];
    if (self) {
        array.observer = self;
        _array = array;
    }
    return self;
}

- (void)recordClass:(Class)aClass selectorString:(NSString *)selectorString isSetter:(BOOL)isSetter {
    PDLNonThreadSafeObserverAction *action = [_array record:isSetter];
    action.detail = selectorString;
}

@end
