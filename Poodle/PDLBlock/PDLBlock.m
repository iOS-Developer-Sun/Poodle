//
//  PDLBlock.m
//  Poodle
//
//  Created by Poodle on 2021/2/3.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLBlock.h"
#import "pdl_block.h"
#import "NSObject+PDLImplementationInterceptor.h"
#import "pdl_thread_storage.h"
#import "NSObject+PDLDebug.h"
#import "pdl_hook.h"
#import "PDLBacktrace.h"
#import "PDLSystemImage.h"

@interface PDLBlockTracker : NSObject

@property (nonatomic, weak) id object;
@property (nonatomic, weak) id stackBlock;
@property (nonatomic, weak) id mallocBlock;
@property (nonatomic, copy) void(^callback)(void *, void *);
@property (nonatomic, strong) PDLBacktrace *backtrace;

@end

@implementation PDLBlockTracker

+ (instancetype)tracker {
    PDLBlockTracker *tracker = [[[self alloc] init] pdl_autoreleaseRetained];
    return tracker;
}

static void *start(void *arg) {
    PDLBlockTracker *self = (__bridge PDLBlockTracker *)(arg);
    self.callback((__bridge void *)(self.mallocBlock), (__bridge void *)(self.object));
    return NULL;
}

- (void)dealloc {
    if (!self.mallocBlock) {
        return;
    }

    if (!self.object) {
        return;
    }

    [self.backtrace execute:&start arg:(__bridge void *)self hidden_count:0];
}

@end

@interface PDLBlockThreadData : NSObject

@property (nonatomic, strong) NSMutableArray *retainedBlocks;
@property (nonatomic, strong) NSMutableArray *copiedBlocks;
@property (nonatomic, strong) NSMapTable *trackers;
@property (nonatomic, strong) NSMapTable *ignoredObjects;
@property (nonatomic, assign) NSInteger ignoreCount;
@property (nonatomic, strong) id active;

@end

@implementation PDLBlockThreadData

- (instancetype)init {
    self = [super init];
    if (self) {
        _retainedBlocks = [NSMutableArray array];
        _copiedBlocks = [NSMutableArray array];
        _trackers = [NSMapTable strongToStrongObjectsMapTable];
        _ignoredObjects = [NSMapTable weakToStrongObjectsMapTable];
        _active = self;
    }
    return self;
}

- (void)pushCopy:(void *)block {
    NSMutableArray *blocks = self.copiedBlocks;
    uintptr_t value = (uintptr_t)block;
    [blocks addObject:@(value)];
}

- (void *)popCopy {
    NSMutableArray *blocks = self.copiedBlocks;
    assert(blocks.count > 0);
    NSNumber *value = blocks.lastObject;
    [blocks removeLastObject];
    void *block = (void *)value.unsignedLongValue;
    return block;
}

- (void *)lastCopy {
    NSMutableArray *blocks = self.copiedBlocks;
    NSNumber *value = blocks.lastObject;
    void *block = (void *)value.unsignedLongValue;
    return block;
}

- (void)pushRetain:(void *)block {
    NSMutableArray *blocks = self.retainedBlocks;
    uintptr_t value = (uintptr_t)block;
    [blocks addObject:@(value)];
}

- (void *)popRetain {
    NSMutableArray *blocks = self.retainedBlocks;
    assert(blocks.count > 0);
    NSNumber *value = blocks.lastObject;
    [blocks removeLastObject];
    void *block = (void *)value.unsignedLongValue;
    return block;
}

- (void *)lastRetain {
    NSMutableArray *blocks = self.retainedBlocks;
    NSNumber *value = blocks.lastObject;
    void *block = (void *)value.unsignedLongValue;
    return block;
}

- (void)invalidate {
    _active = nil;
}

- (BOOL)ignored:(__unsafe_unretained id)object {
    NSNumber *value = [self.ignoredObjects objectForKey:object];
    return value.integerValue > 0;
}

