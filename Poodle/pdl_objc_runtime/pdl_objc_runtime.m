//
//  pdl_objc_runtime.m
//  Poodle
//
//  Created by Poodle on 2020/6/18.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "pdl_objc_runtime.h"

__attribute__((ns_returns_retained))
id pdl_class_createInstance(__unsafe_unretained Class cls, size_t extraBytes, __attribute__((ns_returns_retained)) id(* class_createInstance_original)(__unsafe_unretained Class cls, size_t extraBytes)) {
    return class_createInstance_original(cls, extraBytes);
}

__attribute__((ns_returns_retained))
id pdl_objc_rootAllocWithZone(__unsafe_unretained Class cls, struct _NSZone *zone, id(* _objc_rootAllocWithZone_original)(__unsafe_unretained Class cls, struct _NSZone *zone)) {
    return _objc_rootAllocWithZone_original(cls, zone);
}

void pdl_objc_rootDealloc(__unsafe_unretained id object, void(* _objc_rootDealloc_original)(__unsafe_unretained id object)) {
    _objc_rootDealloc_original(object);
}
