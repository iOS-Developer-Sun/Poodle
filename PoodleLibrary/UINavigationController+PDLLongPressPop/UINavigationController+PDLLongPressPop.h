//
//  UINavigationController+PDLLongPressPop.h
//  Poodle
//
//  Created by Poodle on 2019/1/17.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (PDLLongPressPop)

@property (nonatomic, assign, setter=pdl_setSupportsLongPressPop:) BOOL pdl_supportsLongPressPop; // loadViewIfNeeded

@end
