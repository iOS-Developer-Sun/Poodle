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
    size_t size = 0;
#if TARGET_IPHONE_SIMULATOR
    if (b->impl.Flags & 0x16u) {
        size = b->Desc.size->Block_size;
    } else {
        size = b->Desc.object->Block_size;
    }
#else
    size = b->Desc.object->Block_size;
#endif
    return size - sizeof(pdl_block);
}
