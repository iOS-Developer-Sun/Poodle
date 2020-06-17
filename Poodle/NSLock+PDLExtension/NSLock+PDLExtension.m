//
//  NSLock+PDLExtension.m
//  Poodle
//
//  Created by Poodle on 07/04/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSLock+PDLExtension.h"

__unused __attribute__((visibility("hidden"))) void the_table_of_contents_is_empty(void) {}

#if __has_feature(objc_arc)
#error This file must be compiled with flag "-fno-objc-arc"
#endif

struct NSLockIndexedIvars {
    pthread_mutex_t mutex;
    pthread_t thread;
    struct {
        pthread_mutex_t mutex;
        pthread_cond_t cond;
    } *cond;
    NSString *name;
};

struct NSLockIndexedIvars2 {
    pthread_mutex_t mutex;
    struct {
        pthread_mutex_t mutex;
        pthread_cond_t cond;
    } *cond;
    NSString *name;
};

@implementation NSLock (Extension)

- (pthread_mutex_t *)mutex {
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
        struct NSLockIndexedIvars2 *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->mutex;
    } else {
        struct NSLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->mutex;
    }
}

- (pthread_t)thread {
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
        return NULL;
    } else {
        struct NSLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
        return indexedIvars->thread;
    }
}

- (pthread_mutex_t *)cond_mutex {
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
        struct NSLockIndexedIvars2 *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->cond->mutex;
    } else {
        struct NSLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->cond->mutex;
    }
}

- (pthread_cond_t *)cond_cond {
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
        struct NSLockIndexedIvars2 *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->cond->cond;
    } else {
        struct NSLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->cond->cond;
    }
}

@end

struct NSConditionLockIndexedIvars {
    NSCondition *cond;
    pthread_t thread;
    NSInteger condition;
    NSString *name;
};

@implementation NSConditionLock (Extension)

- (NSCondition *)cond {
    struct NSConditionLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
    return indexedIvars->cond;
}

- (pthread_t)thread {
    struct NSConditionLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
    return indexedIvars->thread;
}

@end

struct NSRecursiveLockIndexedIvars {
    pthread_mutex_t mutex;
    pthread_t pthread;
    NSInteger recursionCount;
    struct {
        pthread_mutex_t mutex;
        pthread_cond_t cond;
    } *cond;
    NSString *name;
};

@implementation NSRecursiveLock (Extension)

- (pthread_mutex_t *)mutex {
    struct NSRecursiveLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
    return &indexedIvars->mutex;
}

- (pthread_t)thread {
    struct NSRecursiveLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
    return indexedIvars->pthread;
}

- (NSInteger)recursionCount {
    struct NSRecursiveLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
    return indexedIvars->recursionCount;
}

- (pthread_mutex_t *)cond_mutex {
    struct NSRecursiveLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
    return &indexedIvars->cond->mutex;
}

- (pthread_cond_t *)cond_cond {
    struct NSRecursiveLockIndexedIvars *indexedIvars = object_getIndexedIvars(self);
    return &indexedIvars->cond->cond;
}

@end

struct NSConditionIndexedIvars {
    pthread_mutex_t mutex;
    pthread_t thread;
    pthread_cond_t cond;
    NSString *name;
};

struct NSConditionIndexedIvars2 {
    pthread_mutex_t mutex;
    pthread_cond_t cond;
    NSString *name;
};

@implementation NSCondition (Extension)

- (pthread_mutex_t *)mutex {
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
        struct NSConditionIndexedIvars2 *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->mutex;
    } else {
        struct NSConditionIndexedIvars *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->mutex;
    }
}

- (pthread_t)thread {
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
        return NULL;
    } else {
        struct NSConditionIndexedIvars *indexedIvars = object_getIndexedIvars(self);
        return indexedIvars->thread;
    }
}

- (pthread_cond_t *)cond {
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
        struct NSConditionIndexedIvars2 *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->cond;
    } else {
        struct NSConditionIndexedIvars *indexedIvars = object_getIndexedIvars(self);
        return &indexedIvars->cond;
    }
}

@end
