//
//  pdl_pthread.m
//  Sun
//
//  Created by Sun on 14-6-27.
//
//

#import "pdl_pthread.h"
#import <os/lock.h>
#import <dlfcn.h>
#import "pdl_mach_o_symbols.h"
#import "pdl_mach_object.h"

static uint32_t _majorVersion = 0;
static uint32_t _minorVersion = 0;
static uint32_t _revisionVersion = 0;

#define _PTHREAD_NO_SIG            0x00000000
#define _PTHREAD_MUTEX_ATTR_SIG        0x4D545841  /* 'MTXA' */
#define _PTHREAD_MUTEX_SIG        0x4D555458  /* 'MUTX' */
#define _PTHREAD_MUTEX_SIG_fast        0x4D55545A  /* 'MUTZ' */
#define _PTHREAD_MUTEX_SIG_MASK        0xfffffffd
#define _PTHREAD_MUTEX_SIG_CMP        0x4D555458  /* _PTHREAD_MUTEX_SIG & _PTHREAD_MUTEX_SIG_MASK */
#define _PTHREAD_MUTEX_SIG_init        0x32AAABA7  /* [almost] ~'MUTX' */
#define _PTHREAD_ERRORCHECK_MUTEX_SIG_init      0x32AAABA1
#define _PTHREAD_RECURSIVE_MUTEX_SIG_init       0x32AAABA2
#define _PTHREAD_FIRSTFIT_MUTEX_SIG_init        0x32AAABA3
#define _PTHREAD_MUTEX_SIG_init_MASK            0xfffffff0
#define _PTHREAD_MUTEX_SIG_init_CMP             0x32AAABA0
#define _PTHREAD_COND_ATTR_SIG        0x434E4441  /* 'CNDA' */
#define _PTHREAD_COND_SIG        0x434F4E44  /* 'COND' */
#define _PTHREAD_COND_SIG_init        0x3CB0B1BB  /* [almost] ~'COND' */
#define _PTHREAD_ATTR_SIG        0x54484441  /* 'THDA' */
#define _PTHREAD_ONCE_SIG        0x4F4E4345  /* 'ONCE' */
#define _PTHREAD_ONCE_SIG_init        0x30B1BCBA  /* [almost] ~'ONCE' */
#define _PTHREAD_SIG            0x54485244  /* 'THRD' */
#define _PTHREAD_RWLOCK_ATTR_SIG    0x52574C41  /* 'RWLA' */
#define _PTHREAD_RWLOCK_SIG        0x52574C4B  /* 'RWLK' */
#define _PTHREAD_RWLOCK_SIG_init    0x2DA8B3B4  /* [almost] ~'RWLK' */

#define _PTHREAD_MTX_OPT_POLICY_FAIRSHARE 1
#define _PTHREAD_MTX_OPT_POLICY_FIRSTFIT 2
#define _PTHREAD_MTX_OPT_POLICY_DEFAULT _PTHREAD_MTX_OPT_POLICY_FIRSTFIT

#define PTHRW_COUNT_SHIFT    8
#define PTHRW_INC        (1 << PTHRW_COUNT_SHIFT)
#define PTHRW_BIT_MASK        ((1 << PTHRW_COUNT_SHIFT) - 1)
#define PTHRW_COUNT_MASK     ((uint32_t)~PTHRW_BIT_MASK)
#define PTHRW_MAX_READERS     PTHRW_COUNT_MASK

typedef union mutex_seq {
    uint32_t seq[2];
    struct { uint32_t lgenval; uint32_t ugenval; };
    struct { uint32_t mgen; uint32_t ugen; };
    uint64_t seq_LU;
    uint64_t _Atomic atomic_seq_LU;
} mutex_seq;

_Static_assert(sizeof(mutex_seq) == 2 * sizeof(uint32_t),
               "Incorrect mutex_seq size");

