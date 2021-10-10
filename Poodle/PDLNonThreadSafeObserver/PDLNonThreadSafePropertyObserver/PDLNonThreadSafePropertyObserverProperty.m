//
//  PDLNonThreadSafePropertyObserverProperty.m
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafePropertyObserverProperty.h"

@interface PDLNonThreadSafePropertyObserverProperty ()

@end

@implementation PDLNonThreadSafePropertyObserverProperty

- (NSString *)description {
    NSString *description = [super description];
    return [NSString stringWithFormat:@"%@, observer: %p\n%@\n%@", description, self.observer, self.identifier, self.actions];
}

@end
