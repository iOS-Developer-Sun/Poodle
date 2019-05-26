//
//  pdl_objc_message.m
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//
//

#include <pdl_objc_message.h>

#define DYLD_INTERPOSE(_replacement,_replacee) \
__attribute__((used)) static struct{ const void* replacement; const void* replacee; } _interpose_##_replacee \
__attribute__ ((section ("__DATA,__interpose"))) = { (const void*)(unsigned long)&_replacement, (const void*)(unsigned long)&_replacee };

static void *pdl_malloc(size_t size) {
    void *address = malloc(size);
    return address;
}

void pdl_objc_msgSend_before(__unsafe_unretained id self, SEL _cmd) {
    ;
}

void pdl_objc_msgSend_after(__unsafe_unretained id self, SEL _cmd) {
    ;
}

__attribute__ ((constructor))
static void m(void) {
    ;
}

DYLD_INTERPOSE(pdl_malloc, malloc)

DYLD_INTERPOSE(pdl_objc_msgSend, objc_msgSend)
//DYLD_INTERPOSE(pdl_objc_msgSendSuper, objc_msgSendSuper)
#ifndef __arm64__
DYLD_INTERPOSE(pdl_objc_msgSend_stret, objc_msgSend_stret)
//DYLD_INTERPOSE(pdl_objc_msgSendSuper_stret, objc_msgSendSuper_stret)
#endif
