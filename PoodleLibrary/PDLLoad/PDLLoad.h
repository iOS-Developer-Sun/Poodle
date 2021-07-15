//
//  PDLLoad.h
//  Poodle
//
//  Created by Poodle on 2020/12/22.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <objc/runtime.h>

#ifdef __cplusplus
extern "C" {
#endif

extern void pdl_disableCategoryLoad(void *image_header, bool(*filter)(Class cls, const char *category_name));

#ifdef __cplusplus
}
#endif
