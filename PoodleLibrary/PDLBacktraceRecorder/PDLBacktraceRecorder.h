//
//  PDLBacktraceRecorder.h
//  Poodle
//
//  Created by Poodle on 2020/10/29.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLBacktraceRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLBacktraceRecorder : NSObject

- (instancetype)initWithThread:(mach_port_t)thread;
- (void)invalidate;

- (NSArray <PDLBacktraceRecord *>*)allRecords;
- (NSArray <PDLBacktraceRecord *>*)recordsFrom:(CFTimeInterval)from to:(CFTimeInterval)to;

@end

NS_ASSUME_NONNULL_END
