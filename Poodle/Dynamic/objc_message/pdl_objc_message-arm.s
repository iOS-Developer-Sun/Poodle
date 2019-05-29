//
//  pdl_objc_message-arm.s
//  Poodle
//
//  Created by Poodle on 2019/5/25.
//
//

#include <pdl_asm.h>

#ifdef __arm__

.text
.align 4
.private_extern _pdl_objc_msgSend
.private_extern _pdl_objc_msgSend_stret
.private_extern _pdl_objc_msgSendSuper2
.private_extern _pdl_objc_msgSendSuper2_stret

_pdl_objc_msgSend:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    bl     _pdl_objc_msgSend_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    b     _objc_msgSend

_pdl_objc_msgSend_stret:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    bl     _pdl_objc_msgSend_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    b      _objc_msgSend_stret

_pdl_objc_msgSendSuper2:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE NORMAL
    bl     _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    b     _objc_msgSendSuper2

_pdl_objc_msgSendSuper2_stret:
    PDL_ASM_OBJC_MESSAGE_STATE_SAVE STRET
    bl     _pdl_objc_msgSendSuper_before
    PDL_ASM_OBJC_MESSAGE_STATE_RESTORE
    b      _objc_msgSendSuper2_stret

#endif