typedef union rwlock_seq {
    uint32_t seq[4];
    struct { uint32_t lcntval; uint32_t rw_seq; uint32_t ucntval; };
    struct { uint32_t lgen; uint32_t rw_wc; uint32_t ugen; };
#if RWLOCK_USE_INT128
    unsigned __int128 seq_LSU;
    unsigned __int128 _Atomic atomic_seq_LSU;
#endif
    struct {
        uint64_t seq_LS;
        uint32_t seq_U;
        uint32_t _pad;
    };
    struct {
        uint64_t _Atomic atomic_seq_LS;
        uint32_t _Atomic atomic_seq_U;
        uint32_t _Atomic _atomic_pad;
    };
} rwlock_seq;

_Static_assert(sizeof(rwlock_seq) == 4 * sizeof(uint32_t),
               "Incorrect rwlock_seq size");

static inline int diff_genseq(uint32_t x, uint32_t y) {
    x &= PTHRW_COUNT_MASK;
    y &= PTHRW_COUNT_MASK;
    if (x == y) {
        return 0;
    } else if (x > y)  {
        return x - y;
    } else {
        return ((PTHRW_MAX_READERS - y) + x + PTHRW_INC);
    }
}

struct _pthread_mutex_options {
    uint32_t protocol:2,
    type:2,
    pshared:2,
    policy:3,
    hold:2,
    misalign:1,
    notify:1,
    mutex:1,
    unused:2,
    lock_count:16;
};

//typedef os_unfair_lock _pthread_lock;
typedef uint32_t _pthread_lock;

typedef struct {
    long sig;
    _pthread_lock lock;
    union {
        uint32_t value;
        struct _pthread_mutex_options options;
    } mtxopts;
    int16_t prioceiling;
    int16_t priority;
#if defined(__LP64__)
    uint32_t _pad;
#endif
    uint32_t m_tid[2]; // thread id of thread that has mutex locked
    uint32_t m_seq[2]; // mutex sequence id
    uint32_t m_mis[2]; // for misaligned locks m_tid/m_seq will span into here
#if defined(__LP64__)
    uint32_t _reserved[4];
#else
    uint32_t _reserved[1];
#endif
} _pthread_mutex;

typedef struct {
    long sig;
    _pthread_lock lock;
    uint32_t unused:29,
misalign:1,
pshared:2;
    _pthread_mutex *busy;
    uint32_t c_seq[3];
#if defined(__LP64__)
    uint32_t _reserved[3];
#endif
} _pthread_cond;

typedef struct {
    long sig;
    _pthread_lock lock;
    uint32_t unused:29,
misalign:1,
pshared:2;
    uint32_t rw_flags;
#if defined(__LP64__)
    uint32_t _pad;
#endif
    volatile uint32_t rw_seq[4];
    struct _pthread *rw_owner;
    volatile uint32_t *rw_lcntaddr;
    volatile uint32_t *rw_seqaddr;
    volatile uint32_t *rw_ucntaddr;
#if defined(__LP64__)
    uint32_t _reserved[31];
#else
    uint32_t _reserved[19];
#endif
} _pthread_rwlock; // libpthread-218.60.3

typedef struct {
    long sig;
    _pthread_lock lock;
    uint32_t unused:29,
misalign:1,
pshared:2;
    uint32_t rw_flags;
#if defined(__LP64__)
    uint32_t _pad;
#endif
    uint32_t rw_tid[2]; // thread id of thread that has exclusive (write) lock
    uint32_t rw_seq[4]; // rw sequence id (at 128-bit aligned boundary)
    uint32_t rw_mis[4]; // for misaligned locks rw_seq will span into here
#if defined(__LP64__)
    uint32_t _reserved[34];
#else
    uint32_t _reserved[18];
#endif
} _pthread_rwlock2; // libpthread-330.220.2

