//
//  pdl_block.m
//  Poodle
//
//  Created by Poodle on 2021/2/3.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "pdl_block.h"

size_t pdl_block_extra_size(void *block) {
    pdl_block *b = (void *)block;
    return b->Desc->Block_size - sizeof(pdl_block);
}
