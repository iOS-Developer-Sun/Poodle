//
//  PDLObjectLockItem.h
//  Poodle
//
//  Created by Poodle on 10/10/23.
//  Copyright © 2023 Poodle. All rights reserved.
//

#import "PDLLockItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLObjectLockItem : PDLLockItem

@property (nonatomic, weak) id object;

+ (instancetype)lockItemWithObject:(id)object;

@end

NS_ASSUME_NONNULL_END
