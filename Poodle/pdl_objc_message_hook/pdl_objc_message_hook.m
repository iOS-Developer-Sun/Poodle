//
//  pdl_objc_message_hook.m
//  Poodle
//
//  Created by Poodle on 2020/10/10.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "pdl_objc_message_hook.h"
#import <dlfcn.h>
#import "pdl_objc_message_hook_dynamic.h"
#import "pdl_objc_message.h"
#import "pdl_asm.h"

__attribute__((naked))
void pdl_objc_message_hook_objc_msgSend(void) {
    PDL_ASM_GOTO(pdl_objc_msgSend);
}

__attribute__((naked))
void pdl_objc_message_hook_objc_msgSendFull(void) {
    PDL_ASM_GOTO(pdl_objc_msgSendFull);
}

__attribute__((naked))
void pdl_objc_message_hook_objc_msgSendSuper(void) {
    PDL_ASM_GOTO(pdl_objc_msgSendSuper);
}

__attribute__((naked))
void pdl_objc_message_hook_objc_msgSendSuperFull(void) {
    PDL_ASM_GOTO(pdl_objc_msgSendSuperFull);
}

__attribute__((naked))
void pdl_objc_message_hook_objc_msgSendSuper2(void) {
    PDL_ASM_GOTO(pdl_objc_msgSendSuper2);
}

__attribute__((naked))
void pdl_objc_message_hook_objc_msgSendSuper2Full(void) {
    PDL_ASM_GOTO(pdl_objc_msgSendSuper2Full);
}

#ifndef __arm64__

__attribute__((naked))
void pdl_objc_message_hook_objc_msgSend_stret(void) {
    PDL_ASM_GOTO(pdl_objc_msgSend_stret);
}

__attribute__((naked))
void pdl_objc_message_hook_objc_msgSend_stretFull(void) {
    PDL_ASM_GOTO(pdl_objc_msgSend_stretFull);
}

__attribute__((naked))
void pdl_objc_message_hook_objc_msgSendSuper_stret(void) {
    PDL_ASM_GOTO(pdl_objc_msgSendSuper_stret);
}

__attribute__((naked))
void pdl_objc_message_hook_objc_msgSendSuper_stretFull(void) {
    PDL_ASM_GOTO(pdl_objc_msgSendSuper_stretFull);
}

__attribute__((naked))
void pdl_objc_message_hook_objc_msgSendSuper2_stret(void) {
    PDL_ASM_GOTO(pdl_objc_msgSendSuper2_stret);
}

__attribute__((naked))
void pdl_objc_message_hook_objc_msgSendSuper2_stretFull(void) {
    PDL_ASM_GOTO(pdl_objc_msgSendSuper2_stretFull);
}

#endif

void pdl_objc_message_hook(void(*before)(__unsafe_unretained id self, SEL _cmd), void(*after)(__unsafe_unretained id self, SEL _cmd), void(*super_before)(struct objc_super *super, SEL _cmd), void(*super_after)(struct objc_super *super, SEL _cmd)) {
#ifdef __LP64__
    BOOL full = after || super_after;
    BOOL hook = before || super_before || full;
    if (!hook) {
        return;
    }

    void *handle = dlopen(NULL, RTLD_GLOBAL | RTLD_NOW);
    if (handle) {
       struct pdl_objc_message_functions (*hook)(BOOL full) = (typeof(hook))dlsym(handle, "pdl_objc_message_hook_dynamic_init");
        if (hook) {
            struct pdl_objc_message_functions functions = hook(full);
            pdl_objc_msgSend_original = functions.objc_msgSend;
            pdl_objc_msgSendSuper_original = functions.objc_msgSendSuper;
            pdl_objc_msgSendSuper2_original = functions.objc_msgSendSuper2;
#ifndef __arm64__
            pdl_objc_msgSend_stret_original = functions.objc_msgSend_stret;
            pdl_objc_msgSendSuper_stret_original = functions.objc_msgSendSuper_stret;
            pdl_objc_msgSendSuper2_stret_original = functions.objc_msgSendSuper2_stret;
#endif
        }
        dlclose(handle);
        if (!hook) {
            return;
        }
    } else {
        return;
    }

    pdl_objc_message_set_msgSend_before_action(before);
    pdl_objc_message_set_msgSend_after_action(after);
    pdl_objc_message_set_msgSendSuper_before_action(super_before);
    pdl_objc_message_set_msgSendSuper_after_action(super_after);
#endif
}
