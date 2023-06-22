//
//  PDLProcessInfo.h
//  Poodle
//
//  Created by Poodle on 2021/2/1.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLProcessInfo : NSObject

@property (readonly) NSDate *processStartDate;
@property (readonly) NSTimeInterval processStartMediaTime;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
