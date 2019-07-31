//
//  pdl_utils.h
//  Poodle
//
//  Created by Poodle on 2016/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#ifndef PDL_PROGRESS
#define PDL_PROGRESS(progress, from, to) ({__typeof__(progress) __p = (progress);__typeof__(from) __f = (from); __typeof__(to) __t = (to); ((__f) + ((__t) - (__f)) * (__p));})
#endif

#ifdef __cplusplus
}
#endif
