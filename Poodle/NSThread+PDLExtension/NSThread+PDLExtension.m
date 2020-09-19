//
//  NSThread+PDLExtension.m
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSThread+PDLExtension.h"
#import "pdl_pthread.h"
#import "pdl_mach.h"
#import "NSObject+PDLExtension.h"

__unused __attribute__((visibility("hidden"))) void the_table_of_contents_is_empty(void) {}

@implementation NSThread (PDLExtension)

- (pthread_t)pdl_pthread {
    NSObject *data = [self valueForKeyPath:@"private"]; // _NSThreadData
    if (!data) {
        return NULL;
    }
    ptrdiff_t offset = [data.class pdl_ivarOffsetForName:"tid"];
    if (offset < 0) {
        return NULL;
    }

    pthread_t *pointer = (__bridge void *)data + offset;
    return *pointer;
}

- (int)pdl_seqNum {
    return [[self valueForKeyPath:@"private.seqNum"] intValue];
}

#if 0
PDL_MACH_O_SYMBOLS_POINTER_FUNCTION_DECLARATION(oAllThreads_pointer, "Foundation", "__NSThreads.oAllThreads")
+ (NSArray *)pdl_allThreads {
    void **oAllThreads = oAllThreads_pointer();
    if (!oAllThreads) {
        return nil;
    }

    NSDictionary *allThreadsDictionary = (__bridge NSDictionary *)(*oAllThreads); // __NSCFDictionary, NSDictionary methods limited
    NSArray *allThreads = allThreadsDictionary.allValues;
    return [allThreads sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [@(((NSThread *)obj1).pdl_seqNum) compare:@(((NSThread *)obj2).pdl_seqNum)];
    }];
}

+ (NSString *)pdl_allThreadsDescription {
    NSMutableString *allThreadsDescription = [NSMutableString string];
    [allThreadsDescription appendString:@"All Threads:\n"];

    NSArray *machThreads = pdl_mach_threadsArray();
    NSArray *allThreads = [self pdl_allThreads];

    for (NSInteger i = 0; i < machThreads.count; i++) {
        mach_port_t machThreadId = [machThreads[i] unsignedIntValue];
        NSThread *thread = nil;
        pthread_t pthread = pthread_from_mach_thread_np(machThreadId);
        uint64_t pthreadId = pdl_pthread_thread_id(pthread);
        for (NSThread *each in allThreads) {
            pthread_t eachPthread = each.pdl_pthread;
            mach_port_t eachMachThreadId = pthread_mach_thread_np(eachPthread);
            if (eachMachThreadId == machThreadId) {
                thread = each;
                break;
            }
        }
        [allThreadsDescription appendFormat:@"%@:\nmach_thread: %u, pthread: %p, pthread_id: %llu, NSThread: %@\n", @(i), machThreadId, pthread, pthreadId, thread];
    }
    return [allThreadsDescription copy];
}

NSString *pdl_NSThreadsDescription(void) {
    return [NSThread pdl_allThreadsDescription];
}
#endif

@end
