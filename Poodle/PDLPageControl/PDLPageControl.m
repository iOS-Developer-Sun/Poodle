//
//  PDLPageControl.m
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLPageControl.h"

@interface PDLPageControl () {
    struct {
        BOOL respondsDidCreateItemView : 1;
        BOOL respondsWillDestroyItemView : 1;
        BOOL respondsGetCurrentForItemView : 1;
        BOOL respondsSetCurrentForItemView : 1;
    } _flags;
}

@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, strong) NSMutableArray <__kindof UIView <PDLPageControlItemView> *>*itemViews;

@end

@implementation PDLPageControl

@synthesize currentPage = _currentPage;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;

        _currentPage = -1;
        _itemViewMargin = 8;
        CGSize itemViewSize = CGSizeMake(8, 8);
        _itemViewSize = itemViewSize;
        _currentItemViewSize = itemViewSize;

        _itemViews = [NSMutableArray array];

        UIView *containerView = [[UIView alloc] init];
        [self addSubview:containerView];
        _containerView = containerView;
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    CGFloat width = 0;
    CGFloat height = 0;
    if (self.numberOfPages > 0) {
        width = (self.numberOfPages - 1) * (self.itemViewSize.width + self.itemViewMargin) + self.currentItemViewSize.width;
        height = MAX(self.itemViewSize.height, self.currentItemViewSize.height);
    }
    return CGSizeMake(width, height);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return self.intrinsicContentSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self reloadItemViews];

    CGRect containerViewFrame = self.containerView.bounds;
    CGFloat toWidth = self.intrinsicContentSize.width;
    BOOL isWidthChanged = (containerViewFrame.size.width != toWidth);
    containerViewFrame.size.width = toWidth;
    containerViewFrame.size.height = self.intrinsicContentSize.height;
    self.containerView.frame = containerViewFrame;

    if (isWidthChanged) {
        [self layoutContainerView];
    }

    containerViewFrame.origin.x = (self.bounds.size.width - containerViewFrame.size.width) / 2;
    containerViewFrame.origin.y = (self.bounds.size.height - containerViewFrame.size.height) / 2;

    self.containerView.frame = containerViewFrame;
}

#pragma mark - Private methods

- (void)didCreateItemView:(UIView <PDLPageControlItemView> *)itemView {
    if (_flags.respondsDidCreateItemView) {
        [_delegate pageControl:self didCreateItemView:itemView];
    }
}

- (void)willDestroyItemView:(UIView <PDLPageControlItemView> *)itemView {
    if (_flags.respondsWillDestroyItemView) {
        [_delegate pageControl:self willDestroyItemView:itemView];
    }
}

- (void)itemViewDidChangeCurrentState:(UIView <PDLPageControlItemView> *)itemView isCurrent:(BOOL)isCurrent {
    if (!itemView) {
        return;
    }

    BOOL originalIsCurrent = !isCurrent;
    if (_flags.respondsGetCurrentForItemView) {
        [_delegate pageControl:self getCurrent:&originalIsCurrent forItemView:itemView];
    } else {
        if ([itemView respondsToSelector:@selector(isCurrentPageControlItemView)]) {
            originalIsCurrent = [itemView isCurrentPageControlItemView];
        }
    }

    if (originalIsCurrent == isCurrent) {
        return;
    }

    if (_flags.respondsSetCurrentForItemView) {
        [_delegate pageControl:self setCurrent:isCurrent forItemView:itemView];
    } else {
        if ([itemView respondsToSelector:@selector(setIsCurrentPageControlItemView:)]) {
            itemView.isCurrentPageControlItemView = isCurrent;
        }
    }
}

- (PDLPageControlItemView *)itemViewAtIndex:(NSUInteger)index {
    if (index >= self.itemViews.count) {
        return nil;
    }

    return self.itemViews[index];
}

- (void)reloadItemViews {
    NSInteger originalCount = self.itemViews.count;
    NSInteger count = self.numberOfPages;
    if (originalCount == count) {
        return;
    }

    if (originalCount < count) {
        CGSize itemViewSize = self.itemViewSize;
        CGSize currentItemViewSize = self.currentItemViewSize;
        Class aClass = self.itemViewClass ?: [PDLPageControlItemView class];
        NSInteger currentPage = self.currentPage;
        for (NSInteger i = originalCount; i < count; i++) {
            BOOL isCurrent = (i == currentPage);
            CGFloat width = (isCurrent ? currentItemViewSize : itemViewSize).width;
            CGFloat height = (isCurrent ? currentItemViewSize : itemViewSize).height;
            UIView <PDLPageControlItemView> *itemView = [[aClass alloc] initWithFrame:CGRectMake(0, 0, width, height)];
            [self.containerView addSubview:itemView];
            [self.itemViews addObject:itemView];
            [self didCreateItemView:itemView];
            [self itemViewDidChangeCurrentState:itemView isCurrent:isCurrent];
        }
    } else {
        for (NSInteger i = originalCount - 1; i >= count; i--) {
            UIView <PDLPageControlItemView> *itemView = self.itemViews[i];
            [self willDestroyItemView:itemView];
            [itemView removeFromSuperview];
            [self.itemViews removeObject:itemView];
        }
    }
    self.currentPage = self.currentPage;
}

