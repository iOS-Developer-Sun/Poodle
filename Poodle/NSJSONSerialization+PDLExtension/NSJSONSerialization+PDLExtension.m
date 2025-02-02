//
//  NSJSONSerialization+PDLExtension.m
//  Poodle
//
//  Created by Poodle on 16/6/1.
//  Copyright © 2016 Poodle. All rights reserved.
//

#import "NSJSONSerialization+PDLExtension.h"

@implementation NSString (PDLJSONSerialization)

- (id)pdl_JSONObject {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"PDLJSONSerialization error: %@", error.localizedDescription);
    }
    return object;
}

@end

@implementation NSData (PDLJSONSerialization)

- (id)pdl_JSONObject {
    NSData *data = self;
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"PDLJSONSerialization error: %@", error.localizedDescription);
    }
    return object;
}

@end

@implementation NSArray (PDLJSONSerialization)

- (NSData *)pdl_JSONData {
    if (![NSJSONSerialization isValidJSONObject:self]) {
        return nil;
    }

    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    return data;
}

- (NSString *)pdl_JSONString {
    NSString *string = nil;
    NSData *data = [self pdl_JSONData];
    if (data) {
        string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return string;
}

@end

@implementation NSDictionary (PDLJSONSerialization)

- (NSData *)pdl_JSONData {
    if (![NSJSONSerialization isValidJSONObject:self]) {
        return nil;
    }

    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    return data;
}

- (NSString *)pdl_JSONString {
    NSString *string = nil;
    NSData *data = [self pdl_JSONData];
    if (data) {
        string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return string;
}

@end
