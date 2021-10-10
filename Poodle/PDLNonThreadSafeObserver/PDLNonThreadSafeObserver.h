//
//  PDLNonThreadSafeObserver.h
//  Poodle
//
//  Created by Poodle on 2021/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLNonThreadSafeObserverCriticalResource.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafeObserver : NSObject

+ (BOOL)queueCheckerEnabled; // default NO
+ (void)registerQueueCheckerEnabled:(BOOL)queueEnabled;

+ (void(^)(PDLNonThreadSafeObserverCriticalResource *resource))reporter;
+ (void)registerReporter:(void(^)(PDLNonThreadSafeObserverCriticalResource *resource))reporter;

+ (Class)checkerClass;
+ (void)registerCheckerClass:(Class)checker; // subclass of PDLNonThreadSafeObserverChecker

+ (BOOL)ignoredForObject:(id)object;
+ (void)setIgnored:(BOOL)ignored forObject:(id)object;

@end

NS_ASSUME_NONNULL_END
