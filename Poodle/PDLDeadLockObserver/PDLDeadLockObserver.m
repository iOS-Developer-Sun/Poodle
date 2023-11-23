//
//  PDLDeadLockObserver.m
//  Poodle
//
//  Created by Poodle on 10/10/23.
//  Copyright © 2023 Poodle. All rights reserved.
//

#import "PDLDeadLockObserver.h"
#import <objc/objc-sync.h>
#import <pthread/pthread.h>
#import <os/lock.h>
#import "PDLGlobalLockItem.h"
#import "PDLObjectLockItem.h"
#import "pdl_hook.h"
#import "pdl_dispatch.h"
#import "pdl_thread_storage.h"
#import "NSObject+PDLImplementationInterceptor.h"

@interface PDLDeadLockObserverSyncObject : NSObject

@property (weak) id object;

@end

@implementation PDLDeadLockObserverSyncObject

@end

@interface PDLDeadLockObserverThreadStorage : NSObject

@property (nonatomic, assign) BOOL isObserving;
@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic, strong) NSMutableArray *waitingActions;
@property (nonatomic, strong) NSMutableArray *upstreamActionsList;

@end

@implementation PDLDeadLockObserverThreadStorage

- (instancetype)init {
    self = [super init];
    if (self) {
        _actions = [NSMutableArray array];
        _waitingActions = [NSMutableArray array];
        _upstreamActionsList = [NSMutableArray array];
    }
    return self;
}

@end


@implementation PDLDeadLockObserver

static void *_pdl_storage_key = &_pdl_storage_key;
static BOOL _realtime = NO;
static BOOL _enabled = NO;

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

+ (NSMutableArray *)actions {
    return [self storage].actions;
}

+ (NSMutableArray *)waitingActions {
    return [self storage].waitingActions;
}

+ (NSMutableArray *)upstreamActionsList {
    return [self storage].upstreamActionsList;
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

+ (void)pushWaitingAction:(PDLLockItemAction *)waitingAction {
    if (waitingAction) {
        [[self waitingActions] addObject:waitingAction];
    }
}

+ (void)popWaitingAction:(PDLLockItemAction *)waitingAction {
    if (waitingAction) {
        assert([self waitingActions].lastObject == waitingAction);
        [[self waitingActions] removeLastObject];
    }
}

+ (void)pushUpstreamActions:(NSArray *)upstreamActions {
    if (upstreamActions.count > 0) {
        [[self upstreamActionsList] addObject:upstreamActions];
    }
}

+ (void)popUpstreamActions:(NSArray *)upstreamActions {
    if (upstreamActions.count > 0) {
        assert([self upstreamActionsList].lastObject == upstreamActions);
        [[self upstreamActionsList] removeLastObject];
    }
}

+ (void)push:(PDLLockItemAction *)action {
    NSMutableArray *actions = [self actions];
    PDLLockItemAction *last = actions.lastObject;
    [actions addObject:action];
    [last.item action:last addChild:action];
}

+ (void)pop:(PDLLockItem *)lockItem {
    NSMutableArray *actions = [self actions];
    NSInteger index = NSNotFound;
    for (NSInteger i = actions.count - 1; i >=0; i--) {
        PDLLockItemAction *action = actions[i];
        if (action.item == lockItem) {
            index = i;
            break;
        }
    }
    assert(index != NSNotFound);
    [actions removeObjectAtIndex:index];
}

+ (BOOL)enterObserving {
    if (!_enabled) {
        return NO;
    }

    if ([self storage].isObserving) {
        return NO;
    }

    [self storage].isObserving = YES;
    return YES;
}

+ (void)leaveObserving {
    [self storage].isObserving = NO;
}

+ (BOOL)enabled {
    return _enabled;
}

#define PDL_DEADLOCK_OBSERVING_ENTER if ([PDLDeadLockObserver enterObserving]) {
#define PDL_DEADLOCK_OBSERVING_LEAVE [PDLDeadLockObserver leaveObserving];}

+ (PDLLockItem *)globalWaitItem {
    static PDLLockItem *_globalWaitItem = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalWaitItem = [[PDLGlobalLockItem alloc] init];
    });
    return _globalWaitItem;
}

+ (PDLLockItemAction *)syncWait:(dispatch_queue_t)queue {
    NSString *queueIdentifier = @(pdl_dispatch_get_queue_unique_identifier(queue)).stringValue;
    NSString *queueLabel = @(queue ? (dispatch_queue_get_label(queue) ?: "") : "");

    PDLLockItemAction *action = [[PDLLockItemAction alloc] init];
    action.item = [self globalWaitItem];
    [action.backtrace record:3];
    action.type = PDLLockItemActionTypeWait;
    action.targetQueueLabel = queueLabel;
    action.targetQueueIdentifier = queueIdentifier;
    return action;
}

