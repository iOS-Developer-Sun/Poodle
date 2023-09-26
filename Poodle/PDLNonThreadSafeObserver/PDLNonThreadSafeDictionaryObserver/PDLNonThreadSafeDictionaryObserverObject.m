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

@end

@implementation PDLNonThreadSafeDictionaryObserverObject

+ (Class)clusterClass {
    return [PDLNonThreadSafeDictionaryObserverDictionary class];
}

+ (instancetype)observerObjectForObject:(id)object {
    PDLNonThreadSafeDictionaryObserverObject *observer = [super observerObjectForObject:object];
    if (!observer && [object isKindOfClass:[NSMutableDictionary class]]) {
        // register __NSCFDictionary
        @autoreleasepool {
            [PDLNonThreadSafeDictionaryObserverObject registerObject:object];
        }
        observer = [super observerObjectForObject:object];
    }
    return observer;
}


@end
