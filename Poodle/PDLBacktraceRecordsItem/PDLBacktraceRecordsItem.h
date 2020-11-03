//
//  PDLBacktraceRecordsItem.h
//  Poodle
//
//  Created by Poodle on 2020/11/2.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLBacktraceRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLBacktraceRecordsItem : NSObject

@property (nonatomic, assign) CFTimeInterval begin;
@property (nonatomic, assign) CFTimeInterval end;
@property (nonatomic, copy, readonly) NSArray <PDLBacktraceRecord *> *records;

- (instancetype)initWithRecords:(NSArray <PDLBacktraceRecord *>*)records;

- (void)enumerateBacktraces:(void(^)(NSArray <NSNumber *>*times, PDLBacktrace *backtrace))enumerator;
- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
