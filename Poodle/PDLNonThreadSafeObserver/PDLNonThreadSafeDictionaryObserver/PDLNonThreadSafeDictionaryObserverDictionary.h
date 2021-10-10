//
//  PDLNonThreadSafeDictionaryObserverDictionary.h
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeObserverCriticalResource.h"
#import "PDLBacktrace.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafeDictionaryObserverDictionary : PDLNonThreadSafeObserverCriticalResource

@property (readonly) PDLBacktrace *backtrace;

@end

NS_ASSUME_NONNULL_END
