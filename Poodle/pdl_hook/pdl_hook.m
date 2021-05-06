//
//  pdl_hook.c
//  Poodle
//
//  Created by Poodle on 21-4-28.
//  Copyright © 2021 Poodle. All rights reserved.
//

#include "pdl_hook.h"
#include "PDLSystemImage.h"
#include "pdl_vm.h"

int pdl_hook(pdl_hook_item *items, size_t count) {
    __block int ret = 0;
    PDLSystemImage *systemImage = [PDLSystemImage executeSystemImage];
    [systemImage enumerateLazySymbolPointers:^(PDLSystemImage *systemImage, const char *symbol, void **address) {
        for (size_t i = 0; i < count; i++) {
            pdl_hook_item *item = items + i;
            if (symbol[0] == '_' && strcmp(symbol + 1, item->name) == 0) {
                bool written = pdl_vm_write(address, item->custom, NULL);
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