- (void)ignoreBegin:(__unsafe_unretained id)object {
    NSNumber *value = [self.ignoredObjects objectForKey:object];
    value = @(value.integerValue + 1);
    [self.ignoredObjects setObject:value forKey:object];
}

- (void)ignoreEnd:(__unsafe_unretained id)object {
    NSNumber *value = [self.ignoredObjects objectForKey:object];
    value = @(value.integerValue - 1);
    if (value.integerValue == 0) {
        value = nil;
    }
    [self.ignoredObjects setObject:value forKey:object];
}

@end

static BOOL(*PDLBlockBlockFilter)(void *block) = NULL;
static BOOL(*PDLBlockObjectFilter)(void *block, void *object) = NULL;

static void *PDLBlockThreadDataKey = &PDLBlockThreadDataKey;

static void PDLBlockDestroy(void *arg) {
    PDLBlockThreadData *data = (__bridge id)(arg);
    [data invalidate];
}

static PDLBlockThreadData *PDLBlockCurretThreadData(void) {
    void **value = (void **)pdl_thread_storage_get(PDLBlockThreadDataKey);
    void *data = NULL;
    if (value) {
        data = *value;
    } else {
        PDLBlockThreadData *threadData = [[PDLBlockThreadData alloc] init];
        data = (__bridge void *)(threadData);
        value = &data;
        pdl_thread_storage_set(PDLBlockThreadDataKey, (void **)value);
    }
    PDLBlockThreadData *ret = (__bridge id)(data);
    return ret;
}

static NSSet *PDLBlockTrackers(__unsafe_unretained id block) {
    NSMapTable *map = PDLBlockCurretThreadData().trackers;
    NSUInteger blockValue = (NSUInteger)(__bridge void *)block;
    id key = @(blockValue);
    NSMutableSet *set = [map objectForKey:key];
    return [set copy];
}

static void PDLBlockAddTracker(__unsafe_unretained id block, PDLBlockTracker *tracker) {
    NSMapTable *map = PDLBlockCurretThreadData().trackers;
    NSUInteger blockValue = (NSUInteger)(__bridge void *)block;
    id key = @(blockValue);
    NSMutableSet *set = [map objectForKey:key];
    if (!set) {
        set = [NSMutableSet set];
        [map setObject:set forKey:key];
    }
    [set addObject:tracker];
}

static void PDLBlockRemoveTrackers(__unsafe_unretained id block) {
    NSMapTable *map = PDLBlockCurretThreadData().trackers;
    NSUInteger blockValue = (NSUInteger)(__bridge void *)block;
    id key = @(blockValue);
    [map removeObjectForKey:key];
}

