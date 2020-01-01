//
//  NSObject+PDLSelectorProxy.h
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SelectorProxy)

- (BOOL)pdl_setSelectorProxyForSelector:(SEL)selector withImplementation:(IMP)implemetation;
- (BOOL)pdl_setSelectorProxyForSelector:(SEL)selector withImplementation:(IMP)implemetation isStructRet:(BOOL)isStructRet;

- (IMP)pdl_selectorProxyImplementationForSelector:(SEL)selector;

@end
