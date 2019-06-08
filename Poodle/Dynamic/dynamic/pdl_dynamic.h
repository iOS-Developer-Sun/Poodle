//
//  pdl_dynamic.h
//  Poodle
//
//  Created by Poodle on 2019/6/8.
//
//

#define PDL_DYLD_INTERPOSE(_replacement,_replacee) \
__attribute__((used)) static struct{ const void* replacement; const void* replacee; } _pdl_dyld_interpose_##_replacee \
__attribute__ ((section ("__DATA,__interpose"))) = { (const void*)(unsigned long)&_replacement, (const void*)(unsigned long)&_replacee };
