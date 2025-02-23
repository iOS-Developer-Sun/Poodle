//
//  NSString+PDLExtension.h
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <pthread.h>
#import <Foundation/Foundation.h>

@interface NSString (PDLExtension)

@property (readonly) NSString *pdl_trimmedString;
@property (readonly) NSString *pdl_plainText;

@end
