//
//  PDLDeadLockObserver.m
//  Poodle
//
//  Created by Poodle on 10/10/23.
//  Copyright © 2023 Poodle. All rights reserved.
//

#import "PDLDeadLockObserver.h"
#import "PDLGlobalLockItem.h"
#import "PDLObjectLockItem.h"
#import "pdl_hook.h"
#import "pdl_dispatch.h"
#import "pdl_thread_storage.h"
#import "PDLProcessInfo.h"
#import "NSObject+PDLImplementationInterceptor.h"
#import <objc/objc-sync.h>
#import <pthread/pthread.h>

@interface PDLDeadLockObserverSyncObject : NSObject

@property (weak) id object;

@end

@implementation PDLDeadLockObserverSyncObject

@end

@interface PDLDeadLockObserverThreadStorage : NSObject

@property (nonatomic, assign) BOOL isObserving;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *waitingItemsList;

@end

@implementation PDLDeadLockObserverThreadStorage

- (instancetype)init {
    self = [super init];
    if (self) {
        _items = [NSMutableArray array];
        _waitingItemsList = [NSMutableArray array];
    }
    return self;
}

@end


@implementation PDLDeadLockObserver

static void *_pdl_storage_key = &_pdl_storage_key;

__unused static void pdl_lock_items_destroy(void *arg) {
    PDLDeadLockObserverThreadStorage *s = (__bridge_transfer id)arg;
    s = nil;
}

+ (PDLDeadLockObserverThreadStorage *)storage {
    PDLDeadLockObserverThreadStorage *storage = nil;
    void **value = pdl_thread_storage_get(_pdl_storage_key);
    if (!value) {
        storage = [[PDLDeadLockObserverThreadStorage alloc] init];
        void *newValue = (__bridge_retained void *)(storage);
        pdl_thread_storage_set(_pdl_storage_key, &newValue);
    } else {
        storage = (__bridge id)*value;
    }
    return storage;
}

+ (NSMutableArray *)items {
    return [self storage].items;
}
+ (NSMutableArray *)waitingItemsList {
    return [self storage].waitingItemsList;
}

+ (PDLDeadLockObserverSyncObject *)syncObject:(id)object {
    static void *key = &key;
    PDLDeadLockObserverSyncObject *syncObject = objc_getAssociatedObject(object, key);
    if (!syncObject) {
        syncObject = [[PDLDeadLockObserverSyncObject alloc] init];
        syncObject.object = object;
        objc_setAssociatedObject(object, key, syncObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return syncObject;
}

+ (PDLLockItemAction *)lock:(PDLLockItem *)lockItem {
    NSArray *lockItems = [PDLDeadLockObserver items];
    PDLLockItemAction *action = [lockItem lock];
    for (PDLLockItem *each in lockItems) {
        if (each != lockItem) {
            [each addAction:action];
        }
    }
    return action;
}

+ (void)pushWaitingItems:(NSArray *)waitingItems {
    if (waitingItems) {
        [[self waitingItemsList] addObject:waitingItems];
    }
}

+ (void)popWaitingItems:(NSArray *)waitingItems {
    if (waitingItems) {
        assert([self waitingItemsList].lastObject == waitingItems);
        [[self waitingItemsList] removeLastObject];
    }
}

+ (void)push:(PDLLockItem *)lockItem {
    NSMutableArray *items = [self items];
    [items addObject:lockItem];
}

+ (void)pop:(PDLLockItem *)lockItem {
    NSMutableArray *items = [self items];
    if (items.lastObject == lockItem) {
        [items removeLastObject];
    }
}

+ (BOOL)enterObserving {
    if ([self storage].isObserving) {
        return NO;
    }

    [self storage].isObserving = YES;
    return YES;
}

+ (void)leaveObserving {
    assert([self storage].isObserving);
    [self storage].isObserving = NO;
}

#define PDL_DEADLOCK_OBSERVING_ENTER if ([PDLDeadLockObserver enterObserving]) {
#define PDL_DEADLOCK_OBSERVING_LEAVE [PDLDeadLockObserver leaveObserving];}

#pragma mark -

#undef dispatch_once
static void (*pdl_dispatch_once_original)(dispatch_once_t *predicate, DISPATCH_NOESCAPE dispatch_block_t block) = NULL;
static void pdl_dispatch_once(dispatch_once_t *predicate, DISPATCH_NOESCAPE dispatch_block_t block) {
    PDLLockItem *lockItem = nil;
    PDL_DEADLOCK_OBSERVING_ENTER;
    lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)predicate];
    [PDLDeadLockObserver push:lockItem];
    [PDLDeadLockObserver lock:lockItem].subtype = PDLLockItemActionSubtypeDispatchOnce;
    PDL_DEADLOCK_OBSERVING_LEAVE;
    pdl_dispatch_once_original(predicate, block);
    PDL_DEADLOCK_OBSERVING_ENTER;
    [PDLDeadLockObserver pop:lockItem];
    PDL_DEADLOCK_OBSERVING_LEAVE;
}

