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

void *pdl_ptrauth_strip(void *pointer) {
    void *ret = pointer;
#ifdef __arm64e__
    ret = ptrauth_strip(ret, ptrauth_key_asia);
#endif
    return ret;
}

void *pdl_ptrauth_sign_unauthenticated(void *value, __unused void *data) {
    void *ret = value;
#ifdef __arm64e__
    ret = ptrauth_sign_unauthenticated(value, ptrauth_key_asia, data);
#endif
    return ret;
}

void *pdl_ptrauth_auth_function(void *value, __unused void *data) {
    void *ret = value;
#ifdef __arm64e__
    ret = ptrauth_auth_data(value, ptrauth_key_asia, data);
#endif
    return ret;
}

void *pdl_ptrauth_sign_unauthenticated_data(void *value, __unused void *data) {
    void *ret = value;
#ifdef __arm64e__
    ret = ptrauth_sign_unauthenticated(value, ptrauth_key_asdb, data);
#endif
    return ret;
}

