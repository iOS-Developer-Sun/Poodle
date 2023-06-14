//
//  PDLNonThreadSafeClusterObserverObject.m
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeClusterObserverObject.h"
#import "PDLNonThreadSafeClusterObserverCluster.h"
#import "PDLBacktrace.h"

@interface PDLNonThreadSafeClusterObserverObject ()

@property (nonatomic, strong, readonly) PDLNonThreadSafeClusterObserverCluster *cluster;

@end

@implementation PDLNonThreadSafeClusterObserverObject

- (instancetype)initWithObject:(id)object {
    PDLNonThreadSafeClusterObserverCluster *cluster = [[[self.class clusterClass] alloc] init];
    if (!cluster) {
        return nil;
    }

    self = [super initWithObject:object];
    if (self) {
        cluster.observer = self;
        _cluster = cluster;
    }
    return self;
}

- (void)recordClass:(Class)aClass selectorString:(NSString *)selectorString isSetter:(BOOL)isSetter {
    PDLNonThreadSafeObserverAction *action = [_cluster record:isSetter];
    action.detail = selectorString;
}

+ (Class)clusterClass {
    return [PDLNonThreadSafeClusterObserverCluster class];
}

@end
