//
//  NSThread+PDLExtension.h
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <pthread.h>
#import <Foundation/Foundation.h>

@interface NSThread (PDLExtension)

@property (readonly) pthread_t pdl_pthread;
@property (readonly) int pdl_seqNum;

@end
