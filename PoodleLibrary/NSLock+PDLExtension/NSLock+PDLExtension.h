//
//  NSLock+PDLExtension.h
//  Poodle
//
//  Created by Poodle on 07/04/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

@interface NSLock (PDLExtension)

@property (readonly) pthread_mutex_t *mutex;
@property (readonly) pthread_t thread API_DEPRECATED("UNAVAILABLE", ios(2.0,11.0));
@property (readonly) pthread_mutex_t *cond_mutex;
@property (readonly) pthread_cond_t *cond_cond;

@end

@interface NSConditionLock (Extension)

@property (readonly) NSCondition *cond;
@property (readonly) pthread_t thread;

@end

@interface NSRecursiveLock (Extension)

@property (readonly) pthread_mutex_t *mutex; // recursive
@property (readonly) pthread_t thread;
@property (readonly) NSInteger recursionCount;
@property (readonly) pthread_mutex_t *cond_mutex;
@property (readonly) pthread_cond_t *cond_cond;

@end

@interface NSCondition (Extension)

@property (readonly) pthread_mutex_t *mutex; // fairshare
@property (readonly) pthread_t thread API_DEPRECATED("UNAVAILABLE", ios(2.0,11.0));
@property (readonly) pthread_cond_t *cond;

@end
