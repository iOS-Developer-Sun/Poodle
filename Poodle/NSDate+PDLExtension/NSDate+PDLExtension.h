//
//  NSDate+PDLExtension.h
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (PDLExtension)

+ (NSDateFormatter *)pdl_ymdhmsDateFormatter;

- (NSString *)pdl_ymdhmsDescription;

@end
