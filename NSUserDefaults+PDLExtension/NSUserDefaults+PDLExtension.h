//
//  NSUserDefaults+PDLExtension.h
//  Poodle
//
//  Created by Sun on 23/06/2017.
//
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (PDLExtension)

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id)key;

@end
