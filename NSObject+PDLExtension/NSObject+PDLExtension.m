//
//  NSObject+PDLExtension.m
//  Poodle
//
//  Created by Sun on 14-6-26.
//
//

#import "NSObject+PDLExtension.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (PDLExtension)

+ (void)pdl_swizzleSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector {
    [self pdl_swizzleSelector:originalSelector withClass:self selector:swizzledSelector];
}

+ (void)pdl_swizzleSelector:(SEL)originalSelector withClass:(Class)swizzledClass selector:(SEL)swizzledSelector {
    Class aClass = self;
    Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    BOOL didAddMethod = class_addMethod(aClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(aClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (IMP)pdl_setProxyClass:(Class)proxyClass forSelector:(SEL)selector {
    return [self pdl_setProxyClass:proxyClass proxySelector:selector forSelector:selector];
}

+ (IMP)pdl_setProxyClass:(Class)proxyClass proxySelector:(SEL)proxySelector forSelector:(SEL)originalSelector {
    Method proxyMethod = class_getInstanceMethod(proxyClass, proxySelector);
    return class_replaceMethod(self, originalSelector, method_getImplementation(proxyMethod), method_getTypeEncoding(proxyMethod));
}

+ (ptrdiff_t)pdl_ivarOffsetForName:(char *)name {
    Ivar ivar = class_getInstanceVariable(self, name);
    if (ivar == NULL) {
        return -1;
    }

    ptrdiff_t offset = ivar_getOffset(ivar);
    return offset;
}

@end
