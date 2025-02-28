//
//  pdl_hook.m
//  Poodle
//
//  Created by Poodle on 21-4-28.
//  Copyright © 2021 Poodle. All rights reserved.
//

#include "pdl_hook.h"
#include "PDLSystemImage.h"
#include "pdl_vm.h"
#include "pdl_pac.h"

int pdl_hook(pdl_hook_item *items, size_t count) {
    __block int ret = 0;
    PDLSystemImage *systemImage = [PDLSystemImage executeSystemImage];
    [systemImage enumerateNonLazySymbolPointers:^(PDLSystemImage *systemImage, const char *symbol, void **address) {
        for (size_t i = 0; i < count; i++) {
            pdl_hook_item *item = items + i;
            if (symbol[0] == '_' && strcmp(symbol + 1, item->name) == 0) {
                void *data = pdl_ptrauth_sign_unauthenticated_function(pdl_ptrauth_strip_function(item->custom), address);
                bool written = pdl_vm_write(&data, address, sizeof(data));
                if (written) {
                    void **original = item->original;
                    if (original) {
                        *original = item->external;
                    }
                    ret++;
                }
            }
        }
    }];
    [systemImage enumerateLazySymbolPointers:^(PDLSystemImage *systemImage, const char *symbol, void **address) {
        for (size_t i = 0; i < count; i++) {
            pdl_hook_item *item = items + i;
            if (symbol[0] == '_' && strcmp(symbol + 1, item->name) == 0) {
                void *data = pdl_ptrauth_sign_unauthenticated_function(pdl_ptrauth_strip_function(item->custom), address);
                bool written = pdl_vm_write(&data, address, sizeof(data));
                if (written) {
                    void **original = item->original;
                    if (original) {
                        *original = item->external;
                    }
                    ret++;
                }
            }
        }
    }];
    return ret;
}
