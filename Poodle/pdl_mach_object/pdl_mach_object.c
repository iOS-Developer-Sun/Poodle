//
//  pdl_mach_object.c
//  Poodle
//
//  Created by Poodle on 25/09/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_mach_object.h"

bool pdl_get_mach_object_with_header(const struct mach_header *header, intptr_t vmaddr_slide, const char *name, pdl_mach_object *mach_object) {
    if (header == NULL) {
        return false;
    }

    bool is64 = false;
    bool swaps = false;
    uintptr_t command_pointer = 0;
    switch(header->magic) {
        case MH_CIGAM:
            swaps = true;
        case MH_MAGIC:
            command_pointer = (uintptr_t)(header + 1);
            is64 = false;
            break;
        case MH_CIGAM_64:
            swaps = true;
        case MH_MAGIC_64:
            command_pointer = (uintptr_t)(((struct mach_header_64 *)header) + 1);
            is64 = true;
            break;
        default:
            return false;
    }

    if (mach_object == NULL) {
        return true;
    }

    memset(mach_object, 0, sizeof(*mach_object));

    mach_object->is64 = is64;
    mach_object->swaps = swaps;
    mach_object->vmaddr_slide = vmaddr_slide;
    mach_object->name = name;
    mach_object->header = header;

    for (uint32_t i = 0; i < header->ncmds; i++) {
        struct load_command *load_command = (struct load_command *)command_pointer;
        uint32_t cmd = load_command->cmd;
        uint32_t cmdsize = load_command->cmdsize;
        switch (cmd) {
            case LC_SEGMENT:
            case LC_SEGMENT_64: {
                struct segment_command *segment_command = (struct segment_command *)command_pointer;
                char *segname = segment_command->segname;
                if (strcmp(segname, SEG_TEXT) == 0) {
                    mach_object->text_segment_command = segment_command;
                    if (is64 == false) {
                        mach_object->vmaddr = segment_command->vmaddr;
                        mach_object->vmsize = segment_command->vmsize;
                    } else {
                        mach_object->vmaddr = (uintptr_t)((const struct segment_command_64 *)segment_command)->vmaddr;
                        mach_object->vmsize = ((const struct segment_command_64 *)segment_command)->vmsize;

                    }
                } else if (strcmp(segname, SEG_DATA) == 0) {
                    mach_object->data_segment_command = segment_command;
                } else if (strcmp(segname, SEG_LINKEDIT) == 0) {
                    mach_object->linkedit_segment_command = segment_command;
                } else if (strcmp(segname, SEG_PAGEZERO) == 0) {
                    mach_object->page_zero_segment_command = segment_command;
                } else {
                    ;
                }
                if (mach_object->total_segments_count < sizeof(mach_object->total_segments) / sizeof(mach_object->total_segments[0])) {
                    mach_object->total_segments[mach_object->total_segments_count] = segment_command;
                }
                mach_object->total_segments_count++;
                uint64_t filesize = (is64 == false) ? segment_command->filesize : ((struct segment_command_64 *)segment_command)->filesize;
                if (filesize > 0) {
                    if (mach_object->segments_count < sizeof(mach_object->segments) / sizeof(mach_object->segments[0])) {
                        mach_object->segments[mach_object->segments_count] = segment_command;
                    }
                    mach_object->segments_count++;
                }
            } break;
            case LC_SYMTAB: {
                mach_object->symtab_command = (struct symtab_command *)command_pointer;
            } break;
            case LC_SYMSEG: {
                mach_object->symseg_command = (struct symseg_command *)command_pointer;
            } break;
            case LC_THREAD: {
                mach_object->thread_command = (struct thread_command *)command_pointer;
            } break;
            case LC_UNIXTHREAD: {
                mach_object->unix_thread_command = (struct thread_command *)command_pointer;
            } break;
            case LC_LOADFVMLIB: {
                mach_object->loadfvmlib_fvmlib_command = (struct fvmlib_command *)command_pointer;
            } break;
            case LC_IDFVMLIB: {
                mach_object->idfvmlib_fvmlib_command = (struct fvmlib_command *)command_pointer;
            } break;
            case LC_IDENT: {
                mach_object->ident_command = (struct ident_command *)command_pointer;
            } break;
            case LC_FVMFILE: {
                // internal use
                mach_object->fvmfile_command = (struct fvmfile_command *)command_pointer;
            } break;
            case LC_PREPAGE: {
                // internal use
                ;
            } break;
            case LC_DYSYMTAB: {
                mach_object->dysymtab_command = (struct dysymtab_command *)command_pointer;
            } break;
            case LC_LOAD_DYLIB: {
                mach_object->load_dylib_dylib_command = (struct dylib_command *)command_pointer;
            } break;
            case LC_ID_DYLIB: {
                mach_object->id_dylib_dylib_command = (struct dylib_command *)command_pointer;
            } break;
            case LC_LOAD_DYLINKER: {
                mach_object->load_dylinker_dylinker_command = (struct dylinker_command *)command_pointer;
            } break;
            case LC_ID_DYLINKER: {
                mach_object->id_dylinker_dylinker_command = (struct dylinker_command *)command_pointer;
            } break;
            case LC_PREBOUND_DYLIB: {
                mach_object->prebound_dylib_command = (struct prebound_dylib_command *)command_pointer;
            } break;
            case LC_ROUTINES:
            case LC_ROUTINES_64: {
                mach_object->routines_command = (struct routines_command *)command_pointer;
            } break;
            case LC_SUB_FRAMEWORK: {
                mach_object->sub_framework_command = (struct sub_framework_command *)command_pointer;
            } break;
            case LC_SUB_UMBRELLA: {
                mach_object->sub_umbrella_command = (struct sub_umbrella_command *)command_pointer;
            } break;
            case LC_SUB_CLIENT: {
                mach_object->sub_client_command = (struct sub_client_command *)command_pointer;
            } break;
            case LC_SUB_LIBRARY: {
                mach_object->sub_library_command = (struct sub_library_command *)command_pointer;
            } break;
            case LC_TWOLEVEL_HINTS: {
                mach_object->twolevel_hints_command = (struct twolevel_hints_command *)command_pointer;
            } break;
            case LC_PREBIND_CKSUM: {
                mach_object->prebind_cksum_command = (struct prebind_cksum_command *)command_pointer;
            } break;
            case LC_LOAD_WEAK_DYLIB: {
                mach_object->load_weak_dylib_dylib_command = (struct dylib_command *)command_pointer;
            } break;
            case LC_UUID: {
                mach_object->uuid_command = (struct uuid_command *)command_pointer;
            } break;
            case LC_RPATH: {
                mach_object->rpath_command = (struct rpath_command *)command_pointer;
            } break;
            case LC_CODE_SIGNATURE: {
                mach_object->code_signature_linkedit_data_command = (struct linkedit_data_command *)command_pointer;
            } break;
            case LC_SEGMENT_SPLIT_INFO: {
                mach_object->segment_split_info_linkedit_data_command = (struct linkedit_data_command *)command_pointer;
            } break;
            case LC_REEXPORT_DYLIB: {
                mach_object->reexport_dylib_dylib_command = (struct dylib_command *)command_pointer;
            } break;
            case LC_LAZY_LOAD_DYLIB: {
                ;
            } break;
            case LC_ENCRYPTION_INFO:
            case LC_ENCRYPTION_INFO_64: {
                mach_object->encryption_info_command = (struct encryption_info_command *)command_pointer;
            } break;
            case LC_DYLD_INFO: {
                mach_object->dyld_info_dyld_info_command = (struct dyld_info_command *)command_pointer;
            } break;
            case LC_DYLD_INFO_ONLY: {
                mach_object->dyld_info_only_dyld_info_command = (struct dyld_info_command *)command_pointer;
            } break;
            case LC_LOAD_UPWARD_DYLIB: {
                ;
            } break;
            case LC_VERSION_MIN_MACOSX:
            case LC_VERSION_MIN_IPHONEOS:
            case LC_VERSION_MIN_TVOS:
            case LC_VERSION_MIN_WATCHOS: {
                mach_object->version_min_command = (struct version_min_command *)command_pointer;
            } break;
            case LC_FUNCTION_STARTS: {
                mach_object->function_starts_linkedit_data_command = (struct linkedit_data_command *)command_pointer;
            } break;
            case LC_DYLD_ENVIRONMENT: {
                mach_object->dyld_environment_dylinker_command = (struct dylinker_command *)command_pointer;
            } break;
            case LC_MAIN: {
                mach_object->entry_point_command = (struct entry_point_command *)command_pointer;
            } break;
            case LC_DATA_IN_CODE: {
                mach_object->data_in_code_linkedit_data_command = (struct linkedit_data_command *)command_pointer;
            } break;
            case LC_SOURCE_VERSION: {
                mach_object->source_version_command = (struct source_version_command *)command_pointer;
            } break;
            case LC_DYLIB_CODE_SIGN_DRS: {
                mach_object->dylib_code_sign_drs_linkedit_data_command = (struct linkedit_data_command *)command_pointer;
            } break;
            case LC_LINKER_OPTION: {
                mach_object->linker_option_command = (struct linker_option_command *)command_pointer;
            } break;
            case LC_LINKER_OPTIMIZATION_HINT: {
                mach_object->linker_optimization_hint_linkedit_data_command = (struct linkedit_data_command *)command_pointer;
            } break;
#ifdef LC_NOTE
            case LC_NOTE: {
                ;
            } break;
            case LC_BUILD_VERSION: {
                ;
            } break;
#endif
            default: {
                ;
            } break;
        }
        command_pointer += cmdsize;
    }

    const struct segment_command *linkedit_segment_command = mach_object->linkedit_segment_command;
    if (linkedit_segment_command) {
        uintptr_t linkedit_base = 0;
        if (mach_object->is64 == false) {
            linkedit_base = mach_object->vmaddr_slide + linkedit_segment_command->vmaddr - linkedit_segment_command->fileoff;
        } else {
            linkedit_base = (uintptr_t)(mach_object->vmaddr_slide + ((const struct segment_command_64 *)linkedit_segment_command)->vmaddr - ((const struct segment_command_64 *)linkedit_segment_command)->fileoff);
        }

        if (vmaddr_slide < 0) {
            linkedit_base = (intptr_t)mach_object->header;
        }

        mach_object->linkedit_base = linkedit_base;

        if (mach_object->symtab_command) {
            mach_object->symtab_list = (struct nlist *)(linkedit_base + mach_object->symtab_command->symoff);
            mach_object->symtab_count = mach_object->symtab_command->nsyms;
            mach_object->strtab = (char *)linkedit_base + mach_object->symtab_command->stroff;
            mach_object->strtab_size = mach_object->symtab_command->strsize;
        }
    } else {
        mach_object->linkedit_base = mach_object->vmaddr_slide;
    }

    return true;
}

bool pdl_get_fat_object_with_header(const struct fat_header *header, pdl_fat_object *fat_object) {
    if (header == NULL) {
        return false;
    }

    bool is64 = false;
    bool swaps = false;
    uintptr_t command_pointer = 0;
    switch(header->magic) {
        case FAT_CIGAM:
            swaps = true;
        case FAT_MAGIC:
            command_pointer = (uintptr_t)(header + 1);
            is64 = false;
            break;
        case FAT_CIGAM_64:
            swaps = true;
        case FAT_MAGIC_64:
            command_pointer = (uintptr_t)(((struct mach_header_64 *)header) + 1);
            is64 = true;
            break;
        default:
            return false;
    }

    if (fat_object == NULL) {
        return true;
    }

    memset(fat_object, 0, sizeof(*fat_object));

    fat_object->is64 = is64;
    fat_object->swaps = swaps;
    fat_object->header = header;
    fat_object->arch_count = swaps ? ntohl(header->nfat_arch) : header->nfat_arch;
    fat_object->arch_list = (struct fat_arch *)command_pointer;

    return true;
}
