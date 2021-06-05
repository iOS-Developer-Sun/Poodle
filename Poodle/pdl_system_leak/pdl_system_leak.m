//
//  pdl_system_leak.m
//  Poodle
//
//  Created by Poodle on 2021/2/3.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "pdl_system_leak.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <NetworkExtension/NetworkExtension.h>
#import <mach/mach.h>
#import <malloc/malloc.h>
#import <objc/runtime.h>
#import "NSObject+PDLImplementationInterceptor.h"
#import "pdl_thread.h"

static pthread_mutex_t pdl_mutex = PTHREAD_MUTEX_INITIALIZER;
static void *pdl_xpc_dictionary_class = NULL;

static bool pdl_enabled_CNCopyCurrentNetworkInfo = false;
static thread_t pdl_thread_CNCopyCurrentNetworkInfo = 0;
static void *pdl_leak_dictionary_96 = NULL;
static void *pdl_leak_dictionary_240 = NULL;

static BOOL pdl_enabled_NEHotspotNetwork = NO;
static thread_t pdl_thread_NEHotspotNetwork = 0;

BOOL(*pdl_system_leak_releaseAction)(void *ptr) = NULL;

static void pdl_common_init(void) {
    pdl_xpc_dictionary_class = (__bridge void *)(objc_getClass("OS_xpc_dictionary"));
}

static void pdl_system_leak_free_xpc_dictionary(void *ptr) {
    if (!ptr) {
        return;
    }

    if (!malloc_size(ptr)) {
        return;
    }

    void *isa = *((void **)ptr);
    if (isa == pdl_xpc_dictionary_class) {
        BOOL continues = YES;
        if (pdl_system_leak_releaseAction) {
            continues = pdl_system_leak_releaseAction(ptr);
        }
        if (continues) {
            CFRelease(ptr);
        }
    }
}

__attribute__((noinline))
void pdl_system_leak_list_add(void *ptr, size_t size, int class_createInstance_frame_index) {
    if (!pdl_enabled_CNCopyCurrentNetworkInfo && !pdl_enabled_NEHotspotNetwork) {
        return;
    }

    if (!pdl_thread_CNCopyCurrentNetworkInfo && !pdl_thread_NEHotspotNetwork) {
        return;
    }

    if (size != 96 && size != 240) {
        return;
    }

    mach_port_t thread_self = mach_thread_self();
    if ((pdl_thread_CNCopyCurrentNetworkInfo != thread_self) && (pdl_thread_NEHotspotNetwork != thread_self)) {
        return;
    }

    static void *begin = &class_createInstance;
    static void *end = NULL;
    end = begin + 256;

    void *function = pdl_builtin_return_address(class_createInstance_frame_index + 1);
    if (function < begin || function > end) {
        return;
    }

    if (size == 96) {
        if (!pdl_leak_dictionary_96) {
            pdl_leak_dictionary_96 = ptr;
        }
    } else {
        pdl_leak_dictionary_240 = ptr;
    }
}

CFDictionaryRef pdl_CNCopyCurrentNetworkInfo(CFStringRef interfaceName) {
    return pdl_CNCopyCurrentNetworkInfoWithOriginal(interfaceName, &CNCopyCurrentNetworkInfo);
}

CFDictionaryRef pdl_CNCopyCurrentNetworkInfoWithOriginal(CFStringRef interfaceName, CFDictionaryRef(*CNCopyCurrentNetworkInfo_original)(CFStringRef interfaceName)) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 13) {
            pdl_common_init();
            pdl_xpc_dictionary_class = (__bridge void *)(objc_getClass("OS_xpc_dictionary"));
            pdl_enabled_CNCopyCurrentNetworkInfo = YES;
        }
    });

    if (!pdl_enabled_CNCopyCurrentNetworkInfo) {
        return CNCopyCurrentNetworkInfo_original(interfaceName);
    }

    pthread_mutex_lock(&pdl_mutex);

    pdl_thread_CNCopyCurrentNetworkInfo = mach_thread_self();
    CFDictionaryRef ret = CNCopyCurrentNetworkInfo_original(interfaceName);
    pdl_thread_CNCopyCurrentNetworkInfo = 0;

    pdl_system_leak_free_xpc_dictionary(pdl_leak_dictionary_96);
    pdl_leak_dictionary_96 = NULL;

    pdl_system_leak_free_xpc_dictionary(pdl_leak_dictionary_240);
    pdl_leak_dictionary_240 = NULL;

    pthread_mutex_unlock(&pdl_mutex);
    return ret;
}

static void pdl_NEHotspotNetworkFetchCurrentWithCompletionHandler(__unsafe_unretained id self, SEL _cmd, void (^completionHandler)(NEHotspotNetwork * __nullable currentNetwork)) {
    PDLImplementationInterceptorRecover(_cmd);

    pthread_mutex_lock(&pdl_mutex);

    pdl_thread_NEHotspotNetwork = mach_thread_self();
    ((typeof(&pdl_NEHotspotNetworkFetchCurrentWithCompletionHandler))_imp)(self, _cmd, completionHandler);
    pdl_thread_NEHotspotNetwork = 0;

    pdl_system_leak_free_xpc_dictionary(pdl_leak_dictionary_96);
    pdl_leak_dictionary_96 = NULL;

    pthread_mutex_unlock(&pdl_mutex);
}

void pdl_system_leak_setReleaseAction(BOOL(*releaseAction)(void *ptr)) {
    pdl_system_leak_releaseAction = releaseAction;
}

BOOL pdl_system_leak_enable_NEHotspotNetwork(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pdl_common_init();
        pdl_enabled_NEHotspotNetwork = [object_getClass([NEHotspotNetwork class]) pdl_interceptSelector:sel_registerName("fetchCurrentWithCompletionHandler:") withInterceptorImplementation:(IMP)&pdl_NEHotspotNetworkFetchCurrentWithCompletionHandler];
    });
    return pdl_enabled_NEHotspotNetwork;
}
