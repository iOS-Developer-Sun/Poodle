//
//  pdl_pac.m
//  Poodle
//
//  Created by Poodle on 22-9-9.
//  Copyright © 2022 Poodle. All rights reserved.
//

#include "pdl_pac.h"
#include <ptrauth.h>
#include <assert.h>

void *pdl_ptrauth_strip_function(void *value) {
    void *ret = value;
#ifdef __arm64e__
    ret = ptrauth_strip(ret, ptrauth_key_asia); // xpaci value
#endif
    return ret;
}

void *pdl_ptrauth_strip_data(void *value) {
    void *ret = value;
#ifdef __arm64e__
    ret = ptrauth_strip(ret, ptrauth_key_asdb); // xpacd value
#endif
    return ret;
}

void *pdl_ptrauth_sign_unauthenticated_function(void *value, __unused void *data) {
    void *ret = value;
#ifdef __arm64e__
    ret = ptrauth_sign_unauthenticated(value, ptrauth_key_asia, data); // pacia value, data
#endif
    return ret;
}

void *pdl_ptrauth_auth_function(void *value, __unused void *data) {
    void *ret = value;
#ifdef __arm64e__
    ret = ptrauth_auth_data(value, ptrauth_key_asia, data); // autia value, data
#endif
    return ret;
}

void *pdl_ptrauth_sign_unauthenticated_data(void *value, __unused void *data) {
    void *ret = value;
#ifdef __arm64e__
    ret = ptrauth_sign_unauthenticated(value, ptrauth_key_asdb, data); // pacdb value, data
#endif
    return ret;
}

void *pdl_ptrauth_auth_data(void *value, __unused void *data) {
    void *ret = value;
#ifdef __arm64e__
    ret = ptrauth_auth_data(value, ptrauth_key_asdb, data); // autdb value, data
#endif
    return ret;
}
