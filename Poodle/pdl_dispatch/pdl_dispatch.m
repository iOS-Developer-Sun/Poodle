//
//  pdl_dispatch.m
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "pdl_dispatch.h"
#import <Foundation/Foundation.h>
#import <malloc/malloc.h>
#import <pthread.h>
#import "pdl_hook.h"
#import <mach-o/ldsyms.h>
#import <dlfcn.h>

enum {
    DISPATCH_QUEUE_OVERCOMMIT = 0x2ull,
};

#define QOS_CLASS_MAINTENANCE 0x05

static void *pdl_dispatch_queue_key = NULL;

@interface pdl_dispatch_queue : NSObject

@property (weak, readonly) dispatch_queue_t queue;
@property (readonly) unsigned long width;
@property (readonly) unsigned long uniqueIdentifier;

@end

@implementation pdl_dispatch_queue

@synthesize queue = _queue;
@synthesize width = _width;
@synthesize uniqueIdentifier = _uniqueIdentifier;

static unsigned long pdl_system_unique_identifier(void) {
    @synchronized ([pdl_dispatch_queue class]) {
        static unsigned long identifier = 0;
        return ++identifier;
    }
}

static unsigned long pdl_unique_identifier(void) {
    @synchronized ([pdl_dispatch_queue class]) {
        static unsigned long identifier = 100;
        return ++identifier;
    }
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue system:(bool)system {
    self = [super init];
    if (self) {
        _queue = queue;

        if (system) {
            assert(malloc_size((__bridge const void *)_queue) == 0);
            _uniqueIdentifier = pdl_system_unique_identifier();
        } else {
            _uniqueIdentifier = pdl_unique_identifier();
        }
    }
    return self;
}

- (unsigned long)width {
    if (_width == 0) {
        NSString *debugDescription = [self.queue debugDescription];
        unsigned int result = 0;

        NSUInteger operationQueueLocation = [debugDescription rangeOfString:@"NSOperationQueue"].location;
        if (operationQueueLocation != NSNotFound) {
            unsigned long long op = 0;
            NSString *operationQueueString = [debugDescription substringFromIndex:operationQueueLocation];
            operationQueueString = [operationQueueString substringToIndex:[operationQueueString rangeOfString:@" ("].location];
            operationQueueString = [operationQueueString substringFromIndex:[operationQueueString rangeOfString:@"NSOperationQueue"].location + [operationQueueString rangeOfString:@"NSOperationQueue"].length];
            NSScanner *scanner = [NSScanner scannerWithString:operationQueueString];
            [scanner scanHexLongLong:&op];
            void *ptr = (void *)(unsigned long)op;
            assert(malloc_size(ptr));
            NSOperationQueue *operationQueue = (__bridge id)ptr;
            result = (unsigned int)operationQueue.maxConcurrentOperationCount;
        } else {
            NSString *widthString = [debugDescription substringFromIndex:[debugDescription rangeOfString:@"width"].location];
            widthString = [widthString substringToIndex:[widthString rangeOfString:@","].location];
            widthString = [widthString substringFromIndex:[widthString rangeOfString:@"width = "].location + [widthString rangeOfString:@"width = "].length];
            NSScanner *scanner = [NSScanner scannerWithString:widthString];
            [scanner scanHexInt:&result];
        }
        assert(result);
        _width = result;
    }
    return _width;
}

static void pdl_dispatch_queue_dealloc(void *value) {
    pdl_dispatch_queue *q = (__bridge_transfer pdl_dispatch_queue *)(value);
    (void)q;
}

static void pdl_dispatch_register_queue(dispatch_queue_t queue, bool system) {
    assert(queue);
    assert(dispatch_queue_get_specific(queue, &pdl_dispatch_queue_key) == NULL);
    pdl_dispatch_queue *q = [[pdl_dispatch_queue alloc] initWithQueue:queue system:system];
    dispatch_queue_set_specific(queue, &pdl_dispatch_queue_key, (__bridge_retained void *)q, pdl_dispatch_queue_dealloc);
}

static void pdl_dispatch_init(void) {
    static bool init = false;
    if (init) {
        return;
    }

    static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_lock(&mutex);
    if (!init) {
        pdl_dispatch_register_queue(dispatch_get_main_queue(), true);

        unsigned int qos[] = {
            QOS_CLASS_USER_INTERACTIVE,
            QOS_CLASS_USER_INITIATED,
            QOS_CLASS_DEFAULT,
            QOS_CLASS_UTILITY,
            QOS_CLASS_BACKGROUND,
            QOS_CLASS_MAINTENANCE,
        };
        for (unsigned int i = 0; i < sizeof(qos) / sizeof(qos[0]); i++) {
            long identifier = qos[i];
            pdl_dispatch_register_queue(dispatch_get_global_queue(identifier, 0), true);
            pdl_dispatch_register_queue(dispatch_get_global_queue(identifier, 2), true);
        }
        init = true;
    }
    pthread_mutex_unlock(&mutex);
}

static void pdl_dispatch_init_queue(dispatch_queue_t queue) {
    pdl_dispatch_init();

    if (!queue) {
        return;
    }

    pdl_dispatch_register_queue(queue, false);
}

static bool pdl_dispatch_queue_enabled = false;

DISPATCH_RETURNS_RETAINED dispatch_queue_t pdl_dispatch_queue_create(const char *label, dispatch_queue_attr_t attr, DISPATCH_RETURNS_RETAINED dispatch_queue_t (*dispatch_queue_create_original)(const char *label, dispatch_queue_attr_t attr)) {
    dispatch_queue_t queue = dispatch_queue_create_original(label, attr);
    pdl_dispatch_queue_enabled = true;
    pdl_dispatch_init_queue(queue);
    return queue;
}

DISPATCH_RETURNS_RETAINED dispatch_queue_t pdl_dispatch_queue_create_with_target(const char *label, dispatch_queue_attr_t attr, dispatch_queue_t target, DISPATCH_RETURNS_RETAINED dispatch_queue_t (*dispatch_queue_create_with_target_original)(const char *label, dispatch_queue_attr_t attr, dispatch_queue_t target)) {
    dispatch_queue_t queue = dispatch_queue_create_with_target_original(label, attr, target);
    pdl_dispatch_queue_enabled = true;
    pdl_dispatch_init_queue(queue);
    return queue;
}

dispatch_queue_t pdl_dispatch_get_current_queue(void) {
    pdl_dispatch_queue *q = (__bridge pdl_dispatch_queue *)(dispatch_get_specific(&pdl_dispatch_queue_key));
    return q.queue;
}

unsigned long pdl_dispatch_get_queue_width(dispatch_queue_t queue) {
    if (!queue) {
        return  0;
    }

    pdl_dispatch_queue *q = (__bridge pdl_dispatch_queue *)dispatch_queue_get_specific(queue, &pdl_dispatch_queue_key);
    return q.width;
}

unsigned long pdl_dispatch_get_queue_unique_identifier(dispatch_queue_t queue) {
    if (!queue) {
        return 0;
    }

    pdl_dispatch_queue *q = (__bridge pdl_dispatch_queue *)dispatch_queue_get_specific(queue, &pdl_dispatch_queue_key);
    return q.uniqueIdentifier;
}

static DISPATCH_RETURNS_RETAINED dispatch_queue_t (*pdl_hook_dispatch_queue_create_original)(const char *_Nullable label, dispatch_queue_attr_t _Nullable attr) = NULL;
static DISPATCH_RETURNS_RETAINED dispatch_queue_t pdl_hook_dispatch_queue_create(const char *_Nullable label, dispatch_queue_attr_t _Nullable attr) {
    dispatch_queue_t queue = pdl_hook_dispatch_queue_create_original(label, attr);
    pdl_dispatch_init_queue(queue);
    return queue;
}

static DISPATCH_RETURNS_RETAINED dispatch_queue_t (*pdl_hook_dispatch_queue_create_with_target_original)(const char *_Nullable label, dispatch_queue_attr_t _Nullable attr, dispatch_queue_t _Nullable target) = NULL;
static DISPATCH_RETURNS_RETAINED dispatch_queue_t pdl_hook_dispatch_queue_create_with_target(const char *_Nullable label, dispatch_queue_attr_t _Nullable attr, dispatch_queue_t _Nullable target) {
    dispatch_queue_t queue = pdl_hook_dispatch_queue_create_with_target_original(label, attr, target);
    pdl_dispatch_init_queue(queue);
    return queue;
}

// (extension in Dispatch):__C.OS_dispatch_queue.init(label: Swift.String, qos: Dispatch.DispatchQoS, attributes: (extension in Dispatch):__C.OS_dispatch_queue.Attributes, autoreleaseFrequency: (extension in Dispatch):__C.OS_dispatch_queue.AutoreleaseFrequency, target: __C.OS_dispatch_queue?) -> __C.OS_dispatch_queue
//extern void *$sSo17OS_dispatch_queueC8DispatchE5label3qos10attributes20autoreleaseFrequency6targetABSS_AC0D3QoSVAbCE10AttributesVAbCE011AutoreleaseI0OABSgtcfC(void *, void *, void *, void *, void *);
static void *(*pdl_hook_OS_dispatch_queue_original)(void *, void *, void *, void *, void *) = NULL;
static void *pdl_hook_OS_dispatch_queue(void *a, void *b, void *c, void *d, void *e) {
    void *queue = pdl_hook_OS_dispatch_queue_original(a, b, c, d, e);
    pdl_dispatch_init_queue((__bridge dispatch_queue_t)(queue));
    return queue;
}

int pdl_dispatch_queue_enable(void) {
    if (pdl_dispatch_queue_enabled) {
        return 0;
    }

    void *handle = dlopen(NULL, RTLD_GLOBAL | RTLD_NOW);
    pdl_hook_OS_dispatch_queue_original = dlsym(handle, "$sSo17OS_dispatch_queueC8DispatchE5label3qos10attributes20autoreleaseFrequency6targetABSS_AC0D3QoSVAbCE10AttributesVAbCE011AutoreleaseI0OABSgtcfC");
    dlclose(handle);

    int count = 0;
    pdl_hook_item items[3];
    items[count++] = (pdl_hook_item) {
        "dispatch_queue_create",
        &dispatch_queue_create,
        &pdl_hook_dispatch_queue_create,
        (void **)&pdl_hook_dispatch_queue_create_original,
    };
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 10) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        items[count++] = (pdl_hook_item) {
            "dispatch_queue_create_with_target",
            &dispatch_queue_create_with_target,
            &pdl_hook_dispatch_queue_create_with_target,
            (void **)&pdl_hook_dispatch_queue_create_with_target_original,
        };
#pragma clang diagnostic pop
    }

    items[count++] = (pdl_hook_item) {
        "$sSo17OS_dispatch_queueC8DispatchE5label3qos10attributes20autoreleaseFrequency6targetABSS_AC0D3QoSVAbCE10AttributesVAbCE011AutoreleaseI0OABSgtcfC",
        NULL, // &$sSo17OS_dispatch_queueC8DispatchE5label3qos10attributes20autoreleaseFrequency6targetABSS_AC0D3QoSVAbCE10AttributesVAbCE011AutoreleaseI0OABSgtcfC,
        &pdl_hook_OS_dispatch_queue,
        NULL, //(void **)&pdl_hook_OS_dispatch_queue_original,
    };

    int ret = pdl_hook(items, count);
    pdl_dispatch_init();
    pdl_dispatch_queue_enabled = true;
    return ret;
}

@end
