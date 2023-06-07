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
        PDLNonThreadSafeDictionaryObserverDictionary *dictionary = [[PDLNonThreadSafeDictionaryObserverDictionary alloc] initWithObserver:self identifier:nil];
        if (!dictionary) {
            return nil;
        }
        _dictionary = dictionary;
    }
    return self;
}

- (void)recordClass:(Class)aClass selectorString:(NSString *)selectorString isSetter:(BOOL)isSetter {
    PDLNonThreadSafeObserverAction *action = [_dictionary recordIsSetter:isSetter isInitializing:self.isInitializing];
    action.detail = selectorString;
}

@end