+ (PDLLockItemAction *)lock:(PDLLockItem *)lockItem {
    PDLLockItemAction *action = [lockItem lock];
    [action.backtrace record:3];
    [self push:action];
    if (_realtime) {
        [lockItem check];
    }
    return action;
}

+ (void)unlock:(PDLLockItem *)lockItem {
    [PDLDeadLockObserver pop:lockItem];
}

#pragma mark -

#undef dispatch_once
static void (*pdl_dispatch_once_original)(dispatch_once_t *predicate, DISPATCH_NOESCAPE dispatch_block_t block) = NULL;
static void pdl_dispatch_once(dispatch_once_t *predicate, DISPATCH_NOESCAPE dispatch_block_t block) {
    PDLLockItem *lockItem = nil;
    PDLLockItemAction *action = nil;
    PDL_DEADLOCK_OBSERVING_ENTER;
    lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)predicate];
    action = [PDLDeadLockObserver lock:lockItem];
    action.subtype = PDLLockItemActionSubtypeDispatchOnce;
    PDL_DEADLOCK_OBSERVING_LEAVE;
    pdl_dispatch_once_original(predicate, block);
    PDL_DEADLOCK_OBSERVING_ENTER;
    [PDLDeadLockObserver unlock:lockItem];
    PDL_DEADLOCK_OBSERVING_LEAVE;
}

static void (*pdl_dispatch_sync_original)(dispatch_queue_t queue, DISPATCH_NOESCAPE dispatch_block_t block) = NULL;
static void pdl_dispatch_sync(dispatch_queue_t queue, DISPATCH_NOESCAPE dispatch_block_t block) {
    BOOL isSerialQueue = pdl_dispatch_get_queue_width(queue) == 1;
    PDLLockItemAction *child = nil;
    NSArray *actions = nil;
    PDL_DEADLOCK_OBSERVING_ENTER;
    if (isSerialQueue) {
        child = [PDLDeadLockObserver syncWait:queue];
        actions = [PDLDeadLockObserver actions];
        PDLLockItemAction *action = actions.lastObject;
        [action.item action:action addChild:child];
        NSArray *waitingActions = [PDLDeadLockObserver waitingActions];
        PDLLockItemAction *waitingAction = waitingActions.lastObject;
        [waitingAction.item action:waitingAction addChild:child];
        if (_realtime) {
            [action.item check];
            for (NSArray *upstreamActions in [PDLDeadLockObserver upstreamActionsList]) {
                for (PDLLockItemAction *upstreamAction in upstreamActions) {
                    [upstreamAction.item check];
                }
            }
        }
    }
    PDL_DEADLOCK_OBSERVING_LEAVE;
    pdl_dispatch_sync_original(queue, ^{
        if (isSerialQueue) {
            PDL_DEADLOCK_OBSERVING_ENTER;
            [PDLDeadLockObserver pushWaitingAction:child];
            [PDLDeadLockObserver pushUpstreamActions:actions];
            PDL_DEADLOCK_OBSERVING_LEAVE;
            block();
            PDL_DEADLOCK_OBSERVING_ENTER;
            [PDLDeadLockObserver popWaitingAction:child];
            [PDLDeadLockObserver popUpstreamActions:actions];
            PDL_DEADLOCK_OBSERVING_LEAVE;
        } else {
            block();
        }
    });
}

static int (*pdl_objc_sync_enter_original)(id object) = NULL;
static int pdl_objc_sync_enter(id object) {
    int ret = pdl_objc_sync_enter_original(object);
    if (object) {
        PDL_DEADLOCK_OBSERVING_ENTER;
        PDLDeadLockObserverSyncObject *syncObject = [PDLDeadLockObserver syncObject:object];
        PDLLockItem *lockItem = [PDLObjectLockItem lockItemWithObject:syncObject];
        PDLLockItemAction *action = [PDLDeadLockObserver lock:lockItem];
        action.subtype = PDLLockItemActionSubtypeSynchronized;
        PDL_DEADLOCK_OBSERVING_LEAVE;
    }
    return ret;
}

static int (*pdl_objc_sync_exit_original)(id object) = NULL;
static int pdl_objc_sync_exit(id object) {
    int ret = pdl_objc_sync_exit_original(object);
    if (object) {
        PDL_DEADLOCK_OBSERVING_ENTER;
        PDLDeadLockObserverSyncObject *syncObject = [PDLDeadLockObserver syncObject:object];
        PDLLockItem *lockItem = [PDLObjectLockItem lockItemWithObject:syncObject];
        [PDLDeadLockObserver unlock:lockItem];
        PDL_DEADLOCK_OBSERVING_LEAVE;
    }
    return ret;
}

