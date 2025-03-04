//
//  UIScreen+PDLExtension.m
//  Poodle
//
//  Created by Poodle on 4/13/16.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "UIScreen+PDLExtension.h"

@implementation UIScreen (PDLExtension)

- (CGSize)pdl_portraitSize {
    CGSize size = self.bounds.size;
    if (size.width > size.height) {
        size = CGSizeMake(size.height, size.width);
    }
    return size;
}

@end
