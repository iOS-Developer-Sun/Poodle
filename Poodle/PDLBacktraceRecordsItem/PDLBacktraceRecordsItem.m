//
//  PDLBacktraceRecordsItem.m
//  Poodle
//
//  Created by Poodle on 2020/11/2.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLBacktraceRecordsItem.h"

@interface PDLBacktraceRecordsItem ()

@property (nonatomic, strong) NSMapTable *timesTable;

@property (nonatomic, copy) NSDictionary *backtraces;
@property (nonatomic, copy) NSArray *timesList;

@end

@implementation PDLBacktraceRecordsItem

- (instancetype)initWithRecords:(NSArray <PDLBacktraceRecord *>*)records {
    self = [super init];
    if (self) {
        _records = [records copy];

        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        NSMapTable *timesTable = [NSMapTable strongToStrongObjectsMapTable];
        for (PDLBacktraceRecord *record in records) {
            PDLBacktrace *backtrace = record.backtrace;
            NSArray *frames = backtrace.frames;
            PDLBacktrace *firstBacktrace = dictionary[frames];
            if (!firstBacktrace) {
                dictionary[frames] = backtrace;
                firstBacktrace = backtrace;
            } else {
                record.backtrace = firstBacktrace;
            }

            NSMutableArray *times = [timesTable objectForKey:firstBacktrace];
            if (!times) {
                times = [NSMutableArray array];
                [timesTable setObject:times forKey:backtrace];
            }
            [times addObject:@(record.time)];
        }
        _timesTable = timesTable;

        NSMutableDictionary *backtraces = [NSMutableDictionary dictionary];
        for (PDLBacktrace *backtrace in self.timesTable) {
            NSArray *times = [self.timesTable objectForKey:backtrace];
            backtraces[times] = backtrace;
        }
        _backtraces = [backtraces copy];

        NSArray *timesList = [backtraces.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSUInteger count1 = ((NSArray *)obj1).count;
            NSUInteger count2 = ((NSArray *)obj2).count;
            if (count1 > count2) {
                return NSOrderedAscending;
            }
            if (count1 < count2) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
        _timesList = [timesList copy];
    }
    return self;
}

- (void)enumerateBacktraces:(void(^)(NSArray <NSNumber *>*times, PDLBacktrace *backtrace))enumerator {
    if (!enumerator) {
        return;
    }

    for (NSArray *times in self.timesList) {
        enumerator(times, self.backtraces[times]);
    }
}

- (void)show {
    for (NSArray *times in self.timesList) {
        PDLBacktrace *backtrace = self.backtraces[times];
        backtrace.name = [NSString stringWithFormat:@"%@:%@", self, @(times.count)];
        [backtrace show];
    }
}

- (void)hide {
    for (NSArray *times in self.timesList) {
        PDLBacktrace *backtrace = self.backtraces[times];
        [backtrace hide];
    }
}

@end
