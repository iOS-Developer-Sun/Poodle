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
#define pdl_thread_fake_end_size 830 // 0x33e
#elif defined(__x86_64__)
#define pdl_thread_fake_end_size 942 // 0x3ae
#elif defined(__arm__)
#define pdl_thread_fake_end_size 864 // 0x360
#elif defined(__arm64__)
#define pdl_thread_fake_end_size 992 // 0x3e0
#endif

#else

#if defined(__i386__)
#define pdl_thread_fake_end_size 371 // 0x173
#elif defined(__x86_64__)
#define pdl_thread_fake_end_size 404 // 0x194
#elif defined(__arm__)
#define pdl_thread_fake_end_size 366 // 0x16e
#elif defined(__arm64__)
#define pdl_thread_fake_end_size 460 // 0x1cc
#endif

#endif
