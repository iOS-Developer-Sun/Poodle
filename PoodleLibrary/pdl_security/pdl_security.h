//
//  pdl_security.h
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

#define PDL_ANTI_RE_DIE_CODE_TRACED 1
#define PDL_ANTI_RE_DIE_CODE_INSERTED_LIBRARIES 2

__attribute__((visibility("hidden")))
extern bool pdl_anti_re(void);

#ifdef __cplusplus
}
#endif
