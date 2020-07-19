//
//  pdl_mach_o_symbol_pointer.h
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "pdl_mach_o_symbols.h"

#ifdef __cplusplus
extern "C" {
#endif

#if TARGET_IPHONE_SIMULATOR

#define PDL_MACH_O_SYMBOLS_POINTER_FUNCTION_DECLARATION(function, image_name, symbol_name) \
    static void **function(void) {\
        static void **pointer = NULL;\
        if (pointer) {\
            return pointer;\
        }\
        struct mach_header *header = pdl_mach_o_image(image_name);\
        char *name = (symbol_name);\
        pdl_mach_o_symbol *symbols = pdl_get_mach_o_symbol_list_contains_symbol_name(header, name);\
        if (symbols) {\
            pointer = (typeof(pointer))symbols->symbol;\
            pdl_free_mach_o_symbol_list(symbols);\
        }\
        return pointer;\
    }

#else

#define PDL_MACH_O_SYMBOLS_POINTER_FUNCTION_DECLARATION(function, image_name, symbol_name) \
    static void **function(void) {\
        static void **pointer = NULL;\
        if (pointer) {\
            return pointer;\
        }\
        struct mach_header *header = pdl_mach_o_image(image_name);\
        char *name = (symbol_name);\
        pdl_mach_o_symbol *symbols = pdl_mach_o_const_symbol(header, name);\
        if (symbols) {\
            pointer = (typeof(pointer))symbols->symbol;\
            pdl_free_mach_o_symbol_list(symbols);\
        }\
        return pointer;\
    }

#endif

#if !TARGET_IPHONE_SIMULATOR

/**
 * Returns the symbols in the symtab of an image in dyld cache.
 *
 * @param header        if header is NULL, returns NULL
 * @param symbol_name   symbol name.
 *
 * @return symbol. You must free the node with free() or pdl_free_mach_o_symbol_list()
 */
extern pdl_mach_o_symbol *pdl_mach_o_const_symbol(struct mach_header *header, const char *symbol_name);

#endif

#ifdef __cplusplus
}
#endif
