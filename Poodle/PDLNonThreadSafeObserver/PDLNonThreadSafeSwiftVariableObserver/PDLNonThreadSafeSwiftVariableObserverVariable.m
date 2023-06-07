//
//  PDLNonThreadSafeSwiftVariableObserverVariable.m
//  Poodle
//
//  Created by Poodle on 2023/6/5.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeSwiftVariableObserverVariable.h"

@interface PDLNonThreadSafeSwiftVariableObserverVariable ()

@end

@implementation PDLNonThreadSafeSwiftVariableObserverVariable

- (NSString *)description {
    NSString *description = [super description];
    return [NSString stringWithFormat:@"%@, observer: %p\n%@\n%@", description, self.observer, self.identifier, self.actions];
}

@end
