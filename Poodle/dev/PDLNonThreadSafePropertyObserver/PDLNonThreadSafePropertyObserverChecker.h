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

@property (strong, readonly) NSMutableSet *getters;
@property (strong, readonly) NSMutableSet *setters;

- (instancetype)initWithObserverProperty:(PDLNonThreadSafePropertyObserverProperty *)property; // call setupCustom
- (void)recordAction:(PDLNonThreadSafePropertyObserverAction *)action; // call custom recordAction if needed
- (BOOL)isThreadSafe; // return custom isThreadSafe if needed

#pragma mark - custom

@property (nonatomic, strong) id <PDLNonThreadSafePropertyObserverCustomChecker> custom;

- (void)setupCustom; // do nothing, overwrite it using category to set 'custom'

@end

NS_ASSUME_NONNULL_END
