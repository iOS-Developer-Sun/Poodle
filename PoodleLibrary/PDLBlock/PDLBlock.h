//
//  PDLBlock.h
//  Poodle
//
//  Created by Poodle on 2021/2/3.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern BOOL PDLBlockCopying(void);
extern BOOL PDLBlockCopyRecordEnable(void);

@interface NSObject (PDLBlock)

+ (BOOL)pdl_enableBlockCheck:(void(^)(void *))callback;

@end

NS_ASSUME_NONNULL_END
