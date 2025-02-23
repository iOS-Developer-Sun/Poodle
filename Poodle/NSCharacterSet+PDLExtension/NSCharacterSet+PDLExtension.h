//
//  NSCharacterSet+PDLExtension.h
//  Poodle
//
//  Created by Poodle on 2019/2/20.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCharacterSet (PDLExtension)

@property (class, readonly, copy) NSCharacterSet *pdl_emptyCharacterSet;
@property (class, readonly, copy) NSCharacterSet *pdl_allCharacterSet;

@property (class, readonly, copy) NSCharacterSet *pdl_URLAllowedCharacterSet;

@end
