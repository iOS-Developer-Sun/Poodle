//
//  pdl_systemcall.c
//  Poodle
//
//  Created by Poodle on 2019/5/10.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include <unistd.h>
#include <dlfcn.h>
#include <assert.h>
#include <sys/syscall.h>
#include <string.h>
#include "pdl_systemcall.h"

#define ATTRIBUTE_VISIBILITY_HIDDEN __attribute__((visibility("hidden")))

#ifdef __LP64__
typedef unsigned __int128 cerror_return_t;
#else
typedef uint64_t cerror_return_t;
#endif

ATTRIBUTE_VISIBILITY_HIDDEN
cerror_return_t pdl_systemcall_cerror(int err) {
    cerror_return_t ret = -1;
    static cerror_return_t (*cerror_ptr)(int) = NULL;
    if (cerror_ptr == NULL) {
        void *handle = dlopen(NULL, RTLD_GLOBAL | RTLD_NOW);
        if (handle) {
            volatile char symbol[7] = {0};
            symbol[0] = 'c';
            symbol[1] = 'e';
            symbol[2] = 'r';
            symbol[3] = 'r';
            symbol[4] = 'o';
            symbol[5] = 'r';
            symbol[6] = '\0';
#ifdef DEBUG
            assert(strcmp((const char *)symbol, "cerror") == 0);
#endif
            cerror_ptr = dlsym(handle, (const char *)symbol);
            dlclose(handle);
        }
    }
    if (cerror_ptr) {
        ret = cerror_ptr(err);
    }
    return ret;
}

#pragma mark - public functions

ATTRIBUTE_VISIBILITY_HIDDEN
int pdl_systemcall_ptrace(int type, int a2, int a3, int a4) {
    return pdl_systemcall(SYS_ptrace, type, a2, a3, a4);
}

ATTRIBUTE_VISIBILITY_HIDDEN
int pdl_systemcall_exit(int status) {
    return pdl_systemcall(SYS_exit, status);
}

ATTRIBUTE_VISIBILITY_HIDDEN
pid_t pdl_systemcall_getpid(void) {
    return pdl_systemcall(SYS_getpid);
}

ATTRIBUTE_VISIBILITY_HIDDEN
int pdl_systemcall_sysctl(int *a1, u_int a2, void *a3, size_t *a4, void *a5, size_t a6) {
    return pdl_systemcall(SYS_sysctl, a1, a2, a3, a4, a5, a6);
}