static void (*pdl_dispatch_sync_original)(dispatch_queue_t queue, DISPATCH_NOESCAPE dispatch_block_t block) = NULL;
static void pdl_dispatch_sync(dispatch_queue_t queue, DISPATCH_NOESCAPE dispatch_block_t block) {
    NSArray *lockItems = nil;
    BOOL isSerialQueue = pdl_dispatch_get_queue_width(queue) == 1;
    PDL_DEADLOCK_OBSERVING_ENTER;
    if (isSerialQueue) {
        lockItems = [PDLDeadLockObserver items];
        for (PDLLockItem *lockItem in lockItems) {
            [lockItem syncWait:queue];
        }
        NSArray *waitingItemsList = [PDLDeadLockObserver waitingItemsList];
        for (NSArray *waitingItems in waitingItemsList) {
            for (PDLLockItem *lockItem in waitingItems) {
                [lockItem syncWait:queue];
            }
        }
    }
    PDL_DEADLOCK_OBSERVING_LEAVE;
    pdl_dispatch_sync_original(queue, ^{
        if (isSerialQueue) {
            PDL_DEADLOCK_OBSERVING_ENTER;
            [PDLDeadLockObserver pushWaitingItems:lockItems];
            PDL_DEADLOCK_OBSERVING_LEAVE;
            block();
            PDL_DEADLOCK_OBSERVING_ENTER;
            [PDLDeadLockObserver popWaitingItems:lockItems];
            PDL_DEADLOCK_OBSERVING_LEAVE;
        } else {
            block();
        }
    });
}

int (*pdl_objc_sync_enter_original)(id object) = NULL;
static int pdl_objc_sync_enter(id object) {
    int ret = pdl_objc_sync_enter_original(object);
    if (object) {
        PDL_DEADLOCK_OBSERVING_ENTER;
        PDLDeadLockObserverSyncObject *syncObject = [PDLDeadLockObserver syncObject:object];
        PDLLockItem *lockItem = [PDLObjectLockItem lockItemWithObject:syncObject];
        [PDLDeadLockObserver push:lockItem];
        [PDLDeadLockObserver lock:lockItem].subtype = PDLLockItemActionSubtypeSynchronized;
        PDL_DEADLOCK_OBSERVING_LEAVE;
    }
    return ret;
}

int (*pdl_objc_sync_exit_original)(id object) = NULL;
static int pdl_objc_sync_exit(id object) {
    int ret = pdl_objc_sync_exit_original(object);
    if (object) {
        PDL_DEADLOCK_OBSERVING_ENTER;
        id syncObject = [PDLDeadLockObserver syncObject:object];
        PDLLockItem *lockItem = [PDLObjectLockItem lockItemWithObject:syncObject];
        [PDLDeadLockObserver pop:lockItem];
        PDL_DEADLOCK_OBSERVING_LEAVE;
    }
    return ret;
}

