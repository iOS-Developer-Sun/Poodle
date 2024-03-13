//
//  pdl_zombie.h
//  Poodle
//
//  Created by Poodle on 2021/7/9.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

extern BOOL pdl_zombie_enable(BOOL(*filter)(__unsafe_unretained id object));
extern BOOL pdl_zombie_object_enabled(__unsafe_unretained id object);
extern void pdl_zombie_set_object_enabled(__unsafe_unretained id object, BOOL enabled);
extern NSTimeInterval pdl_zombie_object_duration(__unsafe_unretained id object);
extern void pdl_zombie_set_object_duration(__unsafe_unretained id object, NSTimeInterval duration);
extern BOOL pdl_zombie_object_is_zombie(__unsafe_unretained id object);
extern void pdl_zombie_free_object(__unsafe_unretained id object);

#ifdef __cplusplus
}
#endif
