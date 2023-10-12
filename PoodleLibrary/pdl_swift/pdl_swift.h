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

extern void *pdl_swift_get_object(void);
extern void *pdl_swift_validate_object(void *address);

extern bool pdl_swift_registerAllocAction(void(*action)(void *cls, size_t requiredSize, size_t requiredAlignmentMask, void *ret));
extern bool pdl_swift_registerAccessBeginAction(void(*action)(void *address, void **result, int8_t flags, int64_t reserved, void *ret));
extern bool pdl_swift_registerAccessEndAction(void(*action)(void **result, void *ret));

extern bool pdl_swift_registerDictionaryGetterAction(void(*action)(void **value, void **key, void **meta, void *a, void *b, void *c, void *object));
extern bool pdl_swift_registerDictionarySetterAction(void(*action)(void **value, void **key, void **meta, void *object));

typedef struct {
    void **a;
    void **b;
} pdl_swift_dictionary_modify_ret;
extern bool pdl_swift_registerDictionaryModifyAction(void(*action)(void **value, void **key, void **meta, pdl_swift_dictionary_modify_ret ret, void *object));

#ifdef __cplusplus
}
#endif
