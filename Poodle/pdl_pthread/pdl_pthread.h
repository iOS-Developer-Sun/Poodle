//
//  pdl_pthread.h
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    PTHREAD_TYPE_UNKNOWN,
    PTHREAD_TYPE_MUTEX,
    PTHREAD_TYPE_MUTEX_ATTR,
    PTHREAD_TYPE_COND,
    PTHREAD_TYPE_COND_ATTR,
    PTHREAD_TYPE_ONCE,
    PTHREAD_TYPE_THREAD,
    PTHREAD_TYPE_THREAD_ATTR,
    PTHREAD_TYPE_RWLOCK,
    PTHREAD_TYPE_RWLOCK_ATTR,
} pthread_type_t;

extern pthread_type_t pdl_pthread_type(void *pthread_pointer);

extern uint64_t pdl_pthread_thread_id(pthread_t thread);

extern bool pdl_pthread_mutex_is_fairshare(pthread_mutex_t *mutex);
extern bool pdl_pthread_mutex_is_firstfit(pthread_mutex_t *mutex);
extern bool pdl_pthread_mutex_is_recursive(pthread_mutex_t *mutex);

extern uint32_t pdl_pthread_mutex_recursion_count(pthread_mutex_t *mutex);

extern uint64_t pdl_pthread_mutex_locked_tid(pthread_mutex_t *mutex);
extern int pdl_pthread_mutex_waiters(pthread_mutex_t *mutex);

extern uint64_t pdl_pthread_rwlock_locked_tid(pthread_rwlock_t *rwlock);
extern uint32_t pdl_pthread_rwlock_lockers(pthread_rwlock_t *rwlock);

extern pthread_mutex_t *pdl_pthread_cond_busy(pthread_cond_t *cond);

#ifdef __cplusplus
}
#endif