#pragma mark -

int (*pdl_pthread_mutex_lock_original)(pthread_mutex_t *) = NULL;
static int pdl_pthread_mutex_lock(pthread_mutex_t *lock) {
    int ret = pdl_pthread_mutex_lock_original(lock);
    PDL_DEADLOCK_OBSERVING_ENTER;
    PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
    [PDLDeadLockObserver push:lockItem];
    [PDLDeadLockObserver lock:lockItem].subtype = PDLLockItemActionSubtypePthreadMutex;
    PDL_DEADLOCK_OBSERVING_LEAVE;
    return ret;
}

int (*pdl_pthread_mutex_trylock_original)(pthread_mutex_t *) = NULL;
static int pdl_pthread_mutex_trylock(pthread_mutex_t *lock) {
    int ret = pdl_pthread_mutex_trylock_original(lock);
    if (ret == 0) {
        PDL_DEADLOCK_OBSERVING_ENTER;
        PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
        [PDLDeadLockObserver push:lockItem];
        [PDLDeadLockObserver lock:lockItem].subtype = PDLLockItemActionSubtypePthreadMutex;
        PDL_DEADLOCK_OBSERVING_LEAVE;
    }
    return ret;
}

int (*pdl_pthread_mutex_unlock_original)(pthread_mutex_t *) = NULL;
static int pdl_pthread_mutex_unlock(pthread_mutex_t *lock) {
    int ret = pdl_pthread_mutex_unlock_original(lock);
    PDL_DEADLOCK_OBSERVING_ENTER;
    PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
    [PDLDeadLockObserver pop:lockItem];
    PDL_DEADLOCK_OBSERVING_LEAVE;
    return ret;
}

#pragma mark -

int (*pdl_pthread_rwlock_rdlock_original)(pthread_rwlock_t *) = NULL;
static int pdl_pthread_rwlock_rdlock(pthread_rwlock_t *lock) {
    int ret = pdl_pthread_rwlock_rdlock_original(lock);
    PDL_DEADLOCK_OBSERVING_ENTER;
    PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
    [PDLDeadLockObserver push:lockItem];
    [PDLDeadLockObserver lock:lockItem].subtype = PDLLockItemActionSubtypePthreadRWLock;
    PDL_DEADLOCK_OBSERVING_LEAVE;
    return ret;
}

int (*pdl_pthread_rwlock_wrlock_original)(pthread_rwlock_t *) = NULL;
static int pdl_pthread_rwlock_wrlock(pthread_rwlock_t *lock) {
    int ret = pdl_pthread_rwlock_wrlock_original(lock);
    PDL_DEADLOCK_OBSERVING_ENTER;
    PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
    [PDLDeadLockObserver push:lockItem];
    [PDLDeadLockObserver lock:lockItem].subtype = PDLLockItemActionSubtypePthreadRWLock;
    PDL_DEADLOCK_OBSERVING_LEAVE;
    return ret;
}

int (*pdl_pthread_rwlock_tryrdlock_original)(pthread_rwlock_t *) = NULL;
static int pdl_pthread_rwlock_tryrdlock(pthread_rwlock_t *lock) {
    int ret = pdl_pthread_rwlock_tryrdlock_original(lock);
    if (ret == 0) {
        PDL_DEADLOCK_OBSERVING_ENTER;
        PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
        [PDLDeadLockObserver push:lockItem];
        [PDLDeadLockObserver lock:lockItem].subtype = PDLLockItemActionSubtypePthreadRWLock;
        PDL_DEADLOCK_OBSERVING_LEAVE;
    }
    return ret;
}

