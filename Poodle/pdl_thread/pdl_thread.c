//
//  pdl_thread.c
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "pdl_thread.h"

__attribute__((noinline))
static void *pdl_thread_process_pointer(void) {
    __volatile void *pc = __builtin_return_address(0);
    return (void *)pc;
}

static void *pdl_thread_fake_end(void **frames, int frames_count, void *(*start)(void *), void *arg, int hides) {
#ifdef __i386__
    int alignment = 4;
    __attribute__((aligned(4)))
    void *aligned_frames[frames_count * alignment + 2];
    void **stack_frames = aligned_frames + 2;
#else
    int alignment = 2;
    void *aligned_frames[frames_count * alignment];
    void **stack_frames = aligned_frames;
#endif
    void *lr = pdl_thread_process_pointer();
    void *fp = __builtin_frame_address(0);
    int current_count = pdl_thread_frames(lr, fp, NULL, __INT_MAX__);
    if (current_count < hides) {
        lr = NULL;
    }

    for (int i = 0; i < frames_count; i++) {
        int fp_index = i * alignment;
        int lr_index = i * alignment + 1;
        if (i != frames_count - 1) {
            stack_frames[fp_index] = &stack_frames[fp_index + alignment];
            stack_frames[lr_index] = frames[i];
        } else {
            stack_frames[fp_index] = fp;
            stack_frames[lr_index] = lr;
        }
    }

    extern void *pdl_thread_fake(void **frames, void *(*start)(void *), void *arg);
    void *ret = pdl_thread_fake(stack_frames, start, arg);
    return ret;
}

void *pdl_thread_execute(void **frames, int frames_count, void *(*start)(void *), void *arg, int hides) {
    void *ret = pdl_thread_fake_end(frames, frames_count, start, arg, hides);
    __asm__ volatile ("nop");
    return ret;
}

int pdl_thread_frames(void *link_register, void *frame_pointer, void **frames, int count) {
    int ret = 0;
    void *lr = (void *)link_register;
    void **fp = (void **)frame_pointer;
    while (true) {
        if (ret > count) {
            break;
        }
        if (frames) {
            frames[ret] = lr;
        }
        ret++;
        if (!fp) {
            break;
        }
        if (!lr) {
            break;
        }
        fp = *fp;

        if (fp) {
            lr = *(fp + 1);
        } else {
            lr = NULL;
        }
    }
    return ret;
}
