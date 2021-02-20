//
//  PDLBlock.h
//  Poodle
//
//  Created by Poodle on 2021/2/3.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "pdl_array.h"

NS_ASSUME_NONNULL_BEGIN

extern BOOL PDLBlockCopying(void);
extern pdl_array_t PDLBlockCopyingBlocks(void);

extern BOOL PDLBlockCopyRecordEnable(BOOL(*_Nullable filter)(void *block));

@interface NSObject (PDLBlock)

+ (BOOL)pdl_enableBlockCheck:(void(^)(void *object, void *block))callback;

@end

NS_ASSUME_NONNULL_END
