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
#import "PDLBacktrace.h"
#import "PDLSystemImage.h"
#import "pdl_pac.h"

@interface PDLBlockTracker : NSObject

@property (nonatomic, weak) id object;
@property (nonatomic, weak) id block;
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
    self.callback((__bridge void *)(self->_block), (__bridge void *)(self->_object));
    return NULL;
}

- (void)dealloc {
    if (!_block) {
        return;
    }

    if (!_object) {
        return;
    }

    [self.backtrace execute:&start arg:(__bridge void *)self hidden_count:0];
}

@end

@interface PDLBlockThreadData : NSObject

@property (nonatomic, strong) NSMutableArray *blocks;
@property (nonatomic, strong) NSMapTable *trackers;
@property (nonatomic, strong) NSMapTable *ignoredObjects;
@property (nonatomic, strong) NSMutableArray *ignoredBlocks;
@property (nonatomic, assign) NSInteger ignoreCount;
@property (nonatomic, strong) id active;

@end

@implementation PDLBlockThreadData

- (instancetype)init {
    self = [super init];
    if (self) {
        _blocks = [NSMutableArray array];
        _trackers = [NSMapTable strongToStrongObjectsMapTable];
        _ignoredObjects = [NSMapTable weakToStrongObjectsMapTable];
        _ignoredBlocks = [NSMutableArray array];
        _active = self;
    }
    return self;
}

- (void)addTracker:(PDLBlockTracker *)tracker {
    NSMapTable *map = self.trackers;
    void *block = [self last];
    NSUInteger blockValue = (NSUInteger)block;
    id key = @(blockValue);
    NSMutableSet *set = [map objectForKey:key];
    if (!set) {
        set = [NSMutableSet set];
        [map setObject:set forKey:key];
    }
    [set addObject:tracker];
}

- (void)removeTrackers:(void *)block {
    NSMapTable *map = self.trackers;
    NSUInteger blockValue = (NSUInteger)block;
    id key = @(blockValue);
    [map removeObjectForKey:key];
}

- (void)push:(void *)block {
    NSMutableArray *blocks = self.blocks;
    uintptr_t value = (uintptr_t)block;
    [blocks addObject:@(value)];
}

- (void *)pop {
    NSMutableArray *blocks = self.blocks;
    assert(blocks.count > 0);
    NSNumber *value = blocks.lastObject;
    [blocks removeLastObject];
    void *block = (void *)value.unsignedLongValue;
    [self removeTrackers:block];
    return block;
}

- (void *)last {
    NSMutableArray *blocks = self.blocks;
    NSNumber *value = blocks.lastObject;
    void *block = (void *)value.unsignedLongValue;
    return block;
}

- (void)invalidate {
    _active = nil;
}

- (BOOL)ignoredBlock:(__unsafe_unretained id)object {
    NSUInteger key = (NSUInteger)object;
    return [self.ignoredBlocks containsObject:@(key)];
}

- (void)ignoreBlockBegin:(__unsafe_unretained id)object {
    NSUInteger key = (NSUInteger)object;
    [self.ignoredBlocks addObject:@(key)];
}

- (void)ignoreBlockEnd:(__unsafe_unretained id)object {
    NSUInteger key = (NSUInteger)object;
    NSInteger index = NSNotFound;
    for (NSInteger i = self.ignoredBlocks.count - 1; i >= 0; i--) {
        NSNumber *value = self.ignoredBlocks[i];
        if (value.unsignedLongValue == key) {
            index = i;
            break;
        }
    }
    assert(index != NSNotFound);
    [self.ignoredBlocks removeObjectAtIndex:index];
}

- (BOOL)ignored:(__unsafe_unretained id)object {
    PDLBlockCheckIgnoreAllBegin();
    NSNumber *value = [self.ignoredObjects objectForKey:object];
    PDLBlockCheckIgnoreAllEnd();
    return value.integerValue > 0;
}

- (void)ignoreBegin:(__unsafe_unretained id)object {
    PDLBlockCheckIgnoreAllBegin();
    NSNumber *value = [self.ignoredObjects objectForKey:object];
    value = @(value.integerValue + 1);
    [self.ignoredObjects setObject:value forKey:object];
    PDLBlockCheckIgnoreAllEnd();
}

- (void)ignoreEnd:(__unsafe_unretained id)object {
    PDLBlockCheckIgnoreAllBegin();
    NSNumber *value = [self.ignoredObjects objectForKey:object];
    value = @(value.integerValue - 1);
    if (value.integerValue == 0) {
        value = nil;
    }
    if (value) {
        [self.ignoredObjects setObject:value forKey:object];
    } else {
        [self.ignoredObjects removeObjectForKey:object];
    }
    PDLBlockCheckIgnoreAllEnd();
}

