//
//  pdl_pthread_backtrace.h
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <pthread.h>

#ifdef __cplusplus
extern "C" {
#endif

int pdl_pthread_backtrace_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void *), void *arg, int (*pthread_create_original)(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void *), void *arg), unsigned int hidden_count);

#ifdef __cplusplus
}
#endif
