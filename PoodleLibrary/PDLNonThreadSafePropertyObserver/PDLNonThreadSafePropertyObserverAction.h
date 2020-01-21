//
//  PDLNonThreadSafePropertyObserverAction.h
//  Poodle
//
//  Created by Poodle on 2020/1/16.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafePropertyObserverAction : NSObject

@property (nonatomic, assign) BOOL isInitializing;
@property (nonatomic, assign) BOOL isSetter;
@property (nonatomic, assign) mach_port_t thread;
@property (nonatomic, copy) NSString *queueIdentifier;
@property (nonatomic, copy) NSString *queueLabel;
@property (nonatomic, assign) BOOL isSerialQueue;

@end

NS_ASSUME_NONNULL_END