@end

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
        void *block = [threadData last];
        BOOL valid = PDLBlockCheckBlockFilter(block);
        if (!valid) {
            break;
        }

        void(^callback)(void *, void *) = (__bridge void (^)(void *, void *))(_data);
        PDLBlockTracker *tracker = [PDLBlockTracker tracker];
        tracker.callback = callback;
        tracker.block = (__bridge id)(block);
        tracker.object = self;
        PDLBacktrace *backtrace = [[PDLBacktrace alloc] init];
        [backtrace record];
        tracker.backtrace = backtrace;

        [threadData addTracker:tracker];
    } while (NO);

    return object;
}

static NSMutableDictionary *PDLBlockCopyMap = nil;
static __weak id PDLBlockCopyMapLock = nil;
static void PDLBlockDescCopy(pdl_block *toBlock, pdl_block *fromBlock) {
    unsigned long key = (unsigned long)(fromBlock->Desc.object);
    unsigned long value = 0;
    @synchronized (PDLBlockCopyMapLock) {
        value = [PDLBlockCopyMap[@(key)] unsignedLongValue];
    }
    assert(value);

    void *block = toBlock;
    PDLBlockThreadData *threadData = PDLBlockCurretThreadData();
    BOOL valid = ![threadData ignoredBlock:(__bridge id)(fromBlock)];
    if (valid) {
        [threadData push:block];
    }

    typeof(&PDLBlockDescCopy) copy = (typeof(&PDLBlockDescCopy))value;
    copy(toBlock, fromBlock);

    if (valid) {
        void *popped = [threadData pop];
        assert(block == popped);
    }
}

NSUInteger PDLBlockCheckEnable(BOOL(*descriptorFilter)(NSString *symbol)) {
    __block NSUInteger ret = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pdl_thread_storage_register(PDLBlockThreadDataKey, &PDLBlockDestroy);
        if (pdl_thread_storage_enabled()) {
            NSMutableDictionary *map = [NSMutableDictionary dictionary];
            PDLBlockCopyMap = map;
            PDLBlockCopyMapLock = map;
            [[PDLSystemImage executeSystemImage] enumerateSymbolPointers:^(PDLSystemImage *systemImage, pdl_nlist *nlist, const char *symbol, void **address) {
                if (!nlist->n_sect) {
                    return;
                }

                unsigned long key = (unsigned long)address;
                if (map[@(key)] != nil) {
                    return;
                }

                NSString *symbolString = @(symbol);
                if (![symbolString hasPrefix:@"___block_descriptor"]) {
                    return;
                }

                pdl_block_desc_object *desc = (void *)address;
                void *copy = desc->copy;
                if (pdl_ptrauth_strip(copy) != copy) {
                    copy = pdl_ptrauth_auth_function(desc->copy, &desc->copy);
                }

                if (!copy) {
                    return;
                }

                if (descriptorFilter) {
                    if (!descriptorFilter(symbolString)) {
                        return;
                    }
                }

                unsigned long value = (unsigned long)pdl_ptrauth_sign_unauthenticated(copy, NULL);
                @synchronized (PDLBlockCopyMapLock) {
                    map[@(key)] = @(value);
                }
                desc->copy = pdl_ptrauth_sign_unauthenticated(pdl_ptrauth_strip(&PDLBlockDescCopy), &desc->copy);
            }];
            ret = PDLBlockCopyMap.count;
            PDLBlockCopyMapLock = nil;
        }
    });

    return ret;
}

BOOL PDLBlockCheck(Class aClass, void (^callback)(void *block, void *object)) {
    BOOL ret = [aClass pdl_interceptSelector:sel_registerName("retain") withInterceptorImplementation:(IMP)&PDLBlockRetainObject isStructRet:@(NO) addIfNotExistent:YES data:(__bridge_retained void *)callback];
    return ret;
}

#pragma mark - ignore

void PDLBlockCheckIgnoreBegin(__unsafe_unretained id object) {
    PDLBlockThreadData *threadData = PDLBlockCurretThreadData();
    if ([object isKindOfClass:objc_getClass("NSBlock")]) {
        [threadData ignoreBlockBegin:object];
    } else {
        [threadData ignoreBegin:object];
    }
}

void PDLBlockCheckIgnoreEnd(__unsafe_unretained id object) {
    PDLBlockThreadData *threadData = PDLBlockCurretThreadData();
    if ([object isKindOfClass:objc_getClass("NSBlock")]) {
        [threadData ignoreBlockEnd:object];
    } else {
        [threadData ignoreEnd:object];
    }
}

void PDLBlockCheckIgnoreAllBegin(void) {
    PDLBlockThreadData *threadData = PDLBlockCurretThreadData();
    threadData.ignoreCount++;
}

void PDLBlockCheckIgnoreAllEnd(void) {
    PDLBlockThreadData *threadData = PDLBlockCurretThreadData();
    threadData.ignoreCount--;
}
