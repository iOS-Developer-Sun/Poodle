//
//  pdl_swift.h
//  Poodle
//
//  Created by Poodle on 23-10-05.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

extern bool pdl_swift_registerAllocAction(void(*action)(void *cls, size_t requiredSize, size_t requiredAlignmentMask, void *result));
extern bool pdl_swift_registerAccessBeginAction(void(*action)(void *address, void **result, int8_t flags, int64_t reserved, void *ret));
extern bool pdl_swift_registerAccessEndAction(void(*action)(void **result, void *ret));

#ifdef __cplusplus
}
#endif
