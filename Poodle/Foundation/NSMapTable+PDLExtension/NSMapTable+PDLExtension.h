//
//  NSMapTable+PDLExtension.h
//
//
//  Created by Sun on 23/06/2017.
//
//

#import <Foundation/Foundation.h>

@interface NSMapTable (PDLExtension)

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id)key;

@end
