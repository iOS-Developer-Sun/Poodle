//
//  PDLNonThreadSafeDictionaryObserverObject.m
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeDictionaryObserverObject.h"
#import "PDLNonThreadSafeDictionaryObserverDictionary.h"
#import "PDLBacktrace.h"

@interface  PDLNonThreadSafeDictionaryObserverObject () {
    PDLNonThreadSafeDictionaryObserverDictionary *_dictionary;
    PDLBacktrace *_backtrace;
}

@end

@implementation PDLNonThreadSafeDictionaryObserverObject

- (instancetype)initWithObject:(id)object {
    self = [super initWithObject:object];
    if (self) {
        _dictionary = [[PDLNonThreadSafeDictionaryObserverDictionary alloc] initWithObserver:self identifier:nil];
    }
    return self;
}

- (void)recordClass:(Class)aClass selectorString:(NSString *)selectorString isSetter:(BOOL)isSetter {
    [_dictionary recordIsSetter:isSetter isInitializing:self.isInitializing];
}

@end
