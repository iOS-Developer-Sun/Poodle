//
//  PDLMachObject.h
//  Poodle
//
//  Created by Poodle on 2019/8/1.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void * PDLMachObjectAddress;

@interface PDLMachObject : NSObject

+ (instancetype)executable;
- (instancetype)initWithPath:(NSString *)path;

- (PDLMachObjectAddress _Nonnull * _Nullable)classList:(size_t *)count;

- (const char *)className:(PDLMachObjectAddress)cls;
- (PDLMachObjectAddress)instanceMethodList:(PDLMachObjectAddress)cls;
- (PDLMachObjectAddress)classMethodList:(PDLMachObjectAddress)cls;
- (void)enumerateMethodList:(PDLMachObjectAddress)methodList action:(void(^)(const char *name, const char *type, intptr_t impOffset))action;

@end

NS_ASSUME_NONNULL_END
