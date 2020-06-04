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

extern void *pdl_thread_execute(void **frames, int frames_count, void *(*start)(void *), void *arg, int hides);

extern int pdl_thread_frames(void *link_register, void *frame_pointer, void **frames, int count);

#ifdef __cplusplus
}
#endif
