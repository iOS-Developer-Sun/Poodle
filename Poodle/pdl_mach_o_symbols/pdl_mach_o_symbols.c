//
//  pdl_mach_o_symbols.c
//  Poodle
//
//  Created by Poodle on 25/09/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_mach_o_symbols.h"
#include <stdlib.h>
#include <mach-o/dyld.h>
#include "pdl_mach_object.h"

// filters

static bool contains_string(pdl_mach_o_symbol *symbol, void *filter_data) {
    return strstr(symbol->symbol_name, (char *)filter_data);
}

static bool matches_string(pdl_mach_o_symbol *symbol, void *filter_data) {
    return strcmp(symbol->symbol_name, (char *)filter_data) == 0;
}

static pdl_mach_o_symbol *_get_mach_o_symbol(pdl_mach_o_symbol *pointer, struct mach_header *header, intptr_t vmaddr_slide, const char *name, uint32_t index, void *filter_data, bool(*filter)(pdl_mach_o_symbol *symbol, void *filter_data)) {
    pdl_mach_object mach_object;
    bool result = pdl_get_mach_object_with_header(header, vmaddr_slide, name, &mach_object);
    if (!result) {
        return pointer;
    }

    pdl_mach_o_symbol *current = pointer;
    pdl_mach_o_symbol *ret = pointer;

    uint32_t symtab_count = mach_object.symtab_count;
    const struct nlist *symtab_list = mach_object.symtab_list;
    const char *strtab = mach_object.strtab;
    for (uint32_t i = 0; i < symtab_count; i++) {
        uint32_t strx = 0;
        uint8_t type = 0;
        uint8_t sect = 0;
        int16_t desc = 0;
        u_long value = 0;
        if (mach_object.is64 == false) {
            const struct nlist *symtab = &symtab_list[i];
            strx = symtab->n_un.n_strx;
            type = symtab->n_type;
            sect = symtab->n_sect;
            desc = symtab->n_desc;
            value = symtab->n_value;
        } else {
            const struct nlist_64 *symtab = &((struct nlist_64 *)symtab_list)[i];
            strx = symtab->n_un.n_strx;
            type = symtab->n_type;
            sect = symtab->n_sect;
            desc = symtab->n_desc;
            value = (u_long)symtab->n_value;
        }

        const char *str = strtab + strx;
        uintptr_t symbol = (uintptr_t)vmaddr_slide + value;

        pdl_mach_o_symbol symbol_test;

        symbol_test.n_type = type;
        symbol_test.n_desc = desc;
        symbol_test.n_sect = sect;
        symbol_test.n_value = value;
        symbol_test.symbol = symbol;
        symbol_test.symbol_name = str;
        symbol_test.symtab_index = i;
        symbol_test.header = header;
        symbol_test.next = NULL;

        if (filter && !filter(&symbol_test, filter_data)) {
            continue;
        }

        pdl_mach_o_symbol *node = (pdl_mach_o_symbol *)malloc(sizeof(pdl_mach_o_symbol));
        if (node == NULL) {
            break;
        }

        memcpy(node, &symbol_test, sizeof(symbol_test));

        if (current) {
            current->next = node;
            current = node;
        } else {
            current = node;
            ret = current;
        }
    }

    return ret;
}

pdl_mach_o_symbol *get_mach_o_symbol(struct mach_header *header, void *filter_data, bool(*filter)(pdl_mach_o_symbol *symbol, void *filter_data)) {
    pdl_mach_o_symbol *symbol = NULL;
    uint32_t count = _dyld_image_count();
    struct mach_header *header_found = NULL;
    for (uint32_t i = 0; i < count; i++) {
        struct mach_header *each_header = (struct mach_header *)_dyld_get_image_header(i);
        intptr_t vmaddr_slide = _dyld_get_image_vmaddr_slide(i);
        const char *name = _dyld_get_image_name(i);
        if (header) {
            if (header == each_header) {
                header_found = header;
                symbol = _get_mach_o_symbol(symbol, header, vmaddr_slide, name, i, filter_data, filter);
                break;
            }
        } else {
            symbol = _get_mach_o_symbol(symbol, each_header, vmaddr_slide, name, i, filter_data, filter);
        }
    }

    if (header && header_found == NULL) {
        symbol = _get_mach_o_symbol(symbol, header, -1, NULL, -1, filter_data, filter);
    }

    return symbol;
}

static const char *last_component(const char* path) {
    const char *start = strrchr(path, '/');
    return start ? start + 1 : path;
}

#pragma mark -

struct mach_header *pdl_mach_o_image(const char *image_name) {
    if (image_name == NULL) {
        return NULL;
    }

    struct mach_header *image = NULL;
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *full_name = _dyld_get_image_name(i);
        const char *last = last_component(full_name);
        if (strcmp(image_name, last) == 0) {
            image = (__typeof(image))_dyld_get_image_header(i);
            break;
        }
    }
    return image;
}

const char *pdl_mach_o_image_name(struct mach_header *header) {
    if (header == NULL) {
        return NULL;
    }

    const char *image_name = NULL;
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        if (header == _dyld_get_image_header(i)) {
            const char *full_name = _dyld_get_image_name(i);
            image_name = last_component(full_name);
            break;
        }
    }
    return image_name;
}

intptr_t pdl_mach_o_image_vmaddr_slide(struct mach_header *header) {
    if (header == NULL) {
        return 0;
    }

    intptr_t vmaddr_slide = 0;
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        if (header == _dyld_get_image_header(i)) {
            vmaddr_slide = _dyld_get_image_vmaddr_slide(i);
            break;
        }
    }
    return vmaddr_slide;
}

pdl_mach_o_symbol *pdl_get_mach_o_symbol_list_with_symbol_name(struct mach_header *header, char *symbol_name) {
    return get_mach_o_symbol(header, symbol_name, &matches_string);
}

pdl_mach_o_symbol *pdl_get_mach_o_symbol_list_contains_symbol_name(struct mach_header *header, char *symbol_name) {
    return get_mach_o_symbol(header, symbol_name, &contains_string);
}

pdl_mach_o_symbol *pdl_get_mach_o_symbol_list(struct mach_header *header, void *filter_data, bool(*filter)(pdl_mach_o_symbol *symbol, void *filter_data)) {
    return get_mach_o_symbol(header, filter_data, filter);
}

void pdl_free_mach_o_symbol_list(pdl_mach_o_symbol *symbol_list) {
    pdl_mach_o_symbol *node = symbol_list;
    while (node) {
        pdl_mach_o_symbol *node_to_free = node;
        node = node->next;
        free(node_to_free);
    }
}
