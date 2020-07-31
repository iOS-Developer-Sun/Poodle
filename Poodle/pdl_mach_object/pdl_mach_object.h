//
//  pdl_mach_object.h
//  Poodle
//
//  Created by Poodle on 25/09/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <mach/machine.h>
#include <mach-o/loader.h>
#include <mach-o/nlist.h>
#include <mach-o/fat.h>

typedef struct pdl_mach_object {
    bool is64;
    bool swaps;
    intptr_t vmaddr_slide;
    const char *name;

    uint32_t segments_count;
    const struct segment_command *segments[8];
    uint32_t total_segments_count;
    const struct segment_command *total_segments[16];

    // mach_header / mach_header_64
    const struct mach_header *header;

    // segment_command / segment_command_64
    const struct segment_command *page_zero_segment_command;
    const struct segment_command *text_segment_command;
    const struct segment_command *data_segment_command;
    const struct segment_command *linkedit_segment_command;

    const struct symtab_command *symtab_command;
    const struct symseg_command *symseg_command;
    const struct dysymtab_command *dysymtab_command;

    const struct dylib_command *id_dylib_dylib_command;
    const struct dylib_command *load_dylib_dylib_command;
    const struct dylib_command *load_weak_dylib_dylib_command;
    const struct dylib_command *reexport_dylib_dylib_command;

    // encryption_info_command / encryption_info_command_64
    const struct encryption_info_command *encryption_info_command;

    const struct dylinker_command *dyld_environment_dylinker_command;
    const struct dylinker_command *load_dylinker_dylinker_command;
    const struct dylinker_command *id_dylinker_dylinker_command;
    const struct prebound_dylib_command *prebound_dylib_command;

    const struct version_min_command *version_min_command;
    const struct source_version_command *source_version_command;
    const struct thread_command *thread_command;
    const struct thread_command *unix_thread_command;
    const struct ident_command *ident_command;
    const struct fvmfile_command *fvmfile_command;
    const struct fvmlib_command *loadfvmlib_fvmlib_command;
    const struct fvmlib_command *idfvmlib_fvmlib_command;

    const struct linker_option_command *linker_option_command;

    const struct linkedit_data_command *function_starts_linkedit_data_command;
    const struct linkedit_data_command *data_in_code_linkedit_data_command;
    const struct linkedit_data_command *code_signature_linkedit_data_command;
    const struct linkedit_data_command *segment_split_info_linkedit_data_command;
    const struct linkedit_data_command *dylib_code_sign_drs_linkedit_data_command;
    const struct linkedit_data_command *linker_optimization_hint_linkedit_data_command;

    const struct dyld_info_command *dyld_info_dyld_info_command;
    const struct dyld_info_command *dyld_info_only_dyld_info_command;
    const struct entry_point_command *entry_point_command;

    const struct uuid_command *uuid_command;
    const struct rpath_command *rpath_command;
    const struct sub_framework_command *sub_framework_command;
    const struct sub_umbrella_command *sub_umbrella_command;
    const struct sub_client_command *sub_client_command;
    const struct sub_library_command *sub_library_command;
    const struct twolevel_hints_command *twolevel_hints_command;
    const struct prebind_cksum_command *prebind_cksum_command;

    // routines_command / routines_command_64
    const struct routines_command *routines_command;

    uint64_t vmsize;
    uint64_t vmaddr;
    uint64_t linkedit_base;
    uint32_t symtab_count;
    // nlist / nlist_64
    const struct nlist *symtab_list;
    uint32_t strtab_size;
    const char *strtab;
} pdl_mach_object;

typedef struct pdl_mach_object_64 {
    bool is64;
    bool swaps;
    intptr_t vmaddr_slide;
    const char *name;

    uint32_t segments_count;
    const struct segment_command_64 *segments[8];
    uint32_t total_segments_count;
    const struct segment_command_64 *total_segments[16];

    // mach_header / mach_header_64
    const struct mach_header_64 *header;

    // segment_command / segment_command_64
    const struct segment_command_64 *page_zero_segment_command;
    const struct segment_command_64 *text_segment_command;
    const struct segment_command_64 *data_segment_command;
    const struct segment_command_64 *linkedit_segment_command;

    const struct segment_command_64 *symtab_command;
    const struct segment_command_64 *symseg_command;
    const struct dysymtab_command *dysymtab_command;

    const struct dylib_command *id_dylib_dylib_command;
    const struct dylib_command *load_dylib_dylib_command;
    const struct dylib_command *load_weak_dylib_dylib_command;
    const struct dylib_command *reexport_dylib_dylib_command;

    // encryption_info_command / encryption_info_command_64
    const struct encryption_info_command_64 *encryption_info_command;

    const struct dylinker_command *dyld_environment_dylinker_command;
    const struct dylinker_command *load_dylinker_dylinker_command;
    const struct dylinker_command *id_dylinker_dylinker_command;
    const struct prebound_dylib_command *prebound_dylib_command;

    const struct version_min_command *version_min_command;
    const struct source_version_command *source_version_command;
    const struct thread_command *thread_command;
    const struct thread_command *unix_thread_command;
    const struct ident_command *ident_command;
    const struct fvmfile_command *fvmfile_command;
    const struct fvmlib_command *loadfvmlib_fvmlib_command;
    const struct fvmlib_command *idfvmlib_fvmlib_command;

    const struct linker_option_command *linker_option_command;

    const struct linkedit_data_command *function_starts_linkedit_data_command;
    const struct linkedit_data_command *data_in_code_linkedit_data_command;
    const struct linkedit_data_command *code_signature_linkedit_data_command;
    const struct linkedit_data_command *segment_split_info_linkedit_data_command;
    const struct linkedit_data_command *dylib_code_sign_drs_linkedit_data_command;
    const struct linkedit_data_command *linker_optimization_hint_linkedit_data_command;

    const struct dyld_info_command *dyld_info_dyld_info_command;
    const struct dyld_info_command *dyld_info_only_dyld_info_command;
    const struct entry_point_command *entry_point_command;

    const struct uuid_command *uuid_command;
    const struct rpath_command *rpath_command;
    const struct sub_framework_command *sub_framework_command;
    const struct sub_umbrella_command *sub_umbrella_command;
    const struct sub_client_command *sub_client_command;
    const struct sub_library_command *sub_library_command;
    const struct twolevel_hints_command *twolevel_hints_command;
    const struct prebind_cksum_command *prebind_cksum_command;

    // routines_command / routines_command_64
    const struct routines_command_64 *routines_command;

    uint64_t vmsize;
    uint64_t vmaddr;
    uint64_t linkedit_base;
    uint32_t symtab_count;
    // nlist / nlist_64
    const struct nlist_64 *symtab_list;
    uint32_t strtab_size;
    const char *strtab;
} pdl_mach_object_64;

_Static_assert(sizeof(pdl_mach_object) == sizeof(pdl_mach_object_64),
                   "Incorrect pdl_mach_object size");

typedef struct pdl_fat_object {
    bool is64;
    bool swaps;
    const char *name;

    // fat_header / fat_header_64
    const struct fat_header *header;

    uint32_t arch_count;
    struct fat_arch *arch_list;
} pdl_fat_object;

typedef struct pdl_fat_object_64 {
    bool is64;
    bool swaps;
    const char *name;

    // fat_header / fat_header_64
    const struct fat_header_64 *header;

    uint32_t arch_count;
    struct fat_arch_64 *arch_list;
} pdl_fat_object_64;

_Static_assert(sizeof(pdl_fat_object) == sizeof(pdl_fat_object_64),
                   "Incorrect pdl_fat_object size");

extern bool pdl_get_mach_object_with_header(const struct mach_header *header, intptr_t vmaddr_slide, const char *name, pdl_mach_object *mach_object);

extern bool pdl_get_fat_object_with_header(const struct fat_header *header, pdl_fat_object *fat_object);

#ifdef __cplusplus
}
#endif
