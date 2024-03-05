//
//  PDLMachObject.h
//  Poodle
//
//  Created by Poodle on 2019/8/1.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "pdl_mach_object.h"

NS_ASSUME_NONNULL_BEGIN

typedef void * PDLMachObjectAddress;

typedef NS_ENUM(NSUInteger, PDLSwiftMethodKind) {
    PDLSwiftMethodKindMethod,
    PDLSwiftMethodKindInit,
    PDLSwiftMethodKindGetter,
    PDLSwiftMethodKindSetter,
    PDLSwiftMethodKindModifyCoroutine,
    PDLSwiftMethodKindReadCoroutine,
    PDLSwiftMethodKindAccess,
};

@interface PDLMachObject : NSObject

@property (nonatomic, assign, readonly) pdl_mach_object_t *object;

- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithPath:(NSString *)path;

- (uintptr_t)mainOffset;

- (uint32_t)constructorsCount;
- (uintptr_t)constructorOffset:(uint32_t)index;

- (PDLMachObjectAddress _Nonnull * _Nullable)classList:(size_t *)count;
- (const char *)className:(PDLMachObjectAddress)cls;
- (PDLMachObjectAddress)instanceMethodList:(PDLMachObjectAddress)cls;
- (PDLMachObjectAddress)classMethodList:(PDLMachObjectAddress)cls;

- (PDLMachObjectAddress _Nonnull * _Nullable)categoryList:(size_t *)count;
- (const char *)categoryName:(PDLMachObjectAddress)cat;
- (const char *)categoryClassName:(PDLMachObjectAddress)cat;
- (PDLMachObjectAddress)categoryInstanceMethodList:(PDLMachObjectAddress)cat;
- (PDLMachObjectAddress)categoryClassMethodList:(PDLMachObjectAddress)cat;

- (uint32_t)methodCount:(PDLMachObjectAddress)methodList;
- (void)enumerateMethodList:(PDLMachObjectAddress)methodList action:(void(^)(const char *name, const char *type, intptr_t impOffset))action;

- (void)enumerateSwiftTypes:(void(^)(NSString *className, PDLSwiftMethodKind methodKind, BOOL isInstance, BOOL isDynamic, intptr_t impOffset))action;

- (void)enumerateBlockInvokes:(intptr_t)impOffset action:(void (^)(intptr_t blockInvokeOffset, intptr_t copyOffset, intptr_t disposeOffset))action byRefAction:(void (^)(intptr_t copyOffset, intptr_t disposeOffset))byRefAction;

@end

NS_ASSUME_NONNULL_END
