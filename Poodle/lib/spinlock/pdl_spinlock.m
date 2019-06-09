//
//  pdl_spinlock.m
//  Sun
//
//  Created by Sun on 14-6-27.
//
//

#import "pdl_spinlock.h"
#import <stdatomic.h>
#import <mach/mach.h>

void pdl_spinlock_lock(pdl_spinlock_t spinlock) {
    while (__c11_atomic_exchange((__volatile atomic_uint *)spinlock, mach_thread_self(), __ATOMIC_SEQ_CST));
}

int pdl_spinlock_trylock(pdl_spinlock_t spinlock) {
    return __c11_atomic_exchange((__volatile atomic_uint *)spinlock, mach_thread_self(), __ATOMIC_SEQ_CST);
}

void pdl_spinlock_unlock(pdl_spinlock_t spinlock) {
    __c11_atomic_store((__volatile atomic_uint *)spinlock, 0, __ATOMIC_SEQ_CST);
}

mach_port_t pdl_spinlock_locked_thread(pdl_spinlock_t spinlock) {
    return spinlock->_pdl_spinlock_opaque;
}
