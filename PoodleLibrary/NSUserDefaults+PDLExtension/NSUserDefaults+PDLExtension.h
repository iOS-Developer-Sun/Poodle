//
//  NSUserDefaults+PDLExtension.h
//  Poodle
//
//  Created by Poodle on 23/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

__attribute__((objc_direct_members))
@interface NSUserDefaults (PDLExtension)

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id)key;

@end
