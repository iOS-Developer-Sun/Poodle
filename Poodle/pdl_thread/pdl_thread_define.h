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
#define pdl_thread_fake_end_size 0x2f4 // 756
#elif defined(__x86_64__)
#define pdl_thread_fake_end_size 0x321 // 801
#elif defined(__arm__)
#define pdl_thread_fake_end_size 0x2ea // 746
#elif defined(__arm64__)
#define pdl_thread_fake_end_size 0x3d4 // 980
#endif

#else

#if defined(__i386__)
#define pdl_thread_fake_end_size 0x169 // 361
#elif defined(__x86_64__)
#define pdl_thread_fake_end_size 0x16e // 366
#elif defined(__arm__)
#define pdl_thread_fake_end_size 0x142 // 322
#elif defined(__arm64__)
#define pdl_thread_fake_end_size 0x198 // 408
#endif

#endif
