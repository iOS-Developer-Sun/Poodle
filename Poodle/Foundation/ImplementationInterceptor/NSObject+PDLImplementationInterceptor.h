//
//  NSObject+PDLImplementationInterceptor.h
//  Poodle
//
//  Created by Poodle on 2017/11/4.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>

struct PDLImplementationInterceptorData {
    // copied from struct objc_method in <objc/runtime.h>
    SEL method_name;
    char *method_types;
    IMP method_imp;
    // end comment
    Class method_class;
};

#define PDLImplementationInterceptorRecover(_cmd) \
char *_types = ((struct PDLImplementationInterceptorData *)(void *)_cmd)->method_types;(void)_types;\
IMP _imp = ((struct PDLImplementationInterceptorData *)(void *)_cmd)->method_imp;(void)_imp;\
__unsafe_unretained Class _class = ((struct PDLImplementationInterceptorData *)(void *)_cmd)->method_class;(void)_class;\
_cmd = ((struct PDLImplementationInterceptorData *)(void *)_cmd)->method_name

@interface NSObject (PDLImplementationInterceptor)

+ (BOOL)pdl_interceptSelector:(SEL)selector withInterceptorImplementation:(IMP)interceptorImplementation;
+ (BOOL)pdl_interceptSelector:(SEL)selector withInterceptorImplementation:(IMP)interceptorImplementation isStructRet:(BOOL)isStructRet addIfNotExistent:(BOOL)addIfNotExistent;

+ (NSUInteger)interceptClusterSelector:(SEL)selector withInterceptorImplementation:(IMP)interceptorImplementation;
+ (NSUInteger)interceptClusterSelector:(SEL)selector withInterceptorImplementation:(IMP)interceptorImplementation isStructRet:(BOOL)isStructRet;

@end

