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

/// private indexed ivar
@property (readonly) pthread_mutex_t *mutex;
/// private indexed ivar
@property (readonly) pthread_mutex_t *cond_mutex;
/// private indexed ivar
@property (readonly) pthread_cond_t *cond_cond;

@end

@interface NSConditionLock (Extension)

/// private indexed ivar
@property (readonly) NSCondition *cond;
/// private indexed ivar
@property (readonly) pthread_t thread;

@end

@interface NSRecursiveLock (Extension)

/// private indexed ivar, recursive
@property (readonly) pthread_mutex_t *mutex;
/// private indexed ivar
@property (readonly) pthread_t thread;
/// private indexed ivar
@property (readonly) NSInteger recursionCount;
/// private indexed ivar
@property (readonly) pthread_mutex_t *cond_mutex;
/// private indexed ivar
@property (readonly) pthread_cond_t *cond_cond;

@end

@interface NSCondition (Extension)

/// private indexed ivar, fairshare
@property (readonly) pthread_mutex_t *mutex;
/// private indexed ivar
@property (readonly) pthread_t thread API_DEPRECATED("UNAVAILABLE", ios(2.0,11.0));
/// private indexed ivar
@property (readonly) pthread_cond_t *cond;

@end
