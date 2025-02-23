//
//  PDLFileObserver.h
//  Poodle
//
//  Created by Poodle on 23/2/25.
//  Copyright © 2025 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLFileObserver : NSObject

@property (nonatomic, copy, readonly) NSString *filePath;
@property (nonatomic, assign, readonly) BOOL isObserving;

- (instancetype)initWithFilePath:(NSString *)filePath;

- (BOOL)startObserving:(void(^)(uintptr_t flags))action;
- (void)stopObserving;

@end

NS_ASSUME_NONNULL_END
