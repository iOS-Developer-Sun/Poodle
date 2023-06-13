//
//  PDLNonThreadSafeDictionaryObserverObject.m
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeDictionaryObserverObject.h"
#import "PDLNonThreadSafeDictionaryObserverDictionary.h"

@interface PDLNonThreadSafeDictionaryObserverObject ()

@property (nonatomic, strong, readonly) PDLNonThreadSafeDictionaryObserverDictionary *dictionary;

@end

@implementation PDLNonThreadSafeDictionaryObserverObject

- (instancetype)initWithObject:(id)object {
    PDLNonThreadSafeDictionaryObserverDictionary *dictionary = [[PDLNonThreadSafeDictionaryObserverDictionary alloc] init];
    if (!dictionary) {
        return nil;
    }

    self = [super initWithObject:object];
    if (self) {
        dictionary.observer = self;
        _dictionary = dictionary;
    }
    return self;
}

- (void)recordClass:(Class)aClass selectorString:(NSString *)selectorString isSetter:(BOOL)isSetter {
    PDLNonThreadSafeObserverAction *action = [_dictionary record:isSetter];
    action.detail = selectorString;
}

@end
