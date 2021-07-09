//
//  pdl_zombie.h
//  Poodle
//
//  Created by Poodle on 2021/7/9.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern unsigned int pdl_zombie_duration(void);
extern void pdl_zombie_set_zombie_duration(unsigned int zombie_duration);
extern bool pdl_zombie_is_zombie(__unsafe_unretained id object);
extern bool pdl_zombie_enable(bool(*filter)(__unsafe_unretained id object));

NS_ASSUME_NONNULL_END
