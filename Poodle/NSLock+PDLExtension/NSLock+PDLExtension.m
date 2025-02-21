//
//  NSLock+PDLExtension.m
//  Poodle
//
//  Created by Poodle on 07/04/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSLock+PDLExtension.h"

#if __has_feature(objc_arc)
#error This file must be compiled with flag "-fno-objc-arc"
#endif

typedef struct {
    pthread_mutex_t mutex;
    pthread_t thread;
    struct {
        pthread_mutex_t mutex;
        pthread_cond_t cond;
    } *cond;
    NSString *name;
} NSLockIndexedIvars;

typedef struct {
    pthread_mutex_t mutex;
    struct {
        pthread_mutex_t mutex;
        pthread_cond_t cond;
    } *cond;
    NSString *name;
} NSLockIndexedIvars2;

@implementation NSLock (Extension)

- (pthread_mutex_t *)mutex {
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
        NSLockIndexedIvars2 *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->mutex;
    } else {
        NSLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->mutex;
    }
}

- (pthread_mutex_t *)cond_mutex {
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
        NSLockIndexedIvars2 *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->cond->mutex;
    } else {
        NSLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->cond->mutex;
    }
}

- (pthread_cond_t *)cond_cond {
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
        NSLockIndexedIvars2 *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->cond->cond;
    } else {
        NSLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->cond->cond;
    }
}

@end

typedef struct {
    NSCondition *cond;
    pthread_t thread;
    NSInteger condition;
    NSString *name;
} NSConditionLockIndexedIvars;

@implementation NSConditionLock (Extension)

- (NSCondition *)cond {
    NSConditionLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
    return indexedIvars->cond;
}

- (pthread_t)thread {
    NSConditionLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
    return indexedIvars->thread;
}

@end

typedef struct {
    pthread_mutex_t mutex;
    pthread_t pthread;
    NSInteger recursionCount;
    struct {
        pthread_mutex_t mutex;
        pthread_cond_t cond;
    } *cond;
    NSString *name;
} NSRecursiveLockIndexedIvars;

@implementation NSRecursiveLock (Extension)

- (pthread_mutex_t *)mutex {
    NSRecursiveLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
    return &indexedIvars->mutex;
}

- (pthread_t)thread {
    NSRecursiveLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
    return indexedIvars->pthread;
}

- (NSInteger)recursionCount {
    NSRecursiveLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
    return indexedIvars->recursionCount;
}

- (pthread_mutex_t *)cond_mutex {
    NSRecursiveLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
    return &indexedIvars->cond->mutex;
}

- (pthread_cond_t *)cond_cond {
    NSRecursiveLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
    return &indexedIvars->cond->cond;
}

@end

typedef struct {
    pthread_mutex_t mutex;
    pthread_t thread;
    pthread_cond_t cond;
    NSString *name;
} NSConditionIndexedIvars;

typedef struct {
    pthread_mutex_t mutex;
    pthread_cond_t cond;
    NSString *name;
} NSConditionIndexedIvars2;

@implementation NSCondition (Extension)

- (pthread_mutex_t *)mutex {
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
        NSConditionIndexedIvars2 *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->mutex;
    } else {
        NSConditionIndexedIvars *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->mutex;
    }
}

- (pthread_t)thread {
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
        return NULL;
    } else {
        NSConditionIndexedIvars *indexedIvars = object_getIndexedIvars(self);
        return indexedIvars->thread;
    }
}

- (pthread_cond_t *)cond {
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
        NSConditionIndexedIvars2 *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->cond;
    } else {
        NSConditionIndexedIvars *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->cond;
    }
}

@end
