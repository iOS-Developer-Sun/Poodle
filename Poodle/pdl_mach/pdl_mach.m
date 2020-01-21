//
//  pdl_mach.m
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "pdl_mach.h"

thread_array_t pdl_mach_threads(mach_msg_type_number_t *count) {
    thread_array_t thread_list = NULL;
    mach_msg_type_number_t thread_count = 0;
    if (task_threads(mach_task_self(), &thread_list, &thread_count) != KERN_SUCCESS) {
        return NULL;
    }
    thread_array_t ret = malloc(thread_count * sizeof(thread_t));
    if (ret) {
        for (mach_msg_type_number_t i = 0; i < thread_count; i++) {
            ret[i] = thread_list[i];
        }
    }

    if (count) {
        *count = thread_count;
    }

    vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));

    return ret;
}

NSArray *pdl_mach_threadsArray(void) {
    mach_msg_type_number_t thread_count = 0;
    thread_array_t threads = pdl_mach_threads(&thread_count);
    if (threads == NULL) {
        return nil;
    }

    NSMutableArray *machThreads = [NSMutableArray array];
    for (mach_msg_type_number_t i = 0; i < thread_count; i++) {
        [machThreads addObject:@(threads[i])];
    }
    free(threads);
    return machThreads.copy;
}
