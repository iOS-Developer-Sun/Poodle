//
//  pdl_objc_message-arm64.s
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_asm-universal.h"

#ifdef __arm64__

.text
.align 4
.private_extern _pdl_objc_msgSend
.private_extern _pdl_objc_msgSend_stret
.private_extern _pdl_objc_msgSendSuper2
.private_extern _pdl_objc_msgSendSuper2_stret

_pdl_objc_msgSend:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    bl     _pdl_objc_msgSend_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    b      _objc_msgSend

_pdl_objc_msgSend_stret:
    b      _pdl_objc_msgSend

_pdl_objc_msgSendSuper2:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE
    bl     _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    b      _objc_msgSendSuper2

_pdl_objc_msgSendSuper2_stret:
    b      _pdl_objc_msgSendSuper2

#endif