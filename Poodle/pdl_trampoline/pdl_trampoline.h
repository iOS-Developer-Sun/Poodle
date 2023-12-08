//
//  pdl_trampoline.h
//  Poodle
//
//  Created by Poodle on 11-8-23.
//  Copyright © 2021 Poodle. All rights reserved.
//

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

extern void *pdl_trampoline(void *original, void(*before)(void *original, void *sp, void *data), void(*after)(void *original, void *sp, void *data), void *data);

#ifdef __cplusplus
}
#endif
