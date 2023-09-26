//
//  PDLNonThreadSafeArrayObserverObject.m
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeArrayObserverObject.h"
#import "PDLNonThreadSafeArrayObserverArray.h"

@interface PDLNonThreadSafeArrayObserverObject ()

@end

@implementation PDLNonThreadSafeArrayObserverObject

+ (Class)clusterClass {
    return [PDLNonThreadSafeArrayObserverArray class];
}

+ (instancetype)observerObjectForObject:(id)object {
    PDLNonThreadSafeArrayObserverObject *observer = [super observerObjectForObject:object];
    if (!observer && [object isKindOfClass:[NSMutableArray class]]) {
        // register __NSCFArray
        @autoreleasepool {
            [PDLNonThreadSafeArrayObserverObject registerObject:object];
        }
        observer = [super observerObjectForObject:object];
    }
    return observer;
}

@end
