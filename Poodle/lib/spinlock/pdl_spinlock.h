//
//  pdl_spinlock.h
//  Sun
//
//  Created by Sun on 14-6-27.
//
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct pdl_spinlock_s {
    uint32_t _pdl_spinlock_opaque;
} pdl_spinlock, *pdl_spinlock_t;

#ifndef PDL_SPINLOCK_INIT
#define PDL_SPINLOCK_INIT {0}
#endif

extern void pdl_spinlock_lock(pdl_spinlock_t spinlock);
extern int pdl_spinlock_trylock(pdl_spinlock_t spinlock);
extern void pdl_spinlock_unlock(pdl_spinlock_t spinlock);
extern mach_port_t pdl_spinlock_locked_thread(pdl_spinlock_t spinlock);

#ifdef __cplusplus
}
#endif
