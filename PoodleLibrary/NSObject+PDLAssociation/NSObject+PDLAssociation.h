//
//  NSObject+PDLAssociation.h
//  Poodle
//
//  Created by Poodle on 2020/6/8.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (PDLAssociation)

- (id _Nullable)pdl_associatedObjectForKey:(const void *)key;
- (void)pdl_setAssociatedObject:(id _Nullable)object forKey:(const void *)key policy:(objc_AssociationPolicy)policy;

- (id _Nullable)pdl_nonatomicWeakAssociatedObjectForKey:(const void *)key;
- (void)pdl_setNonatomicWeakAssociatedObject:(id _Nullable)object forKey:(const void *)key;

- (id _Nullable)pdl_weakAssociatedObjectForKey:(const void *)key;
- (void)pdl_setWeakAssociatedObject:(id _Nullable)object forKey:(const void *)key;

@end

NS_ASSUME_NONNULL_END
