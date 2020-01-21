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

#ifdef __cplusplus
}
#endif
