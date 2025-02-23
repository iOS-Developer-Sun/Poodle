//
//  NSDate+PDLExtension.m
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSDate+PDLExtension.h"

@implementation NSDate (PDLExtension)

+ (NSDateFormatter *)pdl_ymdhmsDateFormatter {
    static dispatch_once_t onceToken;
    static NSDateFormatter *dataFormatter = nil;
    dispatch_once(&onceToken, ^{
        dataFormatter = [[NSDateFormatter alloc] init];
        dataFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        dataFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dataFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    });
    return dataFormatter;
}

- (NSString *)pdl_ymdhmsDescription {
    NSString *timeString = [[self.class pdl_ymdhmsDateFormatter] stringFromDate:self];
    return timeString;
}

@end
