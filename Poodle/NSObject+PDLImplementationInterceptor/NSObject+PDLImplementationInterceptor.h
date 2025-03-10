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
+ (BOOL)pdl_interceptSelector:(SEL)selector withInterceptorImplementation:(IMP)interceptorImplementation isStructRet:(NSNumber *)isStructRet addIfNotExistent:(BOOL)addIfNotExistent data:(void *)data;

+ (NSUInteger)pdl_interceptClusterSelector:(SEL)selector withInterceptorImplementation:(IMP)interceptorImplementation;
+ (NSUInteger)pdl_interceptClusterSelector:(SEL)selector withInterceptorImplementation:(IMP)interceptorImplementation isStructRet:(NSNumber *)isStructRet addIfNotExistent:(BOOL)addIfNotExistent data:(void *)data;

@end

#endif

#ifdef __cplusplus
extern "C" {
#endif

extern BOOL pdl_interceptSelector(Class aClass, SEL selector, IMP interceptorImplementation, NSNumber *isStructRetNumber, BOOL addIfNotExistent, void *data);
extern BOOL pdl_intercept(Class aClass, SEL selector, NSNumber *isStructRetNumber, IMP(^interceptor)(BOOL exists, NSNumber **isStructRetNumber, Method method, void **data));
extern BOOL pdl_interceptMethod(Class aClass, Method method, NSNumber *isStructRetNumber, IMP(^interceptor)(NSNumber **isStructRetNumber, void **data));

extern NSUInteger pdl_interceptClusterSelector(Class aClass, SEL selector, IMP interceptorImplementation, NSNumber *isStructRetNumber, BOOL addIfNotExistent, void *data);
extern NSUInteger pdl_interceptCluster(Class aClass, SEL selector, NSNumber *isStructRetNumber, IMP(^interceptor)(Class aClass, BOOL exists, NSNumber **isStructRetNumber, Method method, void **data));

/*

 struct objc_super su = {self, class_getSuperclass(object_getClass(self))};
 void(*msgSendSuper)(struct objc_super *, SEL) = (void(*)(struct objc_super *, SEL))objc_msgSendSuper;
 msgSendSuper(&su, _cmd);

 */

extern Class pdl_subclass(Class superclass, const char *className, Class targetClass);

#ifdef __cplusplus
}
#endif
