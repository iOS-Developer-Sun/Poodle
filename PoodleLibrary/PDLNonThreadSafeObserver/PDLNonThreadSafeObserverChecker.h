//
//  PDLNonThreadSafeObserverChecker.h
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLNonThreadSafeObserverAction.h"

NS_ASSUME_NONNULL_BEGIN

@class PDLNonThreadSafeObserverCriticalResource;

@interface PDLNonThreadSafeObserverChecker : NSObject

@property (weak, readonly) PDLNonThreadSafeObserverCriticalResource *resource;

@property (readonly) NSSet *getters;
@property (readonly) NSSet *setters;
@property (readonly) NSArray *gettersAndSetters;

- (instancetype)initWithObserverCriticalResource:(PDLNonThreadSafeObserverCriticalResource *)resource;

- (BOOL)isThreadSafe;
- (void)recordAction:(PDLNonThreadSafeObserverAction *)action;

@end

NS_ASSUME_NONNULL_END
