//
//  PDLNonThreadSafeClusterObserver.h
//  Poodle
//
//  Created by Poodle on 2023/6/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDLNonThreadSafeClusterObserverLogData : NSObject

@property (nonatomic, strong) Class clusterClass;
@property (nonatomic, assign) BOOL isExclusive;
@property (nonatomic, assign) BOOL isSetter;

@end

extern void PDLNonThreadSafeClusterObserverLogBegin(__unsafe_unretained id self, Class aClass, SEL sel, void *data);
extern void PDLNonThreadSafeClusterObserverLogEnd(__unsafe_unretained id self, Class aClass, SEL sel, void *data);
extern void PDLNonThreadSafeClusterObserverRegister(__unsafe_unretained id object, void *data);

#pragma mark - log

#define PDLNonThreadSafeClusterObserverDeclLogImp(FUNC_NAME) \
static void *FUNC_NAME(__unsafe_unretained id self, SEL _cmd) {\
    PDLImplementationInterceptorRecover(_cmd);\
    PDLNonThreadSafeClusterObserverLogBegin(self, _class, _cmd, _data);\
    void *ret = NULL;\
    if (_imp) {\
        ret = ((typeof(&FUNC_NAME))_imp)(self, _cmd);\
    } else {\
        _imp = &objc_msgSendSuper;\
        struct objc_super su = {self, class_getSuperclass(_class)};\
        ret = ((typeof(&FUNC_NAME))_imp)((__bridge typeof(self))&su, _cmd);\
    }\
    PDLNonThreadSafeClusterObserverLogEnd(self, _class, _cmd, _data);\
    return ret;\
}

#define PDLNonThreadSafeClusterObserverDeclLogImp1(FUNC_NAME, TYPE1) \
static void *FUNC_NAME(__unsafe_unretained id self, SEL _cmd, TYPE1 a1) {\
    PDLImplementationInterceptorRecover(_cmd);\
    PDLNonThreadSafeClusterObserverLogBegin(self, _class, _cmd, _data);\
    void *ret = NULL;\
    if (_imp) {\
        ret = ((typeof(&FUNC_NAME))_imp)(self, _cmd, a1);\
    } else {\
        _imp = &objc_msgSendSuper;\
        struct objc_super su = {self, class_getSuperclass(_class)};\
        ret = ((typeof(&FUNC_NAME))_imp)((__bridge typeof(self))&su, _cmd, a1);\
    }\
    PDLNonThreadSafeClusterObserverLogEnd(self, _class, _cmd, _data);\
    return ret;\
}

#define PDLNonThreadSafeClusterObserverDeclLogImp2(FUNC_NAME, TYPE1, TYPE2) \
static void *FUNC_NAME(__unsafe_unretained id self, SEL _cmd, TYPE1 a1, TYPE2 a2) {\
    PDLImplementationInterceptorRecover(_cmd);\
    PDLNonThreadSafeClusterObserverLogBegin(self, _class, _cmd, _data);\
    void *ret = NULL;\
    if (_imp) {\
        ret = ((typeof(&FUNC_NAME))_imp)(self, _cmd, a1, a2);\
    } else {\
        _imp = &objc_msgSendSuper;\
        struct objc_super su = {self, class_getSuperclass(_class)};\
        ret = ((typeof(&FUNC_NAME))_imp)((__bridge typeof(self))&su, _cmd, a1, a2);\
    }\
    PDLNonThreadSafeClusterObserverLogEnd(self, _class, _cmd, _data);\
    return ret;\
}

#define PDLNonThreadSafeClusterObserverDeclLogImp3(FUNC_NAME, TYPE1, TYPE2, TYPE3) \
static void *FUNC_NAME(__unsafe_unretained id self, SEL _cmd, TYPE1 a1, TYPE2 a2, TYPE3 a3) {\
    PDLImplementationInterceptorRecover(_cmd);\
    PDLNonThreadSafeClusterObserverLogBegin(self, _class, _cmd, _data);\
    void *ret = NULL;\
    if (_imp) {\
        ret = ((typeof(&FUNC_NAME))_imp)(self, _cmd, a1, a2, a3);\
    } else {\
        _imp = &objc_msgSendSuper;\
        struct objc_super su = {self, class_getSuperclass(_class)};\
        ret = ((typeof(&FUNC_NAME))_imp)((__bridge typeof(self))&su, _cmd, a1, a2, a3);\
    }\
    PDLNonThreadSafeClusterObserverLogEnd(self, _class, _cmd, _data);\
    return ret;\
}

#define PDLNonThreadSafeClusterObserverDeclLogImp4(FUNC_NAME, TYPE1, TYPE2, TYPE3, TYPE4) \
static void *FUNC_NAME(__unsafe_unretained id self, SEL _cmd, TYPE1 a1, TYPE2 a2, TYPE3 a3, TYPE4 a4) {\
    PDLImplementationInterceptorRecover(_cmd);\
    PDLNonThreadSafeClusterObserverLogBegin(self, _class, _cmd, _data);\
    void *ret = NULL;\
    if (_imp) {\
        ret = ((typeof(&FUNC_NAME))_imp)(self, _cmd, a1, a2, a3, a4);\
    } else {\
        _imp = &objc_msgSendSuper;\
        struct objc_super su = {self, class_getSuperclass(_class)};\
        ret = ((typeof(&FUNC_NAME))_imp)((__bridge typeof(self))&su, _cmd, a1, a2, a3, a4);\
    }\
    PDLNonThreadSafeClusterObserverLogEnd(self, _class, _cmd, _data);\
    return ret;\
}

#pragma mark - register

#define PDLNonThreadSafeClusterObserverDeclRegisterImp(FUNC_NAME) \
static id FUNC_NAME(__unsafe_unretained id self, SEL _cmd) {\
    PDLImplementationInterceptorRecover(_cmd);\
    id object = ((typeof(&FUNC_NAME))_imp)(self, _cmd);\
    PDLNonThreadSafeClusterObserverRegister(object, _data);\
    return object;\
}

#define PDLNonThreadSafeClusterObserverDeclRegisterImp1(FUNC_NAME, TYPE1) \
static id FUNC_NAME(__unsafe_unretained id self, SEL _cmd, TYPE1 a1) {\
    PDLImplementationInterceptorRecover(_cmd);\
    id object = ((typeof(&FUNC_NAME))_imp)(self, _cmd, a1);\
    PDLNonThreadSafeClusterObserverRegister(object, _data);\
    return object;\
}

#define PDLNonThreadSafeClusterObserverDeclRegisterImp2(FUNC_NAME, TYPE1, TYPE2) \
static id FUNC_NAME(__unsafe_unretained id self, SEL _cmd, TYPE1 a1, TYPE2 a2) {\
    PDLImplementationInterceptorRecover(_cmd);\
    id object = ((typeof(&FUNC_NAME))_imp)(self, _cmd, a1, a2);\
    PDLNonThreadSafeClusterObserverRegister(object, _data);\
    return object;\
}

#define PDLNonThreadSafeClusterObserverDeclRegisterImp3(FUNC_NAME, TYPE1, TYPE2, TYPE3) \
static id FUNC_NAME(__unsafe_unretained id self, SEL _cmd, TYPE1 a1, TYPE2 a2, TYPE3 a3) {\
    PDLImplementationInterceptorRecover(_cmd);\
    id object = ((typeof(&FUNC_NAME))_imp)(self, _cmd, a1, a2, a3);\
    PDLNonThreadSafeClusterObserverRegister(object, _data);\
    return object;\
}

