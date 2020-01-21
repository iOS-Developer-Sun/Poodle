//
//  NSObject+PDLExtension.h
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PDLExtension)

+ (void)pdl_swizzleSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector;
+ (void)pdl_swizzleSelector:(SEL)originalSelector withClass:(Class)swizzledClass selector:(SEL)swizzledSelector;
+ (IMP)pdl_setProxyClass:(Class)proxyClass forSelector:(SEL)selector;
+ (IMP)pdl_setProxyClass:(Class)proxyClass proxySelector:(SEL)proxySelector forSelector:(SEL)originalSelector;

+ (ptrdiff_t)pdl_ivarOffsetForName:(char *)name;

@end
