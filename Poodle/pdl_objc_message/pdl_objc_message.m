//
//  pdl_objc_message.m
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_objc_message.h"

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

void(*pdl_objc_msgSend_original)(void) = &objc_msgSend;
void(*pdl_objc_msgSendSuper2_original)(void) = &objc_msgSendSuper2;

#ifndef __arm64__

void(*pdl_objc_msgSend_stret_original)(void) = &objc_msgSend_stret;
void(*pdl_objc_msgSendSuper2_stret_original)(void) = &objc_msgSendSuper2_stret;

#endif
