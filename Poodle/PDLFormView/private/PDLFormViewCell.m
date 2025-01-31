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
@property (nonatomic, assign, readonly) CGFloat lineWidth;
@property (nonatomic, assign, readonly, class) CGFloat lineWidth;

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

    CGFloat lineWidth = self.lineWidth;

    UIView *separatorLine = nil;

    separatorLine = _leftSeparatorLine;
    if (separatorLine && (separatorLine.hidden == NO)) {
        x += lineWidth;
        width -= lineWidth;
    }

    separatorLine = _rightSeparatorLine;
    if (separatorLine && (separatorLine.hidden == NO)) {
        width -= lineWidth;
    }

    separatorLine = _topSeparatorLine;
    if (separatorLine && (separatorLine.hidden == NO)) {
        y += lineWidth;
        height -= lineWidth;
    }

    separatorLine = _bottomSeparatorLine;
    if (separatorLine && (separatorLine.hidden == NO)) {
        height -= lineWidth;
    }

    self.contentView.frame = CGRectMake(x, y, width, height);
    if (self.view.superview == self.contentView) {
        self.view.frame = self.contentView.bounds;
    }
}

+ (CGFloat)lineWidth {
    CGFloat lineWidth = 1 / [UIScreen mainScreen].scale;
    return lineWidth;
}

- (CGFloat)lineWidth {
    CGFloat lineWidth = [self.class lineWidth];
    return lineWidth;
}

- (UIView *)leftSeparatorLine {
    if (!_leftSeparatorLine) {
        CGFloat lineWidth = self.lineWidth;
        UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lineWidth, self.bounds.size.height)];
        separatorLine.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        separatorLine.userInteractionEnabled = NO;
        [self addSubview:separatorLine];
        _leftSeparatorLine = separatorLine;
    }
    return _leftSeparatorLine;
}

- (UIView *)rightSeparatorLine {
    if (!_rightSeparatorLine) {
        CGFloat lineWidth = self.lineWidth;
        UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width - lineWidth, 0, lineWidth, self.bounds.size.height)];
        separatorLine.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        separatorLine.userInteractionEnabled = NO;
        [self addSubview:separatorLine];
        _rightSeparatorLine = separatorLine;
    }
    return _rightSeparatorLine;
}

- (UIView *)topSeparatorLine {
    if (!_topSeparatorLine) {
        CGFloat lineWidth = self.lineWidth;
        UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, lineWidth)];
        separatorLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        separatorLine.userInteractionEnabled = NO;
        [self addSubview:separatorLine];
        _topSeparatorLine = separatorLine;
    }
    return _topSeparatorLine;
}

- (UIView *)bottomSeparatorLine {
    if (!_bottomSeparatorLine) {
        CGFloat lineWidth = self.lineWidth;
        UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - lineWidth, self.bounds.size.width, lineWidth)];
        separatorLine.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        separatorLine.userInteractionEnabled = NO;
        [self addSubview:separatorLine];
        _bottomSeparatorLine = separatorLine;
    }
    return _bottomSeparatorLine;
}

- (void)setIsLeft:(BOOL)isLeft isRight:(BOOL)isRight isTop:(BOOL)isTop isBottom:(BOOL)isBottom {
    CGFloat left = 0;
    CGFloat right = 1;
    CGFloat top = 2;
    CGFloat bottom = 3;
    if (isLeft) {
        left += 10;
    }
    if (isRight) {
        right += 10;
    }
    if (isTop) {
        top += 10;
    }
    if (isBottom) {
        bottom += 10;
    }

    _leftSeparatorLine.layer.zPosition = left;
    _rightSeparatorLine.layer.zPosition = right;
    _topSeparatorLine.layer.zPosition = top;
    _bottomSeparatorLine.layer.zPosition = bottom;
}

#pragma mark -

- (UIColor *)leftSeparatorLineColor {
    return _leftSeparatorLine.backgroundColor;
}

- (void)setLeftSeparatorLineColor:(UIColor *)leftSeparatorLineColor {
    BOOL hidden = _leftSeparatorLine ? _leftSeparatorLine.hidden : YES;
    if (leftSeparatorLineColor) {
        self.leftSeparatorLine.hidden = NO;
        self.leftSeparatorLine.backgroundColor = leftSeparatorLineColor;
        if (hidden) {
            [self setNeedsLayout];
        }
    } else {
        _leftSeparatorLine.hidden = YES;
        _leftSeparatorLine.backgroundColor = nil;
        if (!hidden) {
            [self setNeedsLayout];
        }
    }
}

- (UIColor *)rightSeparatorLineColor {
    return _rightSeparatorLine.backgroundColor;
}

- (void)setRightSeparatorLineColor:(UIColor *)rightSeparatorLineColor {
    BOOL hidden = _rightSeparatorLine ? _rightSeparatorLine.hidden : YES;
    if (rightSeparatorLineColor) {
        self.rightSeparatorLine.hidden = NO;
        self.rightSeparatorLine.backgroundColor = rightSeparatorLineColor;
        if (hidden) {
            [self setNeedsLayout];
        }
    } else {
        _rightSeparatorLine.hidden = YES;
        _rightSeparatorLine.backgroundColor = nil;
        if (!hidden) {
            [self setNeedsLayout];
        }
    }
}

- (UIColor *)topSeparatorLineColor {
    return _topSeparatorLine.backgroundColor;
}

- (void)setTopSeparatorLineColor:(UIColor *)topSeparatorLineColor {
    BOOL hidden = _topSeparatorLine ? _topSeparatorLine.hidden : YES;
    if (topSeparatorLineColor) {
        self.topSeparatorLine.hidden = NO;
        self.topSeparatorLine.backgroundColor = topSeparatorLineColor;
        if (hidden) {
            [self setNeedsLayout];
        }
    } else {
        _topSeparatorLine.hidden = YES;
        _topSeparatorLine.backgroundColor = nil;
        if (!hidden) {
            [self setNeedsLayout];
        }
    }
}

- (UIColor *)bottomSeparatorLineColor {
    return _bottomSeparatorLine.backgroundColor;
}

- (void)setBottomSeparatorLineColor:(UIColor *)bottomSeparatorLineColor {
    BOOL hidden = _bottomSeparatorLine ? _bottomSeparatorLine.hidden : YES;
    if (bottomSeparatorLineColor) {
        self.bottomSeparatorLine.hidden = NO;
        self.bottomSeparatorLine.backgroundColor = bottomSeparatorLineColor;
        if (hidden) {
            [self setNeedsLayout];
        }
    } else {
        _bottomSeparatorLine.hidden = YES;
        _bottomSeparatorLine.backgroundColor = nil;
        if (!hidden) {
            [self setNeedsLayout];
        }
    }
}

@end
