//
//  pdl_pac.h
//  Poodle
//
//  Created by Poodle on 22-9-9.
//  Copyright © 2022 Poodle. All rights reserved.
//

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

extern void *pdl_ptrauth_strip_function(void *value);
extern void *pdl_ptrauth_strip_data(void *value);

extern void *pdl_ptrauth_sign_unauthenticated_function(void *value, void *data);
extern void *pdl_ptrauth_auth_function(void *value, void *data);

extern void *pdl_ptrauth_sign_unauthenticated_data(void *value, void *data);
extern void *pdl_ptrauth_auth_data(void *value, void *data);

#ifdef __cplusplus
}
#endif
