//
//  pdl_mach_o_symbols.h
//  Poodle
//
//  Created by Poodle on 25/09/2017.
//  
//

#ifndef pdl_mach_o_symbols_h
#define pdl_mach_o_symbols_h

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <mach/machine.h>
#include <mach-o/loader.h>
#include <mach-o/nlist.h>

#if TARGET_IPHONE_SIMULATOR

#define PDL_MACH_O_SYMBOLS_POINTER_FUNCTION_DECLARATION(function, image_name, symbol_name) \
    static void **function(void) {\
        static void **pointer = NULL;\
        if (pointer) {\
            return pointer;\
        }\
        struct mach_header *header = pdl_mach_o_image(image_name);\
        char *name = (symbol_name);\
        struct pdl_mach_o_symbol *symbols = pdl_get_mach_o_symbol_list_contains_symbol_name(header, name);\
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
        struct pdl_mach_o_symbol *symbols = pdl_mach_o_const_symbol(header, name);\
        if (symbols) {\
            pointer = (typeof(pointer))symbols->symbol;\
            pdl_free_mach_o_symbol_list(symbols);\
        }\
        return pointer;\
    }
    
#endif

struct pdl_mach_o_symbol {
    // nlist
    uint8_t n_type;
    uint8_t n_sect;
    int16_t n_desc;
    uint64_t n_value;

    uintptr_t symbol;
    const char *symbol_name;
    uint32_t symtab_index;
    struct mach_header *header;
    struct pdl_mach_o_symbol *next;
};

/**
 * Returns the mach header with the file last component equivalent to the given name.
 *
 * @param image_name        The last component of the image.
 *
 * @return mach_header      Returns NULL if the image does not exist.
 */
extern struct mach_header *pdl_mach_o_image(const char *image_name);

/**
 * Returns the file last component of the given mach header.
 *
 * @param header            The mach header.
 *
 * @return mach_header      Returns NULL if the header is invalid.
 */
extern const char *pdl_mach_o_image_name(struct mach_header *header);

/**
 * Returns the slide of the given mach header.
 *
 * @param header            The mach header.
 *
 * @return slide          Returns 0 if the header is invalid.
 */
extern intptr_t pdl_mach_o_image_vmaddr_slide(struct mach_header *header);

/**
 * Returns the symbols in the symtab of an image or all images.
 *
 * @param header        if header is NULL, search all headers
 * @param symbol_name   symbol name.
 *
 * @return symbol list. You must free every node of the list with free() or free the list with pdl_free_mach_o_symbol_list()
 */
extern struct pdl_mach_o_symbol *pdl_get_mach_o_symbol_list_with_symbol_name(struct mach_header *header, char *symbol_name);
extern struct pdl_mach_o_symbol *pdl_get_mach_o_symbol_list_contains_symbol_name(struct mach_header *header, char *symbol_name);
extern struct pdl_mach_o_symbol *pdl_get_mach_o_symbol_list(struct mach_header *header, void *filter_data, bool(*filter)(struct pdl_mach_o_symbol *symbol, void *filter_data));

extern void pdl_free_mach_o_symbol_list(struct pdl_mach_o_symbol *symbol_list);

#if !TARGET_IPHONE_SIMULATOR

/**
 * Returns the symbols in the symtab of an image in dyld cache.
 *
 * @param header        if header is NULL, returns NULL
 * @param symbol_name   symbol name.
 *
 * @return symbol. You must free the node with free() or pdl_free_mach_o_symbol_list()
 */
extern struct pdl_mach_o_symbol *pdl_mach_o_const_symbol(struct mach_header *header, const char *symbol_name);

#endif

#ifdef __cplusplus
}
#endif

#endif /* mach_object_h */
