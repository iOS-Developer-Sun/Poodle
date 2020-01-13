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
    void *data;
};

#define PDLImplementationInterceptorRecover(_cmd) \
__unused char *_types = ((struct PDLImplementationInterceptorData *)(void *)_cmd)->method_types;\
__unused IMP _imp = ((struct PDLImplementationInterceptorData *)(void *)_cmd)->method_imp;\
__unused __unsafe_unretained Class _class = ((struct PDLImplementationInterceptorData *)(void *)_cmd)->method_class;\
__unused void *_data = ((struct PDLImplementationInterceptorData *)(void *)_cmd)->data;\
_cmd = ((struct PDLImplementationInterceptorData *)(void *)_cmd)->method_name

#ifdef __OBJC__

@interface NSObject (PDLImplementationInterceptor)

+ (BOOL)pdl_interceptSelector:(SEL)selector withInterceptorImplementation:(IMP)interceptorImplementation;
+ (BOOL)pdl_interceptSelector:(SEL)selector withInterceptorImplementation:(IMP)interceptorImplementation isStructRet:(BOOL)isStructRet addIfNotExistent:(BOOL)addIfNotExistent data:(void *)data;

+ (NSUInteger)pdl_interceptClusterSelector:(SEL)selector withInterceptorImplementation:(IMP)interceptorImplementation;
+ (NSUInteger)pdl_interceptClusterSelector:(SEL)selector withInterceptorImplementation:(IMP)interceptorImplementation isStructRet:(BOOL)isStructRet data:(void *)data;

@end

#endif

#ifdef __cplusplus
extern "C" {
#endif

extern BOOL pdl_interceptSelector(Class aClass, SEL selector, IMP interceptorImplementation, NSNumber *isStructRetNumber, BOOL addIfNotExistent, void *data);
extern NSUInteger pdl_interceptClusterSelector(Class aClass, SEL selector, IMP interceptorImplementation, NSNumber *isStructRetNumber, void *data);

#ifdef __cplusplus
}
#endif