- (void)refreshContainerViewHidden {
    self.containerView.hidden = self.hidesForSinglePage && self.numberOfPages == 1;
}

- (void)layoutContainerView {
    NSMutableArray <__kindof UIView<PDLPageControlItemView> *>*itemViews = self.itemViews;
    CGFloat itemViewSizeWidth = self.itemViewSize.width;
    CGFloat itemViewSizeHeight = self.itemViewSize.height;
    CGFloat currentItemViewSizeWidth = self.currentItemViewSize.width;
    CGFloat currentItemViewSizeHeight = self.currentItemViewSize.height;
    CGFloat gap = self.itemViewMargin;
    CGFloat x = 0;
    NSInteger currentPage = self.currentPage;
    CGFloat containerViewHeight = self.containerView.bounds.size.height;
    for (NSInteger i = 0; i < itemViews.count; i++) {
        __kindof UIView<PDLPageControlItemView> *itemView = itemViews[i];
        BOOL isCurrent = (i == currentPage);
        CGFloat width = isCurrent ? currentItemViewSizeWidth : itemViewSizeWidth;
        CGFloat height = isCurrent ? currentItemViewSizeHeight : itemViewSizeHeight;
        itemView.frame = CGRectMake(x, (containerViewHeight - height) / 2, width, height);
        x += width + gap;
    }
}

#pragma mark - Public methods

- (void)setDelegate:(id<PDLPageControlDelegate>)delegate {
    if (_delegate == delegate) {
        return;
    }

    _delegate = delegate;

    _flags.respondsDidCreateItemView = [delegate respondsToSelector:@selector(pageControl:didCreateItemView:)];
    _flags.respondsWillDestroyItemView = [delegate respondsToSelector:@selector(pageControl:willDestroyItemView:)];
    _flags.respondsGetCurrentForItemView = [delegate respondsToSelector:@selector(pageControl:getCurrent:forItemView:)];
    _flags.respondsSetCurrentForItemView = [delegate respondsToSelector:@selector(pageControl:setCurrent:forItemView:)];
}

- (void)setNumberOfPages:(NSUInteger)numberOfPages {
    NSInteger number = numberOfPages;
    if (number > 100) {
        number = 100;
    }

    NSInteger originalNumberOfPages = _numberOfPages;
    if (originalNumberOfPages == number) {
        return;
    }

    _numberOfPages = number;

    self.currentPage = self.currentPage;

    [self refreshContainerViewHidden];

    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
    NSInteger numberOfPages = self.numberOfPages;
    if (numberOfPages == 0) {
        _currentPage = -1;
        return;
    }

    NSInteger page = currentPage;
    if (page < 0) {
        page = 0;
    } else if (page > numberOfPages - 1) {
        page = numberOfPages - 1;
    }

    NSInteger originalCurrentPage = _currentPage;
    if (originalCurrentPage == page) {
        return;
    }

    _currentPage = page;
    void(^action)(void) = ^{
        [self itemViewDidChangeCurrentState:[self itemViewAtIndex:originalCurrentPage] isCurrent:NO];
        [self itemViewDidChangeCurrentState:[self itemViewAtIndex:page] isCurrent:YES];
        [self layoutContainerView];
    };

    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            action();
        } completion:^(BOOL finished) {
            ;
        }];
    } else {
        action();
    }
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
    _hidesForSinglePage = hidesForSinglePage;

    [self refreshContainerViewHidden];
}

- (void)setItemViewMargin:(CGFloat)itemViewMargin {
    if (_itemViewMargin == itemViewMargin) {
        return;
    }

    _itemViewMargin = itemViewMargin;

    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setItemViewSize:(CGSize)itemViewSize {
    if (CGSizeEqualToSize(_itemViewSize, itemViewSize)) {
        return;
    }

    _itemViewSize = itemViewSize;

    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setCurrentItemViewSize:(CGSize)currentItemViewSize {
    if (CGSizeEqualToSize(_currentItemViewSize, currentItemViewSize)) {
        return;
    }

    _currentItemViewSize = currentItemViewSize;

    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

@end

#pragma mark -

@implementation PDLPageControlItemView

@synthesize isCurrentPageControlItemView = _isCurrentPageControlItemView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];

    self.layer.cornerRadius = self.bounds.size.height / 2;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    self.layer.cornerRadius = self.bounds.size.height / 2;
}

- (void)setIsCurrentPageControlItemView:(BOOL)isCurrentPageControlItemView {
    if (_isCurrentPageControlItemView == isCurrentPageControlItemView) {
        return;
    }

    _isCurrentPageControlItemView = isCurrentPageControlItemView;
    self.backgroundColor = isCurrentPageControlItemView ? [UIColor whiteColor] : [UIColor lightGrayColor];
}

@end