#pragma mark -

static int (*pdl_pthread_mutex_lock_original)(pthread_mutex_t *) = NULL;
static int pdl_pthread_mutex_lock(pthread_mutex_t *lock) {
    int ret = pdl_pthread_mutex_lock_original(lock);
    PDL_DEADLOCK_OBSERVING_ENTER;
    PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
    PDLLockItemAction *action = [PDLDeadLockObserver lock:lockItem];
    action.subtype = PDLLockItemActionSubtypePthreadMutex;
    PDL_DEADLOCK_OBSERVING_LEAVE;
    return ret;
}

static int (*pdl_pthread_mutex_trylock_original)(pthread_mutex_t *) = NULL;
static int pdl_pthread_mutex_trylock(pthread_mutex_t *lock) {
    int ret = pdl_pthread_mutex_trylock_original(lock);
    if (ret == 0) {
        PDL_DEADLOCK_OBSERVING_ENTER;
        PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
        PDLLockItemAction *action = [PDLDeadLockObserver lock:lockItem];
        action.subtype = PDLLockItemActionSubtypePthreadMutex;
        PDL_DEADLOCK_OBSERVING_LEAVE;
    }
    return ret;
}

static int (*pdl_pthread_mutex_unlock_original)(pthread_mutex_t *) = NULL;
static int pdl_pthread_mutex_unlock(pthread_mutex_t *lock) {
    int ret = pdl_pthread_mutex_unlock_original(lock);
    PDL_DEADLOCK_OBSERVING_ENTER;
    PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
    [PDLDeadLockObserver unlock:lockItem];
    PDL_DEADLOCK_OBSERVING_LEAVE;
    return ret;
}

#pragma mark -

static int (*pdl_pthread_rwlock_rdlock_original)(pthread_rwlock_t *) = NULL;
static int pdl_pthread_rwlock_rdlock(pthread_rwlock_t *lock) {
    int ret = pdl_pthread_rwlock_rdlock_original(lock);
    PDL_DEADLOCK_OBSERVING_ENTER;
    PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
    PDLLockItemAction *action = [PDLDeadLockObserver lock:lockItem];
    action.subtype = PDLLockItemActionSubtypePthreadRWLock;
    PDL_DEADLOCK_OBSERVING_LEAVE;
    return ret;
}

static int (*pdl_pthread_rwlock_wrlock_original)(pthread_rwlock_t *) = NULL;
static int pdl_pthread_rwlock_wrlock(pthread_rwlock_t *lock) {
    int ret = pdl_pthread_rwlock_wrlock_original(lock);
    PDL_DEADLOCK_OBSERVING_ENTER;
    PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
    PDLLockItemAction *action = [PDLDeadLockObserver lock:lockItem];
    action.subtype = PDLLockItemActionSubtypePthreadRWLock;
    PDL_DEADLOCK_OBSERVING_LEAVE;
    return ret;
}

static int (*pdl_pthread_rwlock_tryrdlock_original)(pthread_rwlock_t *) = NULL;
static int pdl_pthread_rwlock_tryrdlock(pthread_rwlock_t *lock) {
    int ret = pdl_pthread_rwlock_tryrdlock_original(lock);
    if (ret == 0) {
        PDL_DEADLOCK_OBSERVING_ENTER;
        PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
        PDLLockItemAction *action = [PDLDeadLockObserver lock:lockItem];
        action.subtype = PDLLockItemActionSubtypePthreadRWLock;
        PDL_DEADLOCK_OBSERVING_LEAVE;
    }
    return ret;
}

static int (*pdl_pthread_rwlock_trywrlock_original)(pthread_rwlock_t *) = NULL;
static int pdl_pthread_rwlock_trywrlock(pthread_rwlock_t *lock) {
    int ret = pdl_pthread_rwlock_trywrlock_original(lock);
    if (ret == 0) {
        PDL_DEADLOCK_OBSERVING_ENTER;
        PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
        PDLLockItemAction *action = [PDLDeadLockObserver lock:lockItem];
        action.subtype = PDLLockItemActionSubtypePthreadRWLock;
        PDL_DEADLOCK_OBSERVING_LEAVE;
    }
    return ret;
}

