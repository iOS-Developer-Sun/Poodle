//
//  pdl_thread.c
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#include "pdl_thread.h"
#include "pdl_thread_define.h"

extern void *pdl_thread_fake(void **frames, void *(*start)(void *), void *arg);

static void *pdl_thread_fake_end(void **frames, int frames_count, void *(*start)(void *), void *arg, int hidden_count) {
    int hc = hidden_count;
    int total_frames_count = frames_count;
    if (frames_count == 0) {
        total_frames_count++;
    }
    bool hides_without_self = hc > 0;
    if (hides_without_self) {
        total_frames_count++;
    } else {
        hc = -hc;
    }

#ifdef __i386__
    int alignment = 4;
    __attribute__((aligned(4)))
    void *aligned_frames[total_frames_count * alignment + 2];
    void **stack_frames = aligned_frames + 2;
#else
    int alignment = 2;
    void *aligned_frames[total_frames_count * alignment];
    void **stack_frames = aligned_frames;
#endif

    void (*self_lr)(void) = pdl_builtin_return_address(0);
    void *self_fp = pdl_builtin_frame_address(0);
    void (*lr)(void) = self_lr;
    void *fp = self_fp;
    int current_count = pdl_thread_frames(lr, fp, NULL, __INT_MAX__) - 1;
    if (current_count < hc) {
        lr = NULL;
    } else {
        int from = hc;
        if (hides_without_self) {
            from++;
        }
        fp = pdl_builtin_frame_address(from);
        lr = pdl_builtin_return_address(from);
    }

    if (frames_count > 0) {
        for (int i = 0; i < frames_count; i++) {
            int fp_index = i * alignment;
            int lr_index = i * alignment + 1;
            if (i != frames_count - 1) {
                stack_frames[fp_index] = &stack_frames[fp_index + alignment];
                stack_frames[lr_index] = frames[i];
            } else {
                if (hides_without_self) {
                    stack_frames[fp_index] = &stack_frames[fp_index + alignment];
                    stack_frames[lr_index] = self_lr;
                    stack_frames[fp_index + alignment] = fp;
                    stack_frames[lr_index + alignment] = lr;
                } else {
                    stack_frames[fp_index] = fp;
                    stack_frames[lr_index] = lr;
                }
            }
        }
    } else {
        int fp_index = 0;
        int lr_index = 1;
        if (hides_without_self) {
            stack_frames[fp_index] = &stack_frames[fp_index + alignment];
            stack_frames[lr_index] = self_lr;
            stack_frames[fp_index + alignment] = fp;
            stack_frames[lr_index + alignment] = lr;
        } else {
            stack_frames[fp_index] = fp;
            stack_frames[lr_index] = lr;
        }
    }

    void *ret = pdl_thread_fake(stack_frames, start, arg);
    return ret;
}

void *pdl_thread_execute(void **frames, int frames_count, void *(*start)(void *), void *arg, int hidden_count) {
    void *ret = pdl_thread_fake_end(frames, frames_count, start, arg, hidden_count);
    return ret;
}

int pdl_thread_frames(void *link_register, void *frame_pointer, void **frames, int count) {
    return pdl_thread_frames_with_filter(link_register, frame_pointer, frames, count, NULL);
}

int pdl_thread_frames_with_filter(void *link_register, void *frame_pointer, void **frames, int count, pdl_thread_frame_filter *filter) {
    int ret = 0;
    void *lr = (void *)link_register;
    void **fp = (void **)frame_pointer;
    if (filter && filter->init) {
        filter->init(filter);
    }
    while (true) {
        if (ret > count) {
            break;
        }

        bool available = true;
        if (filter && filter->is_valid) {
            available = filter->is_valid(filter, lr);
        }

        if (available) {
            if (frames) {
                frames[ret] = lr;
            }
            ret++;
        }

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

bool pdl_thread_fake_begin_filter(void *link_register) {
    bool available = (link_register < (void *)&pdl_thread_fake) || (link_register > (void *)&pdl_thread_fake + pdl_thread_fake_size);
    return available;
}

bool pdl_thread_fake_end_filter(void *link_register) {
    bool available = (link_register < (void *)&pdl_thread_fake_end) || (link_register > (void *)&pdl_thread_fake_end + pdl_thread_fake_end_size);
    return available;
}

__attribute__((noinline))
void *pdl_builtin_frame_address(int frame) {
    void *fp = __builtin_frame_address(1);
    int count = frame;
    while (count > 0) {
        fp = *(void **)fp;
        count--;
        if (fp == NULL) {
            break;
        }
    }
    return fp;
}

__attribute__((noinline))
void *pdl_builtin_return_address(int frame) {
    void *lr = NULL;
    if (frame == 0) {
        lr = __builtin_return_address(0);
    } else {
        void **fp = pdl_builtin_frame_address(frame);
        if (fp) {
            lr = fp[1];
        }
    }
    return lr;
}
