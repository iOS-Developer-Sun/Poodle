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

enum {
    DISPATCH_QUEUE_OVERCOMMIT = 0x2ull,
};

#define QOS_CLASS_MAINTENANCE 0x05

static void *pdl_dispatch_queue_key = NULL;

@interface pdl_dispatch_queue : NSObject

@property (unsafe_unretained, readonly) dispatch_queue_t queue;
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
    init = true;

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
}

static void pdl_dispatch_init_queue(dispatch_queue_t queue) {
    pdl_dispatch_init();

    if (!queue) {
        return;
    }

    pdl_dispatch_register_queue(queue, false);
}

dispatch_queue_t pdl_dispatch_queue_create(const char *label, dispatch_queue_attr_t attr, dispatch_queue_t (*dispatch_queue_create_original)(const char *label, dispatch_queue_attr_t attr)) {
    dispatch_queue_t queue = dispatch_queue_create_original(label, attr);
    pdl_dispatch_init_queue(queue);
    return queue;
}

dispatch_queue_t pdl_dispatch_queue_create_with_target(const char *label, dispatch_queue_attr_t attr, dispatch_queue_t target, dispatch_queue_t (*dispatch_queue_create_with_target_original)(const char *label, dispatch_queue_attr_t attr, dispatch_queue_t target)) {
    dispatch_queue_t queue = dispatch_queue_create_with_target_original(label, attr, target);
    pdl_dispatch_init_queue(queue);
    return queue;
}

dispatch_queue_t pdl_dispatch_get_current_queue(void) {
    pdl_dispatch_queue *q = (__bridge pdl_dispatch_queue *)(dispatch_get_specific(&pdl_dispatch_queue_key));
    return q.queue;
}

unsigned long pdl_dispatch_get_queue_width(dispatch_queue_t queue) {
    pdl_dispatch_queue *q = (__bridge pdl_dispatch_queue *)dispatch_queue_get_specific(queue, &pdl_dispatch_queue_key);
    return q.width;
}

unsigned long pdl_dispatch_get_queue_unique_identifier(dispatch_queue_t queue) {
    pdl_dispatch_queue *q = (__bridge pdl_dispatch_queue *)dispatch_queue_get_specific(queue, &pdl_dispatch_queue_key);
    return q.uniqueIdentifier;
}

@end
