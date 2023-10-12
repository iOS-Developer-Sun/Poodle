//
//  PDLDeadLockObserver.h
//  Poodle
//
//  Created by Poodle on 10/10/23.
//  Copyright © 2023 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLLockItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLDeadLockObserver : NSObject

+ (NSArray <PDLLockItem *>*)suspiciousDeadLockItems;
+ (void)observe;

@end

NS_ASSUME_NONNULL_END
