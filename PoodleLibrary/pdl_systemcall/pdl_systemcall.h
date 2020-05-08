//
//  pdl_systemcall.h
//  Poodle
//
//  Created by Poodle on 2019/5/10.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include <sys/syscall.h>

#ifdef __cplusplus
extern "C" {
#endif

extern int pdl_systemcall(int, ...);

extern int pdl_systemcall_ptrace(int, int, int, int);
extern int pdl_systemcall_exit(int);
extern pid_t pdl_systemcall_getpid(void);
extern int pdl_systemcall_sysctl(int *, u_int, void *, size_t *, void *, size_t);

#ifdef __cplusplus
}
#endif
