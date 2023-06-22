//
//  PDLNonThreadSafeObserverObject.h
//  Poodle
//
//  Created by Poodle on 2021/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafeObserverObject : NSObject

- (instancetype)initWithObject:(id)object;

+ (void)registerObject:(id _Nullable)object;
+ (instancetype)observerObjectForObject:(id)object;

- (BOOL)checkInitializing;

- (BOOL)startRecording;
- (void)finishRecording;

@end

NS_ASSUME_NONNULL_END
