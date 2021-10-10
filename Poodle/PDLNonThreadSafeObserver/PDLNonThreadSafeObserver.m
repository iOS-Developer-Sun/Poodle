//
//  PDLNonThreadSafeObserver.m
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeObserver.h"
#import <objc/runtime.h>
#import "PDLNonThreadSafeObserverChecker.h"

@implementation PDLNonThreadSafeObserver

static BOOL _queueEnabled = NO;

+ (BOOL)queueCheckerEnabled {
    return _queueEnabled;
}

+ (void)registerQueueCheckerEnabled:(BOOL)queueEnabled {
    _queueEnabled = queueEnabled;
}

static void (^_reporter)(PDLNonThreadSafeObserverCriticalResource *resource) = nil;

+ (void(^)(PDLNonThreadSafeObserverCriticalResource *resource))reporter {
    return _reporter;
}

+ (void)registerReporter:(void(^)(PDLNonThreadSafeObserverCriticalResource *resource))reporter {
    _reporter = reporter;
}

static Class _checker = nil;

+ (Class)checkerClass {
    return _checker ?: [PDLNonThreadSafeObserverChecker class];
}
+ (void)registerCheckerClass:(Class)checker {
    _checker = checker;
}

static void *PDLNonThreadSafeObserverIgnoredKey = &PDLNonThreadSafeObserverIgnoredKey;

+ (BOOL)ignoredForObject:(id)object {
    if (!object) {
        return NO;
    }

    NSNumber *ignored = objc_getAssociatedObject(object, PDLNonThreadSafeObserverIgnoredKey);
    return ignored.boolValue;
}
+ (void)setIgnored:(BOOL)ignored forObject:(id)object {
    if (!object) {
        return;
    }

    objc_setAssociatedObject(object, PDLNonThreadSafeObserverIgnoredKey, @(ignored), OBJC_ASSOCIATION_RETAIN);
}

@end