int (*pdl_pthread_rwlock_trywrlock_original)(pthread_rwlock_t *) = NULL;
static int pdl_pthread_rwlock_trywrlock(pthread_rwlock_t *lock) {
    int ret = pdl_pthread_rwlock_trywrlock_original(lock);
    if (ret == 0) {
        PDL_DEADLOCK_OBSERVING_ENTER;
        PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
        [PDLDeadLockObserver push:lockItem];
        [PDLDeadLockObserver lock:lockItem].subtype = PDLLockItemActionSubtypePthreadRWLock;
        PDL_DEADLOCK_OBSERVING_LEAVE;
    }
    return ret;
}

int (*pdl_pthread_rwlock_unlock_original)(pthread_rwlock_t *) = NULL;
static int pdl_pthread_rwlock_unlock(pthread_rwlock_t *lock) {
    int ret = pdl_pthread_rwlock_unlock_original(lock);
    PDL_DEADLOCK_OBSERVING_ENTER;
    PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
    [PDLDeadLockObserver pop:lockItem];
    PDL_DEADLOCK_OBSERVING_LEAVE;
    return ret;
}

#pragma mark -

static void pdl_lock_unlock(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    ((typeof(&pdl_lock_unlock))_imp)(self, _cmd);

    PDL_DEADLOCK_OBSERVING_ENTER;
    PDLLockItem *lockItem = [PDLObjectLockItem lockItemWithObject:self];
    if (sel_isEqual(_cmd, @selector(lock))) {
        [PDLDeadLockObserver push:lockItem];
        [PDLDeadLockObserver lock:lockItem].subtype = _class == [NSRecursiveLock class] ? PDLLockItemActionSubtypeNSRecursiveLock : PDLLockItemActionSubtypeNSLock;
    } else {
        [PDLDeadLockObserver pop:lockItem];
    }
    PDL_DEADLOCK_OBSERVING_LEAVE;
}

static BOOL pdl_tryLock(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    BOOL ret = ((typeof(&pdl_tryLock))_imp)(self, _cmd);
    if (ret) {
        PDL_DEADLOCK_OBSERVING_ENTER;
        PDLLockItem *lockItem = [PDLObjectLockItem lockItemWithObject:self];
        [PDLDeadLockObserver push:lockItem];
        [PDLDeadLockObserver lock:lockItem].subtype = _class == [NSRecursiveLock class] ? PDLLockItemActionSubtypeNSRecursiveLock : PDLLockItemActionSubtypeNSLock;
        PDL_DEADLOCK_OBSERVING_LEAVE;
    }
    return ret;
}

static BOOL pdl_lockBeforeDate(__unsafe_unretained id self, SEL _cmd, id date) {
    PDLImplementationInterceptorRecover(_cmd);
    BOOL ret = ((typeof(&pdl_lockBeforeDate))_imp)(self, _cmd, date);
    if (ret) {
        PDL_DEADLOCK_OBSERVING_ENTER;
        PDLLockItem *lockItem = [PDLObjectLockItem lockItemWithObject:self];
        [PDLDeadLockObserver push:lockItem];
        [PDLDeadLockObserver lock:lockItem].subtype = _class == [NSRecursiveLock class] ? PDLLockItemActionSubtypeNSRecursiveLock : PDLLockItemActionSubtypeNSLock;
        PDL_DEADLOCK_OBSERVING_LEAVE;
    }
    return ret;
}

+ (NSArray *)suspiciousDeadLockItems {
    return [PDLLockItem suspiciousDeadLockItems];
}

