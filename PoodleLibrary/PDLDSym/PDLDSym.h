//
//  PDLDSym.h
//  Poodle
//
//  Created by Poodle on 2023/8/3.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "pdl_mach_object.h"

@interface PDLDSym : NSObject

@property (nonatomic, copy) NSString *unnamedSymbolPrefix;
@property (nonatomic, assign) BOOL usesIndexForUnnamedSymbol;
@property (nonatomic, readonly) pdl_mach_object *machObject;
@property (nonatomic, readonly) NSUInteger totalCount;
@property (nonatomic, readonly) NSUInteger unnamedCount;

- (instancetype)initWithObject:(pdl_mach_object)machObject;
- (BOOL)addSymbol:(NSString *)symbol debugName:(NSString *)debugName offset:(ptrdiff_t)offset;
- (BOOL)dump:(NSString *)path;

@end
