//
//  NSThread+PDLExtension.h
//  Sun
//
//  Created by Sun on 14-6-27.
//
//

#import <pthread.h>
#import <Foundation/Foundation.h>

@interface NSThread (PDLExtension)

@property (readonly, class) NSArray *pdl_allThreads;
@property (readonly, class) NSString *pdl_allThreadsDescription;

@property (readonly) pthread_t pdl_pthread;
@property (readonly) int pdl_seqNum;

extern NSString *pdl_NSThreadsDescription(void);

@end
