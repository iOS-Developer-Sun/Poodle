//
//  pdl_systemcall.h
//  Poodle
//
//  Created by Poodle on 2019/5/10.
//
//

#include <sys/syscall.h>

extern int pdl_systemcall(int, ...);

extern int pdl_systemcall_ptrace(int, int, int, int);
extern int pdl_systemcall_exit(int);
