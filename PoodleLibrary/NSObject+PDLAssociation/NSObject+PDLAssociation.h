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

@property (nonatomic, strong, setter=pdl_setNonatomicStrongAssociatedObject:) id _Nullable pdl_nonatomicStrongAssociatedObject;
@property (atomic, strong, setter=pdl_setStrongAssociatedObject:) id _Nullable pdl_strongAssociatedObject;

@property (nonatomic, copy, setter=pdl_setNonatomicCopyAssociatedObject:) id _Nullable pdl_nonatomicCopyAssociatedObject;
@property (atomic, copy, setter=pdl_setCopyAssociatedObject:) id _Nullable pdl_copyAssociatedObject;

@property (unsafe_unretained, setter=pdl_setUnsafeUnretainedAssociatedObject:) id _Nullable pdl_unsafeUnretainedAssociatedObject;

- (id _Nullable)pdl_associatedObjectForKey:(void *)key;
- (void)pdl_setAssociatedObject:(id _Nullable)object forKey:(void *)key policy:(objc_AssociationPolicy)policy;

#pragma mark - weak

@property (nonatomic, weak, setter=pdl_setNonatomicWeakAssociatedObject:) id _Nullable pdl_nonatomicWeakAssociatedObject;
@property (atomic, weak, setter=pdl_setWeakAssociatedObject:) id _Nullable pdl_weakAssociatedObject;

- (id _Nullable)pdl_nonatomicWeakAssociatedObjectForKey:(void *)key;
- (void)pdl_setNonatomicWeakAssociatedObject:(id _Nullable)object forKey:(void *)key;
- (id _Nullable)pdl_weakAssociatedObjectForKey:(void *)key;
- (void)pdl_setWeakAssociatedObject:(id _Nullable)object forKey:(void *)key;

@end

NS_ASSUME_NONNULL_END
