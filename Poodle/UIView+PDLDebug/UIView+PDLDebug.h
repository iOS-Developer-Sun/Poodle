//
//  UIView+PDLDebug.h
//  Poodle
//
//  Created by Poodle on 4/13/16.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PDLViewDebugType) {
    PDLViewDebugTypeNone,
    PDLViewDebugTypeColorViewBounds,
    PDLViewDebugTypeAlignmentRects,
};

@interface UIView (PDLDebug)

@property (nonatomic, assign, class, setter=pdl_setViewDebugType:) PDLViewDebugType pdl_viewDebugType;

+ (BOOL)pdl_debugEnable;

@end
