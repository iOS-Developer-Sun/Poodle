//
//  PDLNonThreadSafeClusterObserver.m
//  Poodle
//
//  Created by Poodle on 2023/6/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeClusterObserver.h"
#import "PDLNonThreadSafeObserver.h"
#import "PDLNonThreadSafeClusterObserverObject.h"

@implementation PDLNonThreadSafeClusterObserverLogData

@end

void PDLNonThreadSafeClusterObserverLogBegin(__unsafe_unretained id self, Class aClass, SEL sel, void *data) {
    if ([PDLNonThreadSafeObserver ignoredForObject:self]) {
        return;
    }

    if ([PDLNonThreadSafeObserverObject isFitered:self]) {
        return;
    }

    PDLNonThreadSafeClusterObserverLogData *logData = (__bridge id)(data);
    Class clusterClass = logData.clusterClass;
    PDLNonThreadSafeClusterObserverObject *observer = [clusterClass observerObjectForObject:self];
    BOOL isSetter = logData.isSetter;
    if (!observer) {
        if (!isSetter) {
            return;
        }

        NSLog(@"!");
    }

    BOOL isExclusive = logData.isExclusive;
    if (!isExclusive) {
        BOOL ready = [observer startRecording];
        if (!ready) {
            return;
        }
    }

    [observer recordClass:aClass selectorString:NSStringFromSelector(sel) isSetter:isSetter];
//    NSLog(@"%@ %@ %@", aClass, NSStringFromSelector(sel), @(isSetter));
}

void PDLNonThreadSafeClusterObserverLogEnd(__unsafe_unretained id self, Class aClass, SEL sel, void *data) {
    if ([PDLNonThreadSafeObserver ignoredForObject:self]) {
        return;
    }

    if ([PDLNonThreadSafeObserverObject isFitered:self]) {
        return;
    }

    PDLNonThreadSafeClusterObserverLogData *logData = (__bridge id)(data);
    Class clusterClass = logData.clusterClass;
    PDLNonThreadSafeClusterObserverObject *observer = [clusterClass observerObjectForObject:self];
    if (!observer) {
        return;
    }

    BOOL isExclusive = logData.isExclusive;
    if (!isExclusive) {
        [observer finishRecording];
    }
}

void PDLNonThreadSafeClusterObserverRegister(__unsafe_unretained id object, void *data) {
    Class observerClass = (__bridge Class)data;
    [observerClass registerObject:object];
}