+ (void)observe {
    PDLLockItemAction.processStartDate = [PDLProcessInfo sharedInstance].processStartDate;
    pdl_thread_storage_register(_pdl_storage_key, &pdl_lock_items_destroy);

    pdl_thread_storage_enabled();
    pdl_dispatch_queue_enable();

    int count = 0;
    pdl_hook_item items[12];
    items[count++] = (pdl_hook_item) {
        "dispatch_once",
        &dispatch_once,
        &pdl_dispatch_once,
        (void **)&pdl_dispatch_once_original,
    };
    items[count++] = (pdl_hook_item) {
        "dispatch_sync",
        &dispatch_sync,
        &pdl_dispatch_sync,
        (void **)&pdl_dispatch_sync_original,
    };

    items[count++] = (pdl_hook_item) {
        "objc_sync_enter",
        &objc_sync_enter,
        &pdl_objc_sync_enter,
        (void **)&pdl_objc_sync_enter_original,
    };
    items[count++] = (pdl_hook_item) {
        "objc_sync_exit",
        &objc_sync_exit,
        &pdl_objc_sync_exit,
        (void **)&pdl_objc_sync_exit_original,
    };

    items[count++] = (pdl_hook_item) {
        "pthread_mutex_lock",
        &pthread_mutex_lock,
        &pdl_pthread_mutex_lock,
        (void **)&pdl_pthread_mutex_lock_original,
    };
    items[count++] = (pdl_hook_item) {
        "pthread_mutex_trylock",
        &pthread_mutex_trylock,
        &pdl_pthread_mutex_trylock,
        (void **)&pdl_pthread_mutex_trylock_original,
    };
    items[count++] = (pdl_hook_item) {
        "pthread_mutex_unlock",
        &pthread_mutex_unlock,
        &pdl_pthread_mutex_unlock,
        (void **)&pdl_pthread_mutex_unlock_original,
    };

    items[count++] = (pdl_hook_item) {
        "pthread_rwlock_rdlock",
        &pthread_rwlock_rdlock,
        &pdl_pthread_rwlock_rdlock,
        (void **)&pdl_pthread_rwlock_rdlock_original,
    };
    items[count++] = (pdl_hook_item) {
        "pthread_rwlock_wrlock",
        &pthread_rwlock_wrlock,
        &pdl_pthread_rwlock_wrlock,
        (void **)&pdl_pthread_rwlock_wrlock_original,
    };
    items[count++] = (pdl_hook_item) {
        "pthread_rwlock_tryrdlock",
        &pthread_rwlock_tryrdlock,
        &pdl_pthread_rwlock_tryrdlock,
        (void **)&pdl_pthread_rwlock_tryrdlock_original,
    };
    items[count++] = (pdl_hook_item) {
        "pthread_rwlock_trywrlock",
        &pthread_rwlock_trywrlock,
        &pdl_pthread_rwlock_trywrlock,
        (void **)&pdl_pthread_rwlock_trywrlock_original,
    };
    items[count++] = (pdl_hook_item) {
        "pthread_rwlock_unlock",
        &pthread_rwlock_unlock,
        &pdl_pthread_rwlock_unlock,
        (void **)&pdl_pthread_rwlock_unlock_original,
    };

    int ret = pdl_hook(items, count);
    (void)ret;

    [NSLock pdl_interceptSelector:@selector(lock) withInterceptorImplementation:(IMP)&pdl_lock_unlock];
    [NSLock pdl_interceptSelector:@selector(unlock) withInterceptorImplementation:(IMP)&pdl_lock_unlock];
    [NSLock pdl_interceptSelector:@selector(tryLock) withInterceptorImplementation:(IMP)pdl_tryLock];
    [NSLock pdl_interceptSelector:@selector(lockBeforeDate:) withInterceptorImplementation:(IMP)pdl_lockBeforeDate];

    [NSRecursiveLock pdl_interceptSelector:@selector(lock) withInterceptorImplementation:(IMP)&pdl_lock_unlock];
    [NSRecursiveLock pdl_interceptSelector:@selector(unlock) withInterceptorImplementation:(IMP)&pdl_lock_unlock];
    [NSRecursiveLock pdl_interceptSelector:@selector(tryLock) withInterceptorImplementation:(IMP)pdl_tryLock];
    [NSRecursiveLock pdl_interceptSelector:@selector(lockBeforeDate:) withInterceptorImplementation:(IMP)pdl_lockBeforeDate];
}

@end
