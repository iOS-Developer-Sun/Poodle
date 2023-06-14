//
//  PDLNonThreadSafeDictionaryObserverDictionary.m
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeDictionaryObserverDictionary.h"
#import "PDLNonThreadSafeDictionaryObserver.h"

@interface PDLNonThreadSafeDictionaryObserverDictionary ()

@end

@implementation PDLNonThreadSafeDictionaryObserverDictionary

+ (BOOL (^)(PDLBacktrace * _Nonnull, NSString * _Nonnull __autoreleasing * _Nullable))filter {
    return [PDLNonThreadSafeDictionaryObserver filter];
}

@end
