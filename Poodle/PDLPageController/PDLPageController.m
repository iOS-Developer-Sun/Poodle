//
//  PDLPageController.m
//  Poodle
//
//  Created by Poodle on 2020/10/24.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLPageController.h"
#import "PDLFormView.h"

@interface PDLPageController () <PDLFormViewDelegate> {
    BOOL _delegateRespondsNumberOfViews;
    BOOL _delegateRespondsViewAtIndex;

    BOOL _delegateRespondsCurrentIndexDidChange;

    BOOL _delegateRespondsWillDisplayAtIndexAnimated;
    BOOL _delegateRespondsDidDisplayAtIndexAnimated;
    BOOL _delegateRespondsWillEndDisplayingAtIndexAnimated;
    BOOL _delegateRespondsDidEndDisplayingAtIndexAnimated;

    BOOL _delegateRespondsDidBeginScrollingAnimation;
}

@property (nonatomic, strong) PDLFormView *pageView;

@end

@implementation PDLPageController

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentIndex = NSNotFound;

        PDLFormView *pageView = [[PDLFormView alloc] init];
        pageView.clipsToBounds = YES;
        pageView.pagingEnabled = YES;
        pageView.showsHorizontalScrollIndicator = NO;
        pageView.showsVerticalScrollIndicator = NO;
        pageView.formViewDelegate = self;
        if (@available(iOS 11.0, *)) {
            pageView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _pageView = pageView;
    }
    return self;
}

#pragma mark -

- (BOOL)formViewHasAnimation:(PDLFormView *)formView {
    id animation = nil;
    @try {
        animation = [formView valueForKeyPath:@"animation"];
    } @catch (NSException *exception) {
        ;
    } @finally {
        ;
    }
    return animation != nil;
}

- (BOOL)formViewAnimated:(PDLFormView *)formView {
    if (formView.isDragging || formView.isDecelerating) {
        return YES;
    }

    return [self formViewHasAnimation:formView];
}

#pragma mark -

- (void)setDelegate:(id<PDLPageControllerDelegate>)delegate {
    if (_delegate == delegate) {
        return;
    }

    _delegate = delegate;

    _delegateRespondsNumberOfViews = [delegate respondsToSelector:@selector(numberOfViewsInPageController:)];
    _delegateRespondsViewAtIndex = [delegate respondsToSelector:@selector(pageController:viewAtIndex:)];

    _delegateRespondsCurrentIndexDidChange = [delegate respondsToSelector:@selector(pageController:currentIndexDidChange:)];

    _delegateRespondsWillDisplayAtIndexAnimated = [delegate respondsToSelector:@selector(pageController:willDisplay:atIndex:animated:)];
    _delegateRespondsDidDisplayAtIndexAnimated = [delegate respondsToSelector:@selector(pageController:didDisplay:atIndex:animated:)];
    _delegateRespondsWillEndDisplayingAtIndexAnimated = [delegate respondsToSelector:@selector(pageController:willEndDisplaying:atIndex:animated:)];
    _delegateRespondsDidEndDisplayingAtIndexAnimated = [delegate respondsToSelector:@selector(pageController:didEndDisplaying:atIndex:animated:)];

    _delegateRespondsDidBeginScrollingAnimation = [delegate respondsToSelector:@selector(pageController:didBeginScrollingAnimation:)];
}

- (UIScrollView *)scrollView {
    return self.pageView;
}

- (NSString *)reuseIdentifierForView:(UIView *)view {
    return [self.pageView reuseIdentifierForView:view];
}

- (void)setReuseIdentifier:(NSString *)identifier forView:(UIView *)view {
    [self.pageView setReuseIdentifier:identifier forView:view];
}

- (UIView *)dequeueReusableViewWithIdentifier:(NSString *)identifier {
    return [self.pageView dequeueReusableViewWithIdentifier:identifier];
}

- (NSDictionary *)dequeueAllReusableViews {
    return [self.pageView dequeueAllReusableViews];
}

- (UIView *)viewAtIndex:(NSInteger)index {
    return [self.pageView viewForColumn:index row:0];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    [self setCurrentIndex:currentIndex animated:NO];
}

- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated {
    NSInteger originalCurrentIndex = _currentIndex;
    if (originalCurrentIndex == currentIndex) {
        return;
    }

    _currentIndex = currentIndex;

    [self.pageView scrollToColumn:currentIndex row:0 atScrollPosition:PDLFormViewScrollPositionNone animated:animated];

    if (_delegateRespondsCurrentIndexDidChange) {
        [_delegate pageController:self currentIndexDidChange:originalCurrentIndex];
    }
}

- (void)reloadData {
    [self.pageView reloadData];
}

- (void)refreshCurrent {
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGRect frame = self.scrollView.frame;
    CGFloat width = CGRectGetWidth(frame);
    if (width == 0) {
        return;
    }

    CGFloat currentIndex = contentOffset.x / width;
    self.currentIndex = round(currentIndex);
}

#pragma mark - PDLFormViewDelegate

- (UIView *)formView:(PDLFormView *)formView viewForColumn:(NSInteger)column row:(NSInteger)row {
    UIView *view = nil;
    if (_delegateRespondsViewAtIndex) {
        view = [_delegate pageController:self viewAtIndex:column];
    }
    return view;
}

- (NSInteger)numberOfColumnsInFormView:(PDLFormView *)formView {
    NSInteger number = 0;
    if (_delegateRespondsNumberOfViews) {
        number = [_delegate numberOfViewsInPageController:self];
    }
    return number;
}

- (NSInteger)numberOfRowsInFormView:(PDLFormView *)formView {
    return 1;
}

- (CGFloat)formView:(PDLFormView *)formView widthForColumn:(NSInteger)column {
    return formView.bounds.size.width;
}

- (CGFloat)formView:(PDLFormView *)formView heightForRow:(NSInteger)row {
    return formView.bounds.size.height;
}

- (void)visibleColumnsRowsDidChange:(PDLFormView *)formView {
    [self refreshCurrent];
}

- (void)formView:(PDLFormView *)formView willDisplayView:(UIView *)view forColumn:(NSInteger)column row:(NSInteger)row {
    if (_delegateRespondsWillDisplayAtIndexAnimated) {
        BOOL animated = [self formViewAnimated:formView];
        [_delegate pageController:self willDisplay:view atIndex:column animated:animated];
    }
}

- (void)formView:(PDLFormView *)formView didDisplayView:(UIView *)view forColumn:(NSInteger)column row:(NSInteger)row {
    if (_delegateRespondsDidDisplayAtIndexAnimated) {
        BOOL animated = [self formViewAnimated:formView];
        [_delegate pageController:self didDisplay:view atIndex:column animated:animated];
    }
}

- (void)formView:(PDLFormView *)formView willEndDisplayingView:(UIView *)view forColumn:(NSInteger)column row:(NSInteger)row {
    if (_delegateRespondsWillEndDisplayingAtIndexAnimated) {
        BOOL animated = [self formViewAnimated:formView];
        [_delegate pageController:self willEndDisplaying:view atIndex:column animated:animated];
    }
}

- (void)formView:(PDLFormView *)formView didEndDisplayingView:(UIView *)view forColumn:(NSInteger)column row:(NSInteger)row {
    if (_delegateRespondsDidEndDisplayingAtIndexAnimated) {
        BOOL animated = [self formViewAnimated:formView];
        [_delegate pageController:self didEndDisplaying:view atIndex:column animated:animated];
    }
}

- (void)formView:(PDLFormView *)formView didSetContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    if (animated && _delegateRespondsDidBeginScrollingAnimation) {
        BOOL formViewAnimated = [self formViewHasAnimation:formView];
        if (formViewAnimated) {
            [_delegate pageController:self didBeginScrollingAnimation:NO];
        }
    }
}

- (void)formView:(PDLFormView *)formView didScrollRectToVisible:(CGRect)rect animated:(BOOL)animated {
    if (animated && _delegateRespondsDidBeginScrollingAnimation) {
        BOOL formViewAnimated = [self formViewHasAnimation:formView];
        if (formViewAnimated) {
            [_delegate pageController:self didBeginScrollingAnimation:YES];
        }
    }
}

@end
