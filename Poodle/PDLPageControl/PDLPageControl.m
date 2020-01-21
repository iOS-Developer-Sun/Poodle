//
//  PDLPageControl.m
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLPageControl.h"

static CGFloat const PDLPageControlDotWidth = 20;
static CGFloat const PDLPageControlDotWidthCurrent = 40;
static CGFloat const PDLPageControlDotHeight = 10;
static CGFloat const PDLPageControlDotMargin = 4;

@interface PDLPageControl ()

@end

@implementation PDLPageControl

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupPageControl];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPageControl];
    }
    return self;
}

- (void)setupPageControl {
    ;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self updateViewsForCurrentPage:self.currentPage];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
    NSInteger previousPage = self.currentPage;
    [super setCurrentPage:currentPage];
    [self updateViewsForCurrentPage:previousPage];

    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            [self updateViewsForCurrentPage:self.currentPage];
        } completion:^(BOOL finished) {
            ;
        }];
    } else {
        [self updateViewsForCurrentPage:self.currentPage];
    }
}

- (CGSize)contentSize {
    CGFloat width = PDLPageControlDotWidthCurrent + (self.numberOfPages - 1) * (PDLPageControlDotWidth + PDLPageControlDotMargin);
    CGFloat height = PDLPageControlDotHeight;
    return CGSizeMake(width, height);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize contentSize = [self contentSize];
    return contentSize;
}

- (void)updateViewsForCurrentPage:(NSInteger)currentPage {
    NSInteger count = self.subviews.count;
    if (count == 0) {
        return;
    }
    if (currentPage < 0) {
        return;
    }
    if (self.numberOfPages == 0) {
        return;
    }

    CGSize contentSize = [self contentSize];
    CGFloat left = (self.frame.size.width - contentSize.width) / 2;
    CGFloat top = (self.frame.size.height - contentSize.height) / 2;
    for (NSInteger i = 0; i < count; i++) {
        UIView *dot = self.subviews[i];
        CGFloat dotTop = top;
        CGFloat dotLeft = left;
        CGFloat dotWidth = PDLPageControlDotWidth;
        CGFloat dotHeight = PDLPageControlDotHeight;

        dot.layer.cornerRadius = dotHeight / 2;
        dot.backgroundColor = [UIColor whiteColor];
        dot.alpha = 0.5;
        if (i == currentPage) {
            dotWidth = PDLPageControlDotWidthCurrent;
            dot.alpha = 1;
        }

        dot.frame =  CGRectMake(dotLeft, dotTop, dotWidth, dotHeight);

        left += dotWidth;
        left += PDLPageControlDotMargin;
    }
}

@end
