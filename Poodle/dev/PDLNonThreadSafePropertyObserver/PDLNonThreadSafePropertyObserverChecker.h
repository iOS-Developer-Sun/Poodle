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

@protocol PDLNonThreadSafePropertyObserverCustomChecker <NSObject>

@optional

- (void)recordAction:(PDLNonThreadSafePropertyObserverAction *)action;
- (BOOL)isThreadSafe;

@end

@class PDLNonThreadSafePropertyObserverProperty;

@interface PDLNonThreadSafePropertyObserverChecker : NSObject

@property (weak, readonly) PDLNonThreadSafePropertyObserverProperty *property;

@property (readonly) NSSet *getters;
@property (readonly) NSSet *setters;
@property (readonly) NSArray *gettersAndsetters;

- (BOOL)isThreadSafe; // will not be called if 'custom' implements 'isThreadSafe'

#pragma mark - custom

@property (nonatomic, strong) id <PDLNonThreadSafePropertyObserverCustomChecker> custom;

- (void)setupCustom; // do nothing, overwrite it using category to set 'custom' when initializing

@end

NS_ASSUME_NONNULL_END
