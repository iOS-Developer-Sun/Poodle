//
//  pdl_objc_message_hook_dynamic_source.h
//  Poodle
//
//  Created by Poodle on 2020/10/10.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "pdl_objc_message_hook_dynamic.h"
#import <dlfcn.h>
#import "pdl_asm.h"
#import "pdl_dynamic.h"
#import "NSObject+PDLPrivate.h"

__attribute__((visibility("hidden")))
void *pdl_objc_message_hook_dyld_pointer_objc_msgSend = NULL;
__attribute__((visibility("hidden")))
void *pdl_objc_message_hook_dyld_pointer_objc_msgSendSuper = NULL;
__attribute__((visibility("hidden")))
void *pdl_objc_message_hook_dyld_pointer_objc_msgSendSuper2 = NULL;
__attribute__((visibility("hidden")))
void *pdl_objc_message_hook_dyld_pointer_objc_msgSend_stret = NULL;
__attribute__((visibility("hidden")))
void *pdl_objc_message_hook_dyld_pointer_objc_msgSendSuper_stret = NULL;
__attribute__((visibility("hidden")))
void *pdl_objc_message_hook_dyld_pointer_objc_msgSendSuper2_stret = NULL;

#pragma mark - x86_64

#ifdef __x86_64__

__attribute__((visibility("hidden"), naked))
void pdl_objc_message_hook_dyld_objc_msgSend(void) {
    __asm__ __volatile__
    (
     "movq    _pdl_objc_message_hook_dyld_pointer_objc_msgSend(%rip), %r11\n"
     "cmpq    $0, %r11\n"
     "je      LOriginal\n"
     "jmpq    *%r11\n"
     "LOriginal:\n"
     "jmp     _objc_msgSend\n"
     );
}

__attribute__((visibility("hidden"), naked))
void pdl_objc_message_hook_dyld_objc_msgSend_stret(void) {
    __asm__ __volatile__
    (
     "movq    _pdl_objc_message_hook_dyld_pointer_objc_msgSend_stret(%rip), %r11\n"
     "cmpq    $0, %r11\n"
     "je      LOriginal_stret\n"
     "jmpq    *%r11\n"
     "LOriginal_stret:\n"
     "jmp     _objc_msgSend_stret\n"
     );
}

__attribute__((visibility("hidden"), naked))
void pdl_objc_message_hook_dyld_objc_msgSendSuper2(void) {
    __asm__ __volatile__
    (
     "movq    _pdl_objc_message_hook_dyld_pointer_objc_msgSendSuper2(%rip), %r11\n"
     "cmpq    $0, %r11\n"
     "je      LOriginalSuper\n"
     "jmpq    *%r11\n"
     "LOriginalSuper:\n"
     "jmp     _objc_msgSendSuper2\n"
     );
}

__attribute__((visibility("hidden"), naked))
void pdl_objc_message_hook_dyld_objc_msgSendSuper2_stret(void) {
    __asm__ __volatile__
    (
     "movq    _pdl_objc_message_hook_dyld_pointer_objc_msgSendSuper2_stret(%rip), %r11\n"
     "cmpq    $0, %r11\n"
     "je      LOriginalSuper_stret\n"
     "jmpq    *%r11\n"
     "LOriginalSuper_stret:\n"
     "jmp     _objc_msgSendSuper2_stret\n"
     );
}

#endif

#pragma mark - arm64

#ifdef __arm64__

__attribute__((visibility("hidden"), naked))
void pdl_objc_message_hook_dyld_objc_msgSend(void) {
    __asm__ __volatile__
    (
     "adrp x9, _pdl_objc_message_hook_dyld_pointer_objc_msgSend@PAGE\n"
     "ldr x9, [x9, _pdl_objc_message_hook_dyld_pointer_objc_msgSend@PAGEOFF]\n"
     "cbz x9, LOriginal\n"
#ifdef __arm64e__
     "braaz x9\n"
#else
     "br x9\n"
#endif
     "LOriginal:\n"
     "b _objc_msgSend\n"
     );
}

__attribute__((visibility("hidden"), naked))
void pdl_objc_message_hook_dyld_objc_msgSendSuper2(void) {
    __asm__ __volatile__
    (
     "adrp x9, _pdl_objc_message_hook_dyld_pointer_objc_msgSendSuper2@PAGE\n"
     "ldr x9, [x9, _pdl_objc_message_hook_dyld_pointer_objc_msgSendSuper2@PAGEOFF]\n"
     "cbz x9, LOriginalSuper\n"
#ifdef __arm64e__
     "braaz x9\n"
#else
     "br x9\n"
#endif
     "LOriginalSuper:\n"
     "b _objc_msgSendSuper2\n"
     );
}

#endif

#pragma mark -

#ifdef __LP64__

PDL_DYLD_INTERPOSE(pdl_objc_message_hook_dyld_objc_msgSend, objc_msgSend);
PDL_DYLD_INTERPOSE(pdl_objc_message_hook_dyld_objc_msgSendSuper2, objc_msgSendSuper2);

