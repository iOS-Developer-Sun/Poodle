//
//  PDLNonThreadSafeObserverAction.m
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeObserverAction.h"

@implementation PDLNonThreadSafeObserverAction

- (NSString *)description {
    NSString *initializingString = self.isInitializing ? @"[init]" : @"";
    NSString *isSetterString = self.isSetter ? @"[setter]" : @"[getter]";
    NSString *threadString = [NSString stringWithFormat:@"[t%@]", @(self.thread)];
    NSString *queueString = self.queueIdentifier ? [NSString stringWithFormat:@"[q%@(%@)]", self.queueIdentifier, self.queueLabel] : @"";
    NSString *timeString = [NSString stringWithFormat:@"[%.3f]", self.time];
    NSString *detailString = self.detail ? [NSString stringWithFormat:@"[%@]", self.detail] : @"";

    NSString *actionString = [NSString stringWithFormat:@"%@%@%@%@%@%@", initializingString, isSetterString, threadString, queueString, timeString, detailString];
    return actionString;
}

@end
