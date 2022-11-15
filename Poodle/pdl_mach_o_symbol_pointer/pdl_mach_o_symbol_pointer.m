//
//  pdl_mach_o_symbol_pointer.m
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "pdl_mach_o_symbol_pointer.h"
#import "pdl_mach_o_const_symbols.h"
#import <Foundation/Foundation.h>
#import <mach-o/ldsyms.h>
#import <dlfcn.h>
#import "pdl_mach_o_symbols.h"
#import "dsc_extractor.h"
#import "pdl_mach_object.h"

#if !TARGET_IPHONE_SIMULATOR

pdl_mach_o_symbol *pdl_mach_o_const_symbol(struct mach_header *header, const char *symbol_name) {
    if (header == NULL || symbol_name == NULL) {
        return NULL;
    }

    const char *image_name = pdl_mach_o_image_name(header);
    if (image_name == NULL) {
        return NULL;
    }

    pdl_mach_o_symbol *symbols = pdl_const_symbols(image_name, symbol_name);
    if (symbols == NULL) {
        return NULL;
    }

    return symbols;
}

#endif
