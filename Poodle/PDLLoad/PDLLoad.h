//
//  PDLLoad.h
//  Poodle
//
//  Created by Poodle on 2020/12/22.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLLoad : NSObject

+ (void)disableCategoryLoad:(BOOL(^_Nullable)(void *imageHeader, NSString *imageName, Class aClass, NSString *categoryName))filter;

@end


NS_ASSUME_NONNULL_END