#ifndef __arm64__

extern void pdl_objc_message_hook_dyld_objc_msgSend_stret(void);
extern void pdl_objc_message_hook_dyld_objc_msgSendSuper2_stret(void);

PDL_DYLD_INTERPOSE(pdl_objc_message_hook_dyld_objc_msgSend_stret, objc_msgSend_stret);
PDL_DYLD_INTERPOSE(pdl_objc_message_hook_dyld_objc_msgSendSuper2_stret, objc_msgSendSuper2_stret);

#endif
#endif

__attribute__((naked))
void pdl_objc_message_hook_dynamic_objc_msgSend(void) {
    PDL_ASM_GOTO(objc_msgSend);
}

__attribute__((naked))
void pdl_objc_message_hook_dynamic_objc_msgSendSuper(void) {
    PDL_ASM_GOTO(objc_msgSendSuper);
}

__attribute__((naked))
void pdl_objc_message_hook_dynamic_objc_msgSendSuper2(void) {
    PDL_ASM_GOTO(objc_msgSendSuper2);
}

#ifndef __arm64__

__attribute__((naked))
void pdl_objc_message_hook_dynamic_objc_msgSend_stret(void) {
    PDL_ASM_GOTO(objc_msgSend_stret);
}

__attribute__((naked))
void pdl_objc_message_hook_dynamic_objc_msgSendSuper_stret(void) {
    PDL_ASM_GOTO(objc_msgSendSuper_stret);
}

__attribute__((naked))
void pdl_objc_message_hook_dynamic_objc_msgSendSuper2_stret(void) {
    PDL_ASM_GOTO(objc_msgSendSuper2_stret);
}

#endif

struct pdl_objc_message_functions pdl_objc_message_hook_dynamic_init(BOOL full) {
    struct pdl_objc_message_functions functions = {NULL};
#ifdef __LP64__

    functions.objc_msgSend = pdl_objc_message_hook_dynamic_objc_msgSend;
    functions.objc_msgSendSuper = pdl_objc_message_hook_dynamic_objc_msgSendSuper;
    functions.objc_msgSendSuper2 = pdl_objc_message_hook_dynamic_objc_msgSendSuper2;
#ifndef __arm64__
    functions.objc_msgSend_stret = pdl_objc_message_hook_dynamic_objc_msgSend_stret;
    functions.objc_msgSendSuper_stret = pdl_objc_message_hook_dynamic_objc_msgSendSuper_stret;
    functions.objc_msgSendSuper2_stret = pdl_objc_message_hook_dynamic_objc_msgSendSuper2_stret;
#endif

    void *handle = dlopen(NULL, RTLD_GLOBAL | RTLD_NOW);
    if (handle) {
        if (!full) {
            pdl_objc_message_hook_dyld_pointer_objc_msgSend = dlsym(handle, "pdl_objc_message_hook_objc_msgSend");
            pdl_objc_message_hook_dyld_pointer_objc_msgSendSuper = dlsym(handle, "pdl_objc_message_hook_objc_msgSendSuper");
            pdl_objc_message_hook_dyld_pointer_objc_msgSendSuper2 = dlsym(handle, "pdl_objc_message_hook_objc_msgSendSuper2");
            pdl_objc_message_hook_dyld_pointer_objc_msgSend_stret = dlsym(handle, "pdl_objc_message_hook_objc_msgSend_stret");
            pdl_objc_message_hook_dyld_pointer_objc_msgSendSuper_stret = dlsym(handle, "pdl_objc_message_hook_objc_msgSendSuper_stret");
            pdl_objc_message_hook_dyld_pointer_objc_msgSendSuper2_stret = dlsym(handle, "pdl_objc_message_hook_objc_msgSendSuper2_stret");
        } else {
            pdl_objc_message_hook_dyld_pointer_objc_msgSend = dlsym(handle, "pdl_objc_message_hook_objc_msgSendFull");
            pdl_objc_message_hook_dyld_pointer_objc_msgSendSuper = dlsym(handle, "pdl_objc_message_hook_objc_msgSendSuperFull");
            pdl_objc_message_hook_dyld_pointer_objc_msgSendSuper2 = dlsym(handle, "pdl_objc_message_hook_objc_msgSendSuper2Full");
            pdl_objc_message_hook_dyld_pointer_objc_msgSend_stret = dlsym(handle, "pdl_objc_message_hook_objc_msgSend_stretFull");
            pdl_objc_message_hook_dyld_pointer_objc_msgSendSuper_stret = dlsym(handle, "pdl_objc_message_hook_objc_msgSendSuper_stretFull");
            pdl_objc_message_hook_dyld_pointer_objc_msgSendSuper2_stret = dlsym(handle, "pdl_objc_message_hook_objc_msgSendSuper2_stretFull");
        }
        dlclose(handle);
    }
#endif
    return functions;
}

