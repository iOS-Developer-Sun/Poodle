//
//  pdl_thread_define.h
//  Poodle
//
//  Created by Poodle on 2020/5/12.
//  Copyright © 2020 Poodle. All rights reserved.
//

#define  pdl_thread_fake        _____PDL_THREAD_FAKE_BEGIN_____
#define _pdl_thread_fake       ______PDL_THREAD_FAKE_BEGIN_____
#define  pdl_thread_fake_end    _____PDL_THREAD_FAKE_END_____
#define _pdl_thread_fake_end   ______PDL_THREAD_FAKE_END_____

#if defined(__i386__)
#define pdl_thread_fake_size 24
#elif defined(__x86_64__)
#define pdl_thread_fake_size 11
#elif defined(__arm__)
#define pdl_thread_fake_size 28
#elif defined(__arm64__)
#define pdl_thread_fake_size 48
#endif

#ifdef DEBUG

#if defined(__i386__)
#define pdl_thread_fake_end_size 0x330
#elif defined(__x86_64__)
#define pdl_thread_fake_end_size 0x3a8
#elif defined(__arm__)
#define pdl_thread_fake_end_size 0x38c
#elif defined(__arm64e__)
#define pdl_thread_fake_end_size 0x3c4
#elif defined(__arm64__)
#define pdl_thread_fake_end_size 0x3c0
#endif

#else

#if defined(__i386__)
#define pdl_thread_fake_end_size 0x170
#elif defined(__x86_64__)
#define pdl_thread_fake_end_size 0x16e
#elif defined(__arm__)
#define pdl_thread_fake_end_size 0x154
#elif defined(__arm64e__)
#define pdl_thread_fake_end_size 0x188
#elif defined(__arm64__)
#define pdl_thread_fake_end_size 0x184
#endif

#endif
