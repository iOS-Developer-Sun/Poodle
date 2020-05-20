//
//  pdl_malloc_zone.h
//  Poodle
//
//  Created by Poodle on 2020/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include <malloc/malloc.h>

extern malloc_zone_t *pdl_malloc_zone(void);
extern void pdl_malloc_trace(void);
