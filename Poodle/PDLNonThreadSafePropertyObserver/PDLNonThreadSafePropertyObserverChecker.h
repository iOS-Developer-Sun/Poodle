//
//  PDLNonThreadSafePropertyObserverChecker.h
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLNonThreadSafePropertyObserverAction.h"

NS_ASSUME_NONNULL_BEGIN

@class PDLNonThreadSafePropertyObserverProperty;

@interface PDLNonThreadSafePropertyObserverChecker : NSObject

@property (weak, readonly) PDLNonThreadSafePropertyObserverProperty *property;

@property (readonly) NSSet *getters;
@property (readonly) NSSet *setters;
@property (readonly) NSArray *gettersAndSetters;

- (BOOL)isThreadSafe;
- (void)recordAction:(PDLNonThreadSafePropertyObserverAction *)action;

@end

NS_ASSUME_NONNULL_END
