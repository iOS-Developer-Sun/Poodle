//
//  PDLNonThreadSafePropertyObserverAction.m
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafePropertyObserverAction.h"

@implementation PDLNonThreadSafePropertyObserverAction

- (NSString *)description {
    NSString *initializingString = self.isInitializing ? @"[init]" : @"";
    NSString *isSetterString = self.isSetter ? @"[setter]" : @"[getter]";
    NSString *threadString = [NSString stringWithFormat:@"[%@]", @(self.thread)];
    NSString *queueString = self.queueIdentifier ? [NSString stringWithFormat:@"[%@][%@]", self.queueIdentifier, self.queueLabel] : @"";

    NSString *actionString = [NSString stringWithFormat:@"%@%@%@%@", initializingString, isSetterString, threadString, queueString];
    return actionString;
}

@end
