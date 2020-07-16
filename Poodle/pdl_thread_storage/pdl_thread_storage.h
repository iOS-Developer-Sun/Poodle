//
//  pdl_thread_storage.h
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

extern bool pdl_thread_storage_enabled(void);
extern void pdl_thread_storage_register(void *key, void(*destructor)(void *));
extern void **pdl_thread_storage_get(void *key);
extern void pdl_thread_storage_set(void *key, void *value);

#ifdef __cplusplus
}
#endif