pthread_type_t pthread_type(void *pthread_pointer) {
    pthread_type_t type = PTHREAD_TYPE_UNKNOWN;
    long sig = *((long *)pthread_pointer);
    switch (sig) {
        case _PTHREAD_MUTEX_ATTR_SIG:
            type = PTHREAD_TYPE_MUTEX_ATTR;
            break;
        case _PTHREAD_MUTEX_SIG:
        case _PTHREAD_MUTEX_SIG_fast:
        case _PTHREAD_MUTEX_SIG_init:
        case _PTHREAD_ERRORCHECK_MUTEX_SIG_init:
        case _PTHREAD_RECURSIVE_MUTEX_SIG_init:
        case _PTHREAD_FIRSTFIT_MUTEX_SIG_init:
            type = PTHREAD_TYPE_MUTEX;
            break;
        case _PTHREAD_COND_ATTR_SIG:
            type = PTHREAD_TYPE_COND_ATTR;
            break;
        case _PTHREAD_COND_SIG:
        case _PTHREAD_COND_SIG_init:
            type = PTHREAD_TYPE_COND;
            break;
        case _PTHREAD_ONCE_SIG:
        case _PTHREAD_ONCE_SIG_init:
            type = PTHREAD_TYPE_ONCE;
            break;
        case _PTHREAD_SIG:
            type = PTHREAD_TYPE_THREAD;
            break;
        case _PTHREAD_ATTR_SIG:
            type = PTHREAD_TYPE_THREAD_ATTR;
            break;
        case _PTHREAD_RWLOCK_SIG:
        case _PTHREAD_RWLOCK_SIG_init:
            type = PTHREAD_TYPE_RWLOCK;
            break;
        case _PTHREAD_RWLOCK_ATTR_SIG:
            type = PTHREAD_TYPE_RWLOCK_ATTR;
            break;

        default:
            type = PTHREAD_TYPE_UNKNOWN;
            break;
    }
    return type;
}

static void RWLOCK_GETSEQ_ADDR(_pthread_rwlock *rwlock,
                               volatile uint32_t **lcntaddr,
                               volatile uint32_t **ucntaddr,
                               volatile uint32_t **seqaddr)
{
    if (rwlock->pshared == PTHREAD_PROCESS_SHARED) {
        if (rwlock->misalign) {
            *lcntaddr = &rwlock->rw_seq[1];
            *seqaddr = &rwlock->rw_seq[2];
            *ucntaddr = &rwlock->rw_seq[3];
        } else {
            *lcntaddr = &rwlock->rw_seq[0];
            *seqaddr = &rwlock->rw_seq[1];
            *ucntaddr = &rwlock->rw_seq[2];
        }
    } else {
        *lcntaddr = rwlock->rw_lcntaddr;
        *seqaddr = rwlock->rw_seqaddr;
        *ucntaddr = rwlock->rw_ucntaddr;
    }
}

uint64_t pdl_pthread_thread_id(pthread_t thread) {
    uint64_t thread_id = 0;
    pthread_threadid_np(thread, &thread_id); // offset: 0xd8 216 for __LP64__
    return thread_id;
}

bool pdl_pthread_mutex_is_fairshare(pthread_mutex_t *omutex) {
    _pthread_mutex *mutex = (_pthread_mutex *)omutex;
    return (mutex->mtxopts.options.policy == _PTHREAD_MTX_OPT_POLICY_FAIRSHARE);
}

bool pdl_pthread_mutex_is_firstfit(pthread_mutex_t *omutex) {
    _pthread_mutex *mutex = (_pthread_mutex *)omutex;
    return (mutex->mtxopts.options.policy == _PTHREAD_MTX_OPT_POLICY_FIRSTFIT);
}

bool pdl_pthread_mutex_is_recursive(pthread_mutex_t *omutex) {
    _pthread_mutex *mutex = (_pthread_mutex *)omutex;
    return (mutex->mtxopts.options.type == PTHREAD_MUTEX_RECURSIVE);
}

uint32_t pdl_pthread_mutex_recursion_count(pthread_mutex_t *omutex) {
    _pthread_mutex *mutex = (_pthread_mutex *)omutex;
    return mutex->mtxopts.options.lock_count;
}

uint64_t pdl_pthread_mutex_locked_tid(pthread_mutex_t *omutex) {
    _pthread_mutex *mutex = (_pthread_mutex *)omutex;
    uint64_t *tidaddr = (void *)(((uintptr_t)mutex->m_tid + 0x7ul) & ~0x7ul);
    return *tidaddr;
}

