//
//  PDLNonThreadSafeObserverCriticalResource.h
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLNonThreadSafeObserverObject.h"
#import "PDLNonThreadSafeObserverAction.h"
#import "PDLNonThreadSafeObserverChecker.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafeObserverCriticalResource : NSObject

@property (nonatomic, weak) PDLNonThreadSafeObserverObject *observer;
@property (nonatomic, copy) NSString *identifier;
@property (readonly) NSArray <PDLNonThreadSafeObserverAction *> *actions;

@property (readonly) PDLNonThreadSafeObserverChecker *checker;

- (PDLNonThreadSafeObserverAction *)record:(BOOL)isSetter;
+ (BOOL)recordsBacktrace;

@end

NS_ASSUME_NONNULL_END
