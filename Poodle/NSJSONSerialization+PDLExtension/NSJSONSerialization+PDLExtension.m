//
//  NSJSONSerialization+PDLExtension.m
//  Poodle
//
//  Created by Poodle on 16/6/1.
//  Copyright © 2016 Poodle. All rights reserved.
//

#import "NSJSONSerialization+PDLExtension.h"

#if !TARGET_OS_OSX
__unused __attribute__((visibility("hidden"))) void the_table_of_contents_is_empty(void) {}
#endif

@implementation NSString (PDLJSONSerialization)

- (id)pdl_JSONObject {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSAssert(NO, @"PDLJSONSerialization error: %@", error.localizedDescription);
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
        NSAssert(NO, @"PDLJSONSerialization error: %@", error.localizedDescription);
    }
    return object;
}

@end

@implementation NSArray (PDLJSONSerialization)

- (NSData *)pdl_JSONData {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    if (error) {
        NSAssert(NO, @"PDLJSONSerialization error: %@", error.localizedDescription);
    }
    return data;
}

- (NSString *)pdl_JSONString {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    if (error) {
        NSAssert(NO, @"PDLJSONSerialization error: %@", error.localizedDescription);
    }
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

@end

@implementation NSDictionary (PDLJSONSerialization)

- (NSData *)pdl_JSONData {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    if (error) {
        NSAssert(NO, @"PDLJSONSerialization error: %@", error.localizedDescription);
    }
    return data;
}

- (NSString *)pdl_JSONString {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    if (error) {
        NSAssert(NO, @"PDLJSONSerialization error: %@", error.localizedDescription);
    }
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

@end