static int (*pdl_pthread_rwlock_unlock_original)(pthread_rwlock_t *) = NULL;
static int pdl_pthread_rwlock_unlock(pthread_rwlock_t *lock) {
    int ret = pdl_pthread_rwlock_unlock_original(lock);
    PDL_DEADLOCK_OBSERVING_ENTER;
    PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
    [PDLDeadLockObserver unlock:lockItem];
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
        PDLLockItemAction *action = [PDLDeadLockObserver lock:lockItem];
        action.subtype = _class == [NSRecursiveLock class] ? PDLLockItemActionSubtypeNSRecursiveLock : PDLLockItemActionSubtypeNSLock;
    } else {
        [PDLDeadLockObserver unlock:lockItem];
    }
    PDL_DEADLOCK_OBSERVING_LEAVE;
}

static BOOL pdl_tryLock(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    BOOL ret = ((typeof(&pdl_tryLock))_imp)(self, _cmd);
    if (ret) {
        PDL_DEADLOCK_OBSERVING_ENTER;
        PDLLockItem *lockItem = [PDLObjectLockItem lockItemWithObject:self];
        PDLLockItemAction *action = [PDLDeadLockObserver lock:lockItem];
        action.subtype = _class == [NSRecursiveLock class] ? PDLLockItemActionSubtypeNSRecursiveLock : PDLLockItemActionSubtypeNSLock;
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
        PDLLockItemAction *action = [PDLDeadLockObserver lock:lockItem];
        action.subtype = _class == [NSRecursiveLock class] ? PDLLockItemActionSubtypeNSRecursiveLock : PDLLockItemActionSubtypeNSLock;
        PDL_DEADLOCK_OBSERVING_LEAVE;
    }
    return ret;
}

#pragma mark -

static void (*pdl_os_unfair_lock_lock_original)(os_unfair_lock_t) = NULL;
static void pdl_os_unfair_lock_lock(os_unfair_lock_t lock) {
    pdl_os_unfair_lock_lock_original(lock);
    PDL_DEADLOCK_OBSERVING_ENTER;
    PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
    PDLLockItemAction *action = [PDLDeadLockObserver lock:lockItem];
    action.subtype = PDLLockItemActionSubtypeOSUnfairLock;
    PDL_DEADLOCK_OBSERVING_LEAVE;
}

static bool (*pdl_os_unfair_lock_trylock_original)(os_unfair_lock_t) = NULL;
static bool pdl_os_unfair_lock_trylock(os_unfair_lock_t lock) {
    bool ret = pdl_os_unfair_lock_trylock_original(lock);
    if (ret) {
        PDL_DEADLOCK_OBSERVING_ENTER;
        PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
        PDLLockItemAction *action = [PDLDeadLockObserver lock:lockItem];
        action.subtype = PDLLockItemActionSubtypeOSUnfairLock;
        PDL_DEADLOCK_OBSERVING_LEAVE;
    }
    return ret;
}

static void (*pdl_os_unfair_lock_unlock_original)(os_unfair_lock_t) = NULL;
static void pdl_os_unfair_lock_unlock(os_unfair_lock_t lock) {
    pdl_os_unfair_lock_unlock_original(lock);
    PDL_DEADLOCK_OBSERVING_ENTER;
    PDLLockItem *lockItem = [PDLGlobalLockItem lockItemWithObject:(NSUInteger)lock];
    [PDLDeadLockObserver unlock:lockItem];
    PDL_DEADLOCK_OBSERVING_LEAVE;
}

#pragma mark -

+ (NSArray *)suspiciousDeadLockItems {
    return [PDLLockItem suspiciousDeadLockItems];
}

+ (void)observe:(BOOL)realtime {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _realtime = realtime;
        pdl_thread_storage_register(_pdl_storage_key, &pdl_lock_items_destroy);

        pdl_thread_storage_enabled();
        pdl_dispatch_queue_enable();

        int count = 0;
        pdl_hook_item items[15];
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

        items[count++] = (pdl_hook_item) {
            "os_unfair_lock_lock",
            &os_unfair_lock_lock,
            &pdl_os_unfair_lock_lock,
            (void **)&pdl_os_unfair_lock_lock_original,
        };
        items[count++] = (pdl_hook_item) {
            "os_unfair_lock_trylock",
            &os_unfair_lock_trylock,
            &pdl_os_unfair_lock_trylock,
            (void **)&pdl_os_unfair_lock_trylock_original,
        };
        items[count++] = (pdl_hook_item) {
            "os_unfair_lock_unlock",
            &os_unfair_lock_unlock,
            &pdl_os_unfair_lock_unlock,
            (void **)&pdl_os_unfair_lock_unlock_original,
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

        _enabled = YES;
    });
}

+ (void)check {
    _enabled = NO;
    NSArray *lockItems = [PDLLockItem lockItems];
    for (NSInteger i = 0; i < lockItems.count; i++) {
        PDLLockItem *lockItem = lockItems[i];
        [lockItem check];
    }
}

@end
