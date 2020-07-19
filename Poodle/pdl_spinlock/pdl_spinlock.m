//
//  pdl_spinlock.m
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "pdl_spinlock.h"
#import <stdatomic.h>
#import <mach/mach.h>

typedef struct {
    __volatile atomic_uint spin;
    uint32_t thread;
} _pdl_spinlock;

void pdl_spinlock_lock(pdl_spinlock_t spinlock) {
    _pdl_spinlock *lock = (_pdl_spinlock *)spinlock;
    while (atomic_flag_test_and_set((volatile atomic_flag *)&lock->spin));
//    while (__c11_atomic_exchange(&lock->spin, 1, __ATOMIC_SEQ_CST));
    lock->thread = mach_thread_self();
}

int pdl_spinlock_trylock(pdl_spinlock_t spinlock) {
    _pdl_spinlock *lock = (_pdl_spinlock *)spinlock;
    int ret = atomic_flag_test_and_set((volatile atomic_flag *)&lock->spin);
//    int ret = __c11_atomic_exchange((__volatile atomic_uint *)spinlock, 1, __ATOMIC_SEQ_CST);
    if (ret == 0) {
        lock->thread = mach_thread_self();
    }
    return ret;
}

void pdl_spinlock_unlock(pdl_spinlock_t spinlock) {
    _pdl_spinlock *lock = (_pdl_spinlock *)spinlock;
    __c11_atomic_store((__volatile atomic_uint *)spinlock, 0, __ATOMIC_SEQ_CST);
    lock->thread = 0;
}

mach_port_t pdl_spinlock_locked_thread(pdl_spinlock_t spinlock) {
    _pdl_spinlock *lock = (_pdl_spinlock *)spinlock;
    return lock->thread;
}
