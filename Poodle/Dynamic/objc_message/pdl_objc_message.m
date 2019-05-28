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

static void(*_pdl_objc_msgSend_before_action)(__unsafe_unretained id self, SEL _cmd) = NULL;
static void(*_pdl_objc_msgSendSuper_before_action)(struct objc_super *super, SEL _cmd) = NULL;

void(*pdl_get_objc_msgSend_before_action(void))(__unsafe_unretained id self, SEL _cmd) {
    return _pdl_objc_msgSend_before_action;
}

void pdl_set_objc_msgSend_before_action(void(*pdl_objc_msgSend_before_action)(__unsafe_unretained id self, SEL _cmd)) {
    _pdl_objc_msgSend_before_action = pdl_objc_msgSend_before_action;
}

void(*pdl_get_objc_msgSendSuper_before_action(void))(struct objc_super *super, SEL _cmd) {
    return _pdl_objc_msgSendSuper_before_action;
}

void pdl_set_objc_msgSendSuper_before_action(void(*pdl_objc_msgSendSuper_before_action)(struct objc_super *super, SEL _cmd)) {
    _pdl_objc_msgSendSuper_before_action = pdl_objc_msgSendSuper_before_action;
}

__attribute__((visibility("hidden")))
void pdl_objc_msgSend_before(__unsafe_unretained id self, SEL _cmd) {
    typeof(_pdl_objc_msgSend_before_action) function = _pdl_objc_msgSend_before_action;
    if (function) {
        function(self, _cmd);
    }
}

__attribute__((visibility("hidden")))
void pdl_objc_msgSendSuper_before(struct objc_super *super, SEL _cmd) {
    typeof(_pdl_objc_msgSendSuper_before_action) function = _pdl_objc_msgSendSuper_before_action;
    if (function) {
        function(super, _cmd);
    }
}

__attribute__ ((constructor))
//static
void pdl_objc_message(void) {
    printf("pdl_objc_message\n");
}

extern IMP pdl_objc_msgSend;
extern IMP pdl_objc_msgSendSuper2;

DYLD_INTERPOSE(pdl_objc_msgSend, objc_msgSend)
DYLD_INTERPOSE(pdl_objc_msgSendSuper2, objc_msgSendSuper2)

#ifndef __arm64__

extern IMP pdl_objc_msgSend_stret;
extern IMP pdl_objc_msgSendSuper2_stret;

DYLD_INTERPOSE(pdl_objc_msgSend_stret, objc_msgSend_stret)
DYLD_INTERPOSE(pdl_objc_msgSendSuper2_stret, objc_msgSendSuper2_stret)

#endif
