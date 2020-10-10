//
//  pdl_dynamic_objc_message.m
//  pdl_dynamic_objc_message
//
//  Created by Poodle on 2020/10/10.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "pdl_dynamic_objc_message.h"
#import <dlfcn.h>
#import "pdl_asm.h"
#import "pdl_dynamic.h"
#import "NSObject+PDLPrivate.h"

__attribute__((visibility("hidden")))
void *pdl_dynamic_objc_message_pointer_objc_msgSend = NULL;
__attribute__((visibility("hidden")))
void *pdl_dynamic_objc_message_pointer_objc_msgSendSuper2 = NULL;
__attribute__((visibility("hidden")))
void *pdl_dynamic_objc_message_pointer_objc_msgSend_stret = NULL;
__attribute__((visibility("hidden")))
void *pdl_dynamic_objc_message_pointer_objc_msgSendSuper2_stret = NULL;

extern void _pdl_dynamic_objc_msgSend(void);
extern void _pdl_dynamic_objc_msgSendSuper(void);

PDL_DYLD_INTERPOSE(_pdl_dynamic_objc_msgSend, objc_msgSend);
PDL_DYLD_INTERPOSE(_pdl_dynamic_objc_msgSendSuper, objc_msgSendSuper2);

#ifndef __arm64__

extern void _pdl_dynamic_objc_msgSend_stret(void);
extern void _pdl_dynamic_objc_msgSendSuper_stret(void);

PDL_DYLD_INTERPOSE(_pdl_dynamic_objc_msgSend_stret, objc_msgSend_stret);
PDL_DYLD_INTERPOSE(_pdl_dynamic_objc_msgSendSuper_stret, objc_msgSendSuper2_stret);

#endif


__attribute__((naked))
void pdl_dynamic_objc_msgSend(void) {
    PDL_ASM_GOTO(objc_msgSend);
}

__attribute__((naked))
void pdl_dynamic_objc_msgSendSuper2(void) {
    PDL_ASM_GOTO(objc_msgSendSuper2);
}

#ifndef __arm64__

__attribute__((naked))
void pdl_dynamic_objc_msgSend_stret(void) {
    PDL_ASM_GOTO(objc_msgSend_stret);
}

__attribute__((naked))
void pdl_dynamic_objc_msgSendSuper2_stret(void) {
    PDL_ASM_GOTO(objc_msgSendSuper2_stret);
}

#endif

void pdl_dynamic_objc_msgSend_initialize(BOOL full) {
    void *handle = dlopen(NULL, RTLD_GLOBAL | RTLD_NOW);
    if (!handle) {
        return;
    }

#ifdef __i386__
    full = NO;
#endif

    if (!full) {
        pdl_dynamic_objc_message_pointer_objc_msgSend = dlsym(handle, "pdl_dynamic_bridge_objc_msgSend");
        pdl_dynamic_objc_message_pointer_objc_msgSendSuper2 = dlsym(handle, "pdl_dynamic_bridge_objc_msgSendSuper2");
        pdl_dynamic_objc_message_pointer_objc_msgSend_stret = dlsym(handle, "pdl_dynamic_bridge_objc_msgSend_stret");
        pdl_dynamic_objc_message_pointer_objc_msgSendSuper2_stret = dlsym(handle, "pdl_dynamic_bridge_objc_msgSendSuper2_stret");
    } else {
        pdl_dynamic_objc_message_pointer_objc_msgSend = dlsym(handle, "pdl_dynamic_bridge_objc_msgSendFull");
        pdl_dynamic_objc_message_pointer_objc_msgSendSuper2 = dlsym(handle, "pdl_dynamic_bridge_objc_msgSendSuper2Full");
        pdl_dynamic_objc_message_pointer_objc_msgSend_stret = dlsym(handle, "pdl_dynamic_bridge_objc_msgSend_stretFull");
        pdl_dynamic_objc_message_pointer_objc_msgSendSuper2_stret = dlsym(handle, "pdl_dynamic_bridge_objc_msgSendSuper2_stretFull");
    }
}
