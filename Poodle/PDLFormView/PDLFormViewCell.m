//
//  PDLFormViewCell.m
//  Poodle
//
//  Created by Poodle on 28/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLFormViewCell.h"

@interface PDLFormViewCell ()

@property (nonatomic, weak) UIView *leftSeparatorLine;
@property (nonatomic, weak) UIView *rightSeparatorLine;
@property (nonatomic, weak) UIView *topSeparatorLine;
@property (nonatomic, weak) UIView *bottomSeparatorLine;

@property (nonatomic, weak) UIView *contentView;

@end

@implementation PDLFormViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:contentView];
        _contentView = contentView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;

    CGFloat lineWidth = 1 / [UIScreen mainScreen].scale;

    UIView *separatorLine = nil;

    separatorLine = _leftSeparatorLine;
    if (separatorLine) {
        separatorLine.frame = CGRectMake(0, 0, lineWidth, self.bounds.size.height);
        if (separatorLine.hidden == NO) {
            x += lineWidth;
            width -= lineWidth;
        }
    }

    separatorLine = _rightSeparatorLine;
    if (separatorLine) {
        separatorLine.frame = CGRectMake(self.bounds.size.width - lineWidth, 0, lineWidth, self.bounds.size.height);
        if (separatorLine.hidden == NO) {
            width -= lineWidth;
        }
    }

    separatorLine = _topSeparatorLine;
    if (separatorLine) {
        separatorLine.frame = CGRectMake(0, 0, self.bounds.size.width, lineWidth);
        if (separatorLine.hidden == NO) {
            y += lineWidth;
            height -= lineWidth;
        }
    }

    separatorLine = _bottomSeparatorLine;
    if (separatorLine) {
        separatorLine.frame = CGRectMake(0, self.bounds.size.height - lineWidth, self.bounds.size.width, lineWidth);
        if (separatorLine.hidden == NO) {
            height -= lineWidth;
        }
    }

    self.contentView.frame = CGRectMake(x, y, width, height);
    if (self.view.superview == self.contentView) {
        self.view.frame = self.contentView.bounds;
    }
}

- (UIView *)leftSeparatorLine {
    if (!_leftSeparatorLine) {
        UIView *leftSeparatorLine = [[UIView alloc] init];
        [self addSubview:leftSeparatorLine];
        _leftSeparatorLine = leftSeparatorLine;
    }
    return _leftSeparatorLine;
}

- (UIView *)rightSeparatorLine {
    if (!_rightSeparatorLine) {
        UIView *rightSeparatorLine = [[UIView alloc] init];
        [self addSubview:rightSeparatorLine];
        _rightSeparatorLine = rightSeparatorLine;
    }
    return _rightSeparatorLine;
}

- (UIView *)topSeparatorLine {
    if (!_topSeparatorLine) {
        UIView *topSeparatorLine = [[UIView alloc] init];
        [self addSubview:topSeparatorLine];
        _topSeparatorLine = topSeparatorLine;
    }
    return _topSeparatorLine;
}

- (UIView *)bottomSeparatorLine {
    if (!_bottomSeparatorLine) {
        UIView *bottomSeparatorLine = [[UIView alloc] init];
        [self addSubview:bottomSeparatorLine];
        _bottomSeparatorLine = bottomSeparatorLine;
    }
    return _bottomSeparatorLine;
}

- (void)applyShown:(BOOL)shown forView:(UIView *)view {
    if (!view) {
        return;
    }

    view.hidden = !shown;
    if (shown) {
        [view.superview bringSubviewToFront:view];
    } else {
        [view.superview sendSubviewToBack:view];
    }

}

- (void)setIsLeft:(BOOL)isLeft isRight:(BOOL)isRight isTop:(BOOL)isTop isBottom:(BOOL)isBottom {
    [self applyShown:isLeft forView:_leftSeparatorLine];
    [self applyShown:isRight forView:_rightSeparatorLine];
    [self applyShown:isTop forView:_topSeparatorLine];
    [self applyShown:isBottom forView:_bottomSeparatorLine];
}

#pragma mark -

- (UIColor *)leftSeparatorLineColor {
    return _leftSeparatorLine.backgroundColor;
}

- (void)setLeftSeparatorLineColor:(UIColor *)leftSeparatorLineColor {
    (leftSeparatorLineColor ? self.leftSeparatorLine : _leftSeparatorLine).backgroundColor = leftSeparatorLineColor;
}

- (UIColor *)rightSeparatorLineColor {
    return _rightSeparatorLine.backgroundColor;
}

- (void)setRightSeparatorLineColor:(UIColor *)rightSeparatorLineColor {
    (rightSeparatorLineColor ? self.rightSeparatorLine : _rightSeparatorLine).backgroundColor = rightSeparatorLineColor;
}

- (UIColor *)topSeparatorLineColor {
    return _topSeparatorLine.backgroundColor;
}

- (void)setTopSeparatorLineColor:(UIColor *)topSeparatorLineColor {
    (topSeparatorLineColor ? self.topSeparatorLine : _topSeparatorLine).backgroundColor = topSeparatorLineColor;
}

- (UIColor *)bottomSeparatorLineColor {
    return _bottomSeparatorLine.backgroundColor;
}

- (void)setBottomSeparatorLineColor:(UIColor *)bottomSeparatorLineColor {
    (bottomSeparatorLineColor ? self.bottomSeparatorLine : _bottomSeparatorLine).backgroundColor = bottomSeparatorLineColor;
}

@end
