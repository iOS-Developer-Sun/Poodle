//
//  pdl_security.c
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_security.h"
#include <sys/sysctl.h>
#include "pdl_systemcall.h"
#include "pdl_die.h"

__attribute__((visibility("hidden")))
bool pdl_anti_re(void) {
    bool ret = false;
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    int name[4];
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = pdl_systemcall_getpid();
    if ((pdl_systemcall_sysctl(name, 4, &info, &info_size, NULL, 0) != -1) && ((info.kp_proc.p_flag & P_TRACED) != 0)) {
        pdl_die(PDL_ANTI_RE_DIE_CODE_TRACED);
    }

    pdl_systemcall_ptrace(31, 0, 0, 0); // PT_DENY_ATTACH

    char dydl_insert_libraries_string[22] = {0};
    dydl_insert_libraries_string[0] = 'D';
    dydl_insert_libraries_string[1] = 'Y';
    dydl_insert_libraries_string[2] = 'L';
    dydl_insert_libraries_string[3] = 'D';
    dydl_insert_libraries_string[4] = '_';
    dydl_insert_libraries_string[5] = 'I';
    dydl_insert_libraries_string[6] = 'N';
    dydl_insert_libraries_string[7] = 'S';
    dydl_insert_libraries_string[8] = 'E';
    dydl_insert_libraries_string[9] = 'R';
    dydl_insert_libraries_string[10] = 'T';
    dydl_insert_libraries_string[11] = '_';
    dydl_insert_libraries_string[12] = 'L';
    dydl_insert_libraries_string[13] = 'I';
    dydl_insert_libraries_string[14] = 'B';
    dydl_insert_libraries_string[15] = 'R';
    dydl_insert_libraries_string[16] = 'A';
    dydl_insert_libraries_string[17] = 'R';
    dydl_insert_libraries_string[18] = 'I';
    dydl_insert_libraries_string[19] = 'E';
    dydl_insert_libraries_string[20] = 'S';
    dydl_insert_libraries_string[21] = '\0';
    char *libs = getenv(dydl_insert_libraries_string);
    if (libs && (libs[0] != '\0')) {
        pdl_die(PDL_ANTI_RE_DIE_CODE_INSERTED_LIBRARIES);
    }
    ret = true;
    return ret;
}

__attribute__((visibility("hidden")))
bool pdl_is_tracing(void) {
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    int name[4];
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = pdl_systemcall_getpid();
    bool ret = (pdl_systemcall_sysctl(name, 4, &info, &info_size, NULL, 0) != -1) && ((info.kp_proc.p_flag & P_TRACED) != 0);
    return ret;
}
