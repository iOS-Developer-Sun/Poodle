//
//  NSCache+PDLExtension.h
//
//
//  Created by Sun on 23/06/2017.
//
//

#import <Foundation/Foundation.h>

@interface NSCache (PDLExtension)

@property (readonly) NSArray *allObjects;

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id)key;

@end
