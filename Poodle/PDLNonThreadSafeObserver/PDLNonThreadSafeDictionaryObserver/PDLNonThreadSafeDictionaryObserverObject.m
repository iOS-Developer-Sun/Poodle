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

@end
