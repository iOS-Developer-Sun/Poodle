//
//  PDLSessionTaskStatisticsManager.h
//  Poodle
//
//  Created by Poodle on 2020/12/28.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLSessionTaskStatistics.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLSessionTaskStatisticsManager : NSObject

@property (readonly) NSArray <PDLSessionTaskStatistics *>*statisticsRecords;

+ (BOOL)setup;
+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
