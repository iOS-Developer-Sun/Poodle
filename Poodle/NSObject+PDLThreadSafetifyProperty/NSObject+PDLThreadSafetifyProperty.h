//
//  NSObject+PDLThreadSafetifyProperty.h
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PDLThreadSafetifyProperty)

+ (BOOL)pdl_threadSafetifyProperty:(NSString *)propertyName;

@end
