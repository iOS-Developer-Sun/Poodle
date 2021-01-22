//
//  PDLPageView.m
//  Poodle
//
//  Created by Poodle on 2020/10/26.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLPageView.h"
#import "PDLPageController.h"

@interface PDLPageView () <PDLPageControllerDelegate, UIScrollViewDelegate> {
    BOOL _delegateRespondsNumberOfViews;
    BOOL _delegateRespondsViewAtIndex;

    BOOL _delegateRespondsCurrentIndexDidChange;

    BOOL _delegateRespondsWillBeginDragging;
    BOOL _delegateRespondsDidEndScrollingAnimation;
    BOOL _delegateRespondsDidScrollToIndex;
    BOOL _delegateRespondsDidEndDecelerating;
    BOOL _delegateRespondsDidEndDraggingWillDecelerate;
}

@property (nonatomic, strong) PDLPageController *pageController;

@end

@implementation PDLPageView

static void init(PDLPageView *self) {
    PDLPageController *pageController = [[PDLPageController alloc] init];
    pageController.delegate = self;
    self.pageController = pageController;
    UIScrollView *scrollView = pageController.scrollView;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.frame = self.bounds;
    scrollView.delegate = self;
    [self addSubview:scrollView];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        init(self);
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        init(self);
    }
    return self;
}

- (BOOL)isVertical {
    return self.pageController.isVertical;
}

- (void)setIsVertical:(BOOL)isVertical {
    self.pageController.isVertical = isVertical;
}

- (void)setDelegate:(id<PDLPageViewDelegate>)delegate {
    if (_delegate == delegate) {
        return;
    }

    _delegate = delegate;

    _delegateRespondsNumberOfViews = [delegate respondsToSelector:@selector(numberOfViewsInPageView:)];
    _delegateRespondsViewAtIndex = [delegate respondsToSelector:@selector(pageView:viewAtIndex:)];

    _delegateRespondsCurrentIndexDidChange = [delegate respondsToSelector:@selector(pageView:currentIndexDidChange:)];

    _delegateRespondsWillBeginDragging = [delegate respondsToSelector:@selector(pageViewWillBeginDragging:)];
    _delegateRespondsDidEndScrollingAnimation = [delegate respondsToSelector:@selector(pageViewDidEndScrollingAnimation:)];
    _delegateRespondsDidScrollToIndex = [delegate respondsToSelector:@selector(pageView:didScrollToIndex:)];
    _delegateRespondsDidEndDecelerating = [delegate respondsToSelector:@selector(pageViewDidEndDecelerating:)];
    _delegateRespondsDidEndDraggingWillDecelerate  = [delegate respondsToSelector:@selector(pageViewDidEndDragging:willDecelerate:)];
}

#pragma mark - Public properties

- (NSInteger)currentIndex {
    return self.pageController.currentIndex;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    [self setCurrentIndex:currentIndex animated:NO];
}

- (UIScrollView *)scrollView {
    return self.pageController.scrollView;
}

#pragma mark - Public methods

- (NSString *)reuseIdentifierForView:(UIView *)view {
    return [self.pageController reuseIdentifierForView:view];
}

- (void)setReuseIdentifier:(NSString *)identifier forView:(UIView *)view {
    [self.pageController setReuseIdentifier:identifier forView:view];
}

- (__kindof UIView *)dequeueReusableViewWithIdentifier:(NSString *)identifier {
    return [self.pageController dequeueReusableViewWithIdentifier:identifier];
}

- (NSDictionary *)dequeueAllReusableViews {
    return [self.pageController dequeueAllReusableViews];
}

- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated {
    [self.pageController setCurrentIndex:currentIndex animated:animated];
}

- (void)reloadData {
    [self.pageController reloadData];
}

#pragma mark - PDLPageControllerDelegate

- (NSInteger)numberOfViewsInPageController:(PDLPageController *)pageController {
    NSInteger number = 0;
    if (_delegateRespondsNumberOfViews) {
        number = [_delegate numberOfViewsInPageView:self];
    }
    return number;
}

- (__kindof UIView *)pageController:(PDLPageController *)pageController viewAtIndex:(NSInteger)index {
    UIView *view = nil;
    if (_delegateRespondsViewAtIndex) {
        view = [_delegate pageView:self viewAtIndex:index];
    }
    return view;
}

- (void)pageController:(PDLPageController *)pageController currentIndexDidChange:(NSInteger)originalCurrentIndex {
    if (_delegateRespondsCurrentIndexDidChange) {
        [_delegate pageView:self currentIndexDidChange:originalCurrentIndex];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    CGRect frame = scrollView.frame;
    BOOL isVertical = self.pageController.isVertical;
    CGFloat length = isVertical ?  CGRectGetHeight(frame) : CGRectGetWidth(frame);
    if (length == 0) {
        return;
    }
    CGFloat ratio = (isVertical ? contentOffset.y : contentOffset.x) / length;

    if (_delegateRespondsDidScrollToIndex) {
        [_delegate pageView:self didScrollToIndex:ratio];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_delegateRespondsWillBeginDragging) {
        [_delegate pageViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (_delegateRespondsDidEndScrollingAnimation) {
        [_delegate pageViewDidEndScrollingAnimation:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_delegateRespondsDidEndDecelerating) {
        [_delegate pageViewDidEndDecelerating:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_delegateRespondsDidEndDraggingWillDecelerate) {
        [_delegate pageViewDidEndDragging:self willDecelerate:decelerate];
    }
}

@end

