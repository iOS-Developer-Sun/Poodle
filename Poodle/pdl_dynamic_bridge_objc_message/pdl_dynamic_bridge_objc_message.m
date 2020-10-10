//
//  pdl_dynamic_bridge_objc_message.m
//  Poodle
//
//  Created by Poodle on 2020/10/10.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "pdl_dynamic_bridge_objc_message.h"
#import "pdl_asm.h"

__attribute__((naked))
void pdl_dynamic_bridge_objc_msgSend(void) {
    PDL_ASM_GOTO(pdl_objc_msgSend);
}

__attribute__((naked))
void pdl_dynamic_bridge_objc_msgSendFull(void) {
    PDL_ASM_GOTO(pdl_objc_msgSendFull);
}

__attribute__((naked))
void pdl_dynamic_bridge_objc_msgSendSuper2(void) {
    PDL_ASM_GOTO(pdl_objc_msgSendSuper2);
}

__attribute__((naked))
void pdl_dynamic_bridge_objc_msgSendSuper2Full(void) {
    PDL_ASM_GOTO(pdl_objc_msgSendSuper2Full);
}

#ifndef __arm64__

__attribute__((naked))
void pdl_dynamic_bridge_objc_msgSend_stret(void) {
    PDL_ASM_GOTO(pdl_objc_msgSend_stret);
}

__attribute__((naked))
void pdl_dynamic_bridge_objc_msgSend_stretFull(void) {
    PDL_ASM_GOTO(pdl_objc_msgSend_stretFull);
}

__attribute__((naked))
void pdl_dynamic_bridge_objc_msgSendSuper2_stret(void) {
    PDL_ASM_GOTO(pdl_objc_msgSendSuper2_stret);
}

__attribute__((naked))
void pdl_dynamic_bridge_objc_msgSendSuper2_stretFull(void) {
    PDL_ASM_GOTO(pdl_objc_msgSendSuper2_stretFull);
}

#endif
