//
//  NSCache+PDLExtension.h
//  Poodle
//
//  Created by Poodle on 23/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCache (PDLExtension)

/// private API
@property (readonly) NSArray *allObjects;

- (id)objectForKeyedSubscript:(id)key __attribute__((objc_direct));
- (void)setObject:(id)obj forKeyedSubscript:(id)key __attribute__((objc_direct));

@end
