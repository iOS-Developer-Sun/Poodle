//
//  PDLBacktrace.h
//  Poodle
//
//  Created by Poodle on 2020/6/1.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLBacktrace : NSObject

@property (atomic, copy) NSString *name;
@property (readonly) BOOL isShown;
@property (readonly) NSArray <NSNumber *>*frames;

- (void)record;
- (void)record:(unsigned int)hiddenCount;
- (void)show;
- (void)showWithoutWaiting;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
