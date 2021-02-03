//
//  pdl_block.h
//  Poodle
//
//  Created by Poodle on 2021/2/3.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
    char data[0];
} pdl_block;

extern size_t pdl_block_extra_size(id block);

NS_ASSUME_NONNULL_END