int pdl_pthread_mutex_waiters(pthread_mutex_t *omutex) {
    _pthread_mutex *mutex = (_pthread_mutex *)omutex;
    mutex_seq *seqaddr = (void *)(((uintptr_t)mutex->m_seq + 0x7ul) & ~0x7ul);
    int numwaiters = diff_genseq(seqaddr->lgenval, seqaddr->ugenval) >> PTHRW_COUNT_SHIFT;
    if (_majorVersion <= 301) {
        numwaiters--;
        if (numwaiters < 0) {
            numwaiters = 0;
        }
    }
    return numwaiters;
}

uint64_t pdl_pthread_rwlock_locked_tid(pthread_rwlock_t *orwlock) {
    if (_majorVersion > 218) {
        _pthread_rwlock2 *rwlock = (_pthread_rwlock2 *)orwlock;
        uint64_t *tidaddr = (void *)(((uintptr_t)rwlock->rw_tid + 0x7ul) & ~0x7ul);
        return *tidaddr;
    } else {
        _pthread_rwlock *rwlock = (_pthread_rwlock *)orwlock;
        pthread_t owner = (pthread_t)rwlock->rw_owner;
        if (owner) {
            return pdl_pthread_thread_id(owner);
        }
        return 0;
    }
}

uint32_t pdl_pthread_rwlock_lockers(pthread_rwlock_t *orwlock) {
    if (_majorVersion > 218) {
        _pthread_rwlock2 *rwlock = (_pthread_rwlock2 *)orwlock;
        rwlock_seq *seqaddr = (void *)(((uintptr_t)rwlock->rw_seq + 0xful) & ~0xful);
        int numwaiters = diff_genseq(seqaddr->lcntval, seqaddr->ucntval) >> PTHRW_COUNT_SHIFT;
        return numwaiters;
    } else {
        _pthread_rwlock *rwlock = (_pthread_rwlock *)orwlock;
        volatile uint32_t *lcntaddr, *ucntaddr, *seqaddr;
        RWLOCK_GETSEQ_ADDR(rwlock, &lcntaddr, &ucntaddr, &seqaddr);
        int numwaiters = diff_genseq(*lcntaddr, *ucntaddr) >> PTHRW_COUNT_SHIFT;
        return numwaiters;
    }
}

pthread_mutex_t *pdl_pthread_cond_busy(pthread_cond_t *ocond) {
    _pthread_cond *cond = (_pthread_cond *)ocond;
    return (pthread_mutex_t *)cond->busy;
}

PDL_MACH_O_SYMBOLS_POINTER_FUNCTION_DECLARATION(nsthread_get_0_pointer, "Foundation", "_NSThreadGet0")
NSThread *pdl_pthread_nsthread(pthread_t thread) {
    NSThread *(*_NSThreadGet0)(pthread_t) = (typeof(_NSThreadGet0))nsthread_get_0_pointer();
    if (!_NSThreadGet0) {
        return nil;
    }

    NSThread *nsthread = _NSThreadGet0(thread);
    return nsthread;
}

PDL_MACH_O_SYMBOLS_POINTER_FUNCTION_DECLARATION(pthread_count_pointer, "libsystem_pthread.dylib", "_pthread_count")
int pdl_pthread_count(void) {
    int *pthreadCount = (typeof(pthreadCount))pthread_count_pointer();
    if (!pthreadCount) {
        return 0;
    }
    return *pthreadCount;
}

__attribute__ ((constructor)) static void check_version(void) {
    const char *name = "libsystem_pthread.dylib";
    struct mach_header *header = pdl_mach_o_image(name);
    struct pdl_mach_object mach_object;
    bool ret = pdl_get_mach_object_with_header(header, -1, name, -1, &mach_object);
    if (ret) {
        uint32_t version = 0;
        if (mach_object.id_dylib_dylib_command) {
            version = mach_object.id_dylib_dylib_command->dylib.current_version;
        }
        _majorVersion = version >> 16;
        _minorVersion = (version >> 8) & 0xff;
        _revisionVersion = version & 0xff;
    }
}

