//
//  PDLFormViewCell.h
//  Poodle
//
//  Created by Poodle on 28/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDLFormViewCell : UIView

@property (nonatomic, weak, readonly) UIView *contentView;
@property (nonatomic, weak) UIView *view;

@property (nonatomic, strong) UIColor *leftSeparatorLineColor;
@property (nonatomic, strong) UIColor *rightSeparatorLineColor;
@property (nonatomic, strong) UIColor *topSeparatorLineColor;
@property (nonatomic, strong) UIColor *bottomSeparatorLineColor;

- (void)setIsLeft:(BOOL)isLeft isRight:(BOOL)isRight isTop:(BOOL)isTop isBottom:(BOOL)isBottom;

@end
