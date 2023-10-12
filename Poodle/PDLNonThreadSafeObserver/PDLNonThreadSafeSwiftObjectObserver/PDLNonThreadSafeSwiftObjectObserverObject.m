//
//  PDLNonThreadSafeSwiftObjectObserverObject.m
//  Poodle
//
//  Created by Poodle on 2023/6/5.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeSwiftObjectObserverObject.h"
#import "PDLNonThreadSafeSwiftVariableObserverVariable.h"
#import "PDLNonThreadSafeSwiftObjectObserverSwiftObject.h"

@interface PDLNonThreadSafeSwiftObjectObserverObject ()

@property (nonatomic, strong, readonly) PDLNonThreadSafeObserverCriticalResource *criticalResource;

@end

@implementation PDLNonThreadSafeSwiftObjectObserverObject

- (instancetype)initWithObject:(id)object {
    self = [super initWithObject:object];
    if (self) {
        _criticalResource = [[PDLNonThreadSafeSwiftObjectObserverSwiftObject alloc] init];
        _criticalResource.observer = self;
    }
    return self;
}

- (void)record:(BOOL)isSetter {
    [_criticalResource record:isSetter];
}

@end
