//
//  pdl_thread.h
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#include <pthread.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct pdl_thread_frame_filter {
    void *data;
    bool (*is_valid)(void **data_ptr, void *link_register);
} pdl_thread_frame_filter;

extern void *pdl_thread_execute(void **frames, int frames_count, void *(*start)(void *), void *arg, int hidden_count);

extern int pdl_thread_frames(void *link_register, void *frame_pointer, void **frames, int count);

extern int pdl_thread_frames_with_filter(void *link_register, void *frame_pointer, void **frames, int count, pdl_thread_frame_filter *filter);

extern bool pdl_thread_fake_begin_filter(void *link_register);
extern bool pdl_thread_fake_end_filter(void *link_register);

extern void *pdl_builtin_frame_address(int frame);
extern void *pdl_builtin_return_address(int frame);

#ifdef __cplusplus
}
#endif
