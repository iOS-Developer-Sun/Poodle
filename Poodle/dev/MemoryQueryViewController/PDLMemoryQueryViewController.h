//
//  PDLMemoryQueryViewController.h
//  Poodle
//
//  Created by Poodle on 15/7/16.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLViewController.h"

typedef NS_ENUM(NSUInteger, PDLMemoryQueryResultType) {
    PDLMemoryQueryResultTypeUnknown,
    PDLMemoryQueryResultTypeVoid,
    PDLMemoryQueryResultTypeClass,
    PDLMemoryQueryResultTypeSelector,
    PDLMemoryQueryResultTypeNSObject,
    PDLMemoryQueryResultTypeChar,
    PDLMemoryQueryResultTypeShort,
    PDLMemoryQueryResultTypeInt,
    PDLMemoryQueryResultTypeLong,
    PDLMemoryQueryResultTypeLongLong,
    PDLMemoryQueryResultTypeUnsignedChar,
    PDLMemoryQueryResultTypeUnsignedShort,
    PDLMemoryQueryResultTypeUnsignedInt,
    PDLMemoryQueryResultTypeUnsignedLong,
    PDLMemoryQueryResultTypeUnsignedLongLong,
    PDLMemoryQueryResultTypeFloat,
    PDLMemoryQueryResultTypeDouble,
    PDLMemoryQueryResultTypeBool,
    PDLMemoryQueryResultTypePointer,
    PDLMemoryQueryResultTypeFunctionPointer,
    PDLMemoryQueryResultTypeCString,
    PDLMemoryQueryResultTypeBlock,
    PDLMemoryQueryResultTypeCGPoint,
    PDLMemoryQueryResultTypeCGSize,
    PDLMemoryQueryResultTypeCGRect,
    PDLMemoryQueryResultTypeError,
    PDLMemoryQueryResultTypeCount
};

@interface PDLMemoryQueryResult : NSObject

@property (nonatomic, assign) PDLMemoryQueryResultType type;
@property (nonatomic, strong) id result;

@end

@interface PDLMemoryQueryViewController : PDLViewController

+ (void)addConstantQueryWithTitle:(NSString *)title action:(void(^)(PDLMemoryQueryResult *result))action;

@end
