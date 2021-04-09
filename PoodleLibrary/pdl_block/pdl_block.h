//
//  pdl_block.h
//  Poodle
//
//  Created by Poodle on 2021/2/3.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef union {
    char c[0];
    short s[0];
    int i[0];
    long l[0];
    float f[0];
    double d[0];
    void *_Nullable p[0];
} pdl_block_data;

_Static_assert(sizeof(pdl_block_data) == 0, "");

typedef struct pdl_block_byref {
    void *__isa;
    struct pdl_block_byref *__forwarding;
    int __flags;
    int __size;
    pdl_block_data data;
} pdl_block_byref;

typedef struct {
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;
} pdl_block_impl;

typedef struct {
    size_t reserved;
    size_t Block_size;
    void (*copy)(pdl_block_impl *, pdl_block_impl *);
    void (*dispose)(pdl_block_impl *);
    const char *signature;
} pdl_block_desc;

typedef struct {
    pdl_block_impl impl;
    pdl_block_desc *Desc;
    pdl_block_data data;
} pdl_block;

extern size_t pdl_block_extra_size(void *block);

NS_ASSUME_NONNULL_END
