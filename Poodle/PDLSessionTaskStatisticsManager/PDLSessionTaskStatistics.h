//
//  PDLSessionTaskStatistics.h
//  Poodle
//
//  Created by Poodle on 2020/12/29.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLSessionTaskStatistics : NSObject

@property (readonly) NSString *urlString;
@property (readonly) int64_t countOfBytesReceived;
@property (readonly) int64_t countOfBytesSent;
@property (readonly) NSURLSessionTaskState state;
@property (readonly) NSError *_Nullable error;
@property (readonly) NSTimeInterval startTime;
@property (readonly) NSTimeInterval duration;

@end

NS_ASSUME_NONNULL_END