static void *PDLBlockCopy(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    void *block = (__bridge void *)self;
    PDLBlockThreadData *threadData = PDLBlockCurretThreadData();
    BOOL valid = YES;
    if (PDLBlockBlockFilter) {
        valid = PDLBlockBlockFilter(block);
    }
    if (valid) {
        [threadData pushCopy:block];
    }
    void *object = NULL;
    if (_imp) {
        object = ((void *(*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((void *(*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }
    if (valid) {
        void *popped = [threadData popCopy];
        assert(block == popped);
    }
    return object;
}

static void *PDLBlockCopyWithZone(__unsafe_unretained id self, SEL _cmd, struct _NSZone *zone) {
    PDLImplementationInterceptorRecover(_cmd);
    void *block = (__bridge void *)self;
    PDLBlockThreadData *threadData = PDLBlockCurretThreadData();
    BOOL valid = YES;
    if (PDLBlockBlockFilter) {
        valid = PDLBlockBlockFilter(block);
    }
    if (valid) {
        [threadData pushCopy:block];
    }
    void *object = NULL;
    if (_imp) {
        object = ((void *(*)(id, SEL, struct _NSZone *))_imp)(self, _cmd, zone);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((void *(*)(struct objc_super *, SEL, struct _NSZone *))objc_msgSendSuper)(&su, _cmd, zone);
    }
    if (valid) {
        void *popped = [threadData popCopy];
        assert(block == popped);
    }
    return object;
}

void PDLBlockRetainBlockBegin(void *block) {
    BOOL valid = YES;
    if (PDLBlockBlockFilter) {
        valid = PDLBlockBlockFilter(block);
    }
    if (valid) {
        [PDLBlockCurretThreadData() pushRetain:block];
    }
}

void PDLBlockRetainBlockEnd(void *block, void *mallocBlock) {
    BOOL valid = YES;
    if (PDLBlockBlockFilter) {
        valid = PDLBlockBlockFilter(block);
    }
    if (valid) {
        void *popped = [PDLBlockCurretThreadData() popRetain];
        assert(block == popped);
        NSSet *trackers = PDLBlockTrackers((__bridge id)(block));
        for (PDLBlockTracker *tracker in trackers) {
            tracker.mallocBlock = (__bridge id)(mallocBlock);
        }
        PDLBlockRemoveTrackers((__bridge id)block);
    }
}

static void *(*pdl_objc_retainBlock_original)(void *block);
static void *pdl_objc_retainBlock(void *block) {
    if (![(__bridge id)block isKindOfClass:objc_getClass("__NSStackBlock__")]) {
        return pdl_objc_retainBlock_original(block);
    }

    PDLBlockRetainBlockBegin(block);
    void *ret = pdl_objc_retainBlock_original(block);
    PDLBlockRetainBlockEnd(block, ret);
    return ret;
}

static BOOL PDLBlockIgnored(__unsafe_unretained id object) {
    PDLBlockThreadData *threadData = PDLBlockCurretThreadData();
    if (threadData.ignoreCount > 0) {
        return YES;
    }
    if ([threadData ignored:object]) {
        return YES;
    }
    return NO;
}

static BOOL PDLBlockIsSystemBlock(void *frame) {
    PDLSystemImage *systemImage = [PDLSystemImage systemImageWithName:@"libsystem_blocks.dylib"];
    return ((uintptr_t)frame >= systemImage.address && (uintptr_t)frame <= systemImage.endAddress);
}

static BOOL PDLBlockIsCustomBlock(void *frame) {
    PDLSystemImage *systemImage = [PDLSystemImage executeSystemImage];
    return ((uintptr_t)frame >= systemImage.address && (uintptr_t)frame <= systemImage.endAddress);
}

static BOOL PDLBlockCheckBlockFilter(void *block) {
    if (!block) {
        return NO;
    }

    pdl_block *b = block;
    return PDLBlockIsCustomBlock(b->impl.FuncPtr);
}

static void *PDLBlockRetainObject(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    void *object = nil;
    if (_imp) {
        object = ((void *(*)(id, SEL))_imp)(self, _cmd);
    } else {
        struct objc_super su = {self, class_getSuperclass(_class)};
        object = ((void *(*)(struct objc_super *, SEL))objc_msgSendSuper)(&su, _cmd);
    }

    do {
        BOOL ignored = PDLBlockIgnored(self);
        if (ignored) {
            break;
        }

        PDLBlockThreadData *threadData = PDLBlockCurretThreadData();
        BOOL isCallbacked = NO;
        do {
            void *block = [threadData lastCopy];
            BOOL valid = PDLBlockCheckBlockFilter(block);
            if (!valid) {
                break;
            }

            if (PDLBlockObjectFilter && !PDLBlockObjectFilter(block, object)) {
                break;
            }

            void(^callback)(void *, void *) = (__bridge void (^)(void *, void *))(_data);
            if (callback) {
                callback((__bridge void *)self, block);
            }
            isCallbacked = YES;
        } while (NO);
        if (isCallbacked) {
            break;
        }

        do {
            void *block = [threadData lastRetain];
            BOOL valid = PDLBlockCheckBlockFilter(block);
            if (!valid) {
                break;
            }

            if (PDLBlockObjectFilter && !PDLBlockObjectFilter(block, object)) {
                break;
            }

            void(^callback)(void *, void *) = (__bridge void (^)(void *, void *))(_data);
            PDLBlockTracker *tracker = [PDLBlockTracker tracker];
            tracker.callback = callback;
            tracker.stackBlock = (__bridge id)(block);
            tracker.object = self;
            PDLBlockAddTracker((__bridge id)block, tracker);
            PDLBacktrace *backtrace = [[PDLBacktrace alloc] init];
            [backtrace record];
            tracker.backtrace = backtrace;
            isCallbacked = YES;
        } while (NO);
        if (isCallbacked) {
            break;
        }

        {
            int frameCount = 5;
            void *lr = pdl_builtin_return_address(1);
            void *fp = pdl_builtin_frame_address(0);
            void *frames[frameCount];
            pdl_thread_frames(lr, fp, frames, frameCount);
            void *copyFrame = NULL;
            for (int i = 0; i < frameCount; i++) {
                void *frame = frames[i];
                if (!frame) {
                    break;
                }

                if (PDLBlockIsSystemBlock(frame)) {
                    copyFrame = frames[i - 1];
                    break;
                }
            }

            if (!PDLBlockIsCustomBlock(copyFrame)) {
                break;
            }

            if (PDLBlockObjectFilter && !PDLBlockObjectFilter(NULL, object)) {
                break;
            }

            void(^callback)(void *, void *) = (__bridge void (^)(void *, void *))(_data);
            if (callback) {
                callback(NULL, (__bridge void *)self);
            }
        }
    } while (NO);

    return object;
}

BOOL PDLBlockCheckEnable(BOOL(*blockFilter)(void *block), BOOL(*objectFilter)(void *block, void *object)) {
    size_t count = 1;
    pdl_hook_item items[count];
    {
        pdl_hook_item *item = items + 0;
        item->name = "objc_retainBlock";
        extern void *objc_retainBlock(void *);
        item->external = &objc_retainBlock;
        item->custom = &pdl_objc_retainBlock;
        item->original = (void **)&pdl_objc_retainBlock_original;
    }
    int hooked = pdl_hook(items, count);
    assert(hooked == count);

    pdl_thread_storage_register(PDLBlockThreadDataKey, &PDLBlockDestroy);

    if (!pdl_thread_storage_enabled()) {
        return NO;
    }

    PDLBlockBlockFilter = blockFilter;
    PDLBlockObjectFilter = objectFilter;
    Class stackBlockClass = objc_getClass("__NSStackBlock__");
    SEL copySelector = sel_registerName("copy");
    SEL copyWithZoneSelector = sel_registerName("copyWithZone:");
    BOOL ret = [stackBlockClass pdl_interceptSelector:copySelector withInterceptorImplementation:(IMP)&PDLBlockCopy isStructRet:@(NO) addIfNotExistent:YES data:NULL];
    ret = ret && [stackBlockClass pdl_interceptSelector:copyWithZoneSelector withInterceptorImplementation:(IMP)&PDLBlockCopyWithZone isStructRet:@(NO) addIfNotExistent:YES data:NULL];
    return ret;
}

BOOL PDLBlockCheck(Class aClass, void (^callback)(void *block, void *object)) {
    BOOL ret = [aClass pdl_interceptSelector:sel_registerName("retain") withInterceptorImplementation:(IMP)&PDLBlockRetainObject isStructRet:@(NO) addIfNotExistent:YES data:(__bridge_retained void *)callback];
    return ret;
}

void PDLBlockCheckIgnoreBegin(__unsafe_unretained id object) {
    PDLBlockThreadData *threadData = PDLBlockCurretThreadData();
    [threadData ignoreBegin:object];
}

void PDLBlockCheckIgnoreEnd(__unsafe_unretained id object) {
    PDLBlockThreadData *threadData = PDLBlockCurretThreadData();
    [threadData ignoreEnd:object];
}

void PDLBlockCheckIgnoreAllBegin(void) {
    PDLBlockThreadData *threadData = PDLBlockCurretThreadData();
    threadData.ignoreCount++;
}

void PDLBlockCheckIgnoreAllEnd(void) {
    PDLBlockThreadData *threadData = PDLBlockCurretThreadData();
    threadData.ignoreCount--;
}
