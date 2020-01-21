//
//  PDLResizableImageView.h
//  Poodle
//
//  Created by Poodle on 2019/1/17.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDLResizableImageView : UIView

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) UIEdgeInsets capInsets;
@property (nonatomic, assign) CGSize centralSize;

@end
