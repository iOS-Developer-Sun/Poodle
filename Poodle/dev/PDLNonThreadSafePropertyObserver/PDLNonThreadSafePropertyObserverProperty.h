//
//  PDLNonThreadSafePropertyObserverProperty.h
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLNonThreadSafePropertyObserverAction.h"
#import "PDLNonThreadSafePropertyObserverChecker.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafePropertyObserverProperty : NSObject

@property (readonly) NSString *identifier;
@property (readonly) NSArray <PDLNonThreadSafePropertyObserverAction *> *actions;

@property (readonly) PDLNonThreadSafePropertyObserverChecker *checker;

@end

NS_ASSUME_NONNULL_END
