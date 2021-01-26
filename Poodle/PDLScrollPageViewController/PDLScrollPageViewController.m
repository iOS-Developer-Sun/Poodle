//
//  PDLScrollPageViewController.m
//  Poodle
//
//  Created by Poodle on 16-1-19.
//
//

#import "PDLScrollPageViewController.h"

@interface PDLScrollPageViewControllerScrollPageView : UIView

@property (nonatomic, assign) BOOL needsReload;

@property (nonatomic, assign) NSInteger state; // 0 1 2
@property (nonatomic, copy) void (^stateDidChangeAction)(PDLScrollPageViewControllerScrollPageView *pageView, NSInteger originalState);
@property (nonatomic, strong) UIViewController *viewController;

@end

@implementation PDLScrollPageViewControllerScrollPageView

- (void)setViewController:(UIViewController *)viewController {
    if (_viewController == viewController) {
        return;
    }

    [viewController.view removeFromSuperview];
    _viewController = viewController;
    [self addSubview:viewController.view];
}

- (BOOL)refreshState {
    NSInteger originalState = self.state;
    NSInteger state = originalState;
    do {
        UIView *superview = self.superview;
        if (!superview) {
            state = 0;
            break;
        }

        CGRect frame = self.frame;
        CGRect bounds = superview.bounds;
        BOOL contains = CGRectContainsRect(bounds, frame);
        if (contains) {
            state = 2;
            break;
        }

        BOOL isOnScreen = CGRectIntersectsRect(bounds, frame);
        if (isOnScreen) {
            state = 1;
            break;
        }
        state = 0;
    } while (0);

    self.state = state;
    if (originalState != state) {
        if (self.stateDidChangeAction) {
            self.stateDidChangeAction(self, originalState);
        }
        return YES;
    }
    return NO;
}

@end

@interface PDLScrollPageViewControllerScrollView : UIScrollView

@property (nonatomic, copy) void(^layoutSubviewsAction)(PDLScrollPageViewControllerScrollView *scrollView);

@end

@implementation PDLScrollPageViewControllerScrollView

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.layoutSubviewsAction) {
        self.layoutSubviewsAction(self);
    }
}

@end

@interface PDLScrollPageViewControllerItem : NSObject

@end

static const NSInteger PDLScrollPageCount = 3;

@interface PDLScrollPageViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) PDLScrollPageViewControllerScrollView *scrollView;
@property (nonatomic, copy) NSArray <PDLScrollPageViewControllerScrollPageView *> *pageViews;

@property (nonatomic, assign) BOOL isReseting;

@end

@implementation PDLScrollPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    PDLScrollPageViewControllerScrollView *scrollView = [[PDLScrollPageViewControllerScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.bounces = NO;
    scrollView.scrollsToTop = NO;
    scrollView.clipsToBounds = YES;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;

    __weak __typeof(self) weakSelf = self;
    scrollView.layoutSubviewsAction = ^(PDLScrollPageViewControllerScrollView *scrollView) {
        [weakSelf scrollViewDidLayoutSubviews];
    };

    NSMutableArray <PDLScrollPageViewControllerScrollPageView *> *pageViews = [NSMutableArray array];
    for (NSInteger i = 0; i < PDLScrollPageCount; i++) {
        PDLScrollPageViewControllerScrollPageView *pageView = [[PDLScrollPageViewControllerScrollPageView alloc] initWithFrame:CGRectMake(0, 0, scrollView.bounds.size.width, scrollView.bounds.size.height)];
        pageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        pageView.needsReload = YES;
        pageView.stateDidChangeAction = ^(PDLScrollPageViewControllerScrollPageView *pageView, NSInteger originalState) {
            [weakSelf pageViewStateDidChange:pageView originalState:originalState];
        };
        [scrollView addSubview:pageView];
        [pageViews addObject:pageView];
    }
    self.pageViews = pageViews;
}

- (UIScrollView *)scrollView {
    [self loadViewIfNeeded];
    return _scrollView;
}

- (NSInteger)count {
    return self.pageViews.count;
}

- (PDLScrollPageViewControllerScrollPageView *)currentPageView {
    NSInteger index = self.count / 2;
    return self.pageViews[index];
}

- (PDLScrollPageViewControllerScrollPageView *)previousPageView {
    NSInteger index = self.count / 2 - 1;
    return self.pageViews[index];
}

- (PDLScrollPageViewControllerScrollPageView *)nextPageView {
    NSInteger index = self.count / 2 + 1;
    return self.pageViews[index];
}

- (void)setIsVertical:(BOOL)isVertical {
    if (_isVertical == isVertical) {
        return;
    }

    _isVertical = isVertical;

    [self.scrollView setNeedsLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

//    if (!self.currentPage) {
//        [self reloadData];
//    }
}

- (void)scrollViewDidLayoutSubviews {
    if (self.scrollView.contentSize.width == 0 || self.scrollView.contentSize.height == 0) {
        [self refreshContentSize];
        [self refreshPageViewsFrame];
        [self resetContentOffset];
    }

    BOOL changed = NO;
    for (NSInteger i = 0; i < self.count; i++) {
        PDLScrollPageViewControllerScrollPageView *pageView = self.pageViews[i];
        if (pageView.needsReload) {
            [self reloadPageViewAtIndex:i];
        }
        changed |= [pageView refreshState];
    }

    if (changed) {
        [self didScroll];
    }
    [self refreshContentInset];
}

- (void)reloadPageViewAtIndex:(NSInteger)index {
    PDLScrollPageViewControllerScrollPageView *pageView = self.pageViews[index];
    pageView.needsReload = NO;
    NSInteger currentIndex = self.count / 2;
    UIViewController *viewController = [self.delegate scrollPageViewController:self viewControllerAtIndex:index - currentIndex];
    pageView.viewController = viewController;
}

- (void)pageViewStateDidChange:(PDLScrollPageViewControllerScrollPageView *)pageView originalState:(NSInteger)originalState {
    NSInteger state = pageView.state;
    if (originalState == 0) {
        ;
    }
}

- (void)scrollToPreviousAnimated:(BOOL)animated {
    if (!self.scrollView) {
        return;
    }

    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:animated];
}

- (void)scrollToNextAnimated:(BOOL)animated {
    if (!self.nextPageView.viewController) {
        return;
    }

    CGRect frame = self.scrollView.frame;
    [self.scrollView setContentOffset:CGPointMake(self.isVertical ? 0 : 2 * frame.size.width, self.isVertical ? 2 * frame.size.height : 0) animated:animated];
}

- (void)reloadData {
//    [self resetScrollView];
}

- (void)enqueue:(UIViewController *)item {
    ;
}

- (void)refreshPageViewsFrame {
    BOOL isVertical = self.isVertical;
    CGSize size = self.scrollView.frame.size;
    for (NSInteger i = 0; i < self.count; i++) {
        PDLScrollPageViewControllerScrollPageView *pageView = self.pageViews[i];
        if (isVertical) {
            pageView.frame = CGRectMake(0, i * size.height, size.width, size.height);
        } else {
            pageView.frame = CGRectMake(i * size.width, 0, size.width, size.height);
        }
    }
}

- (void)refreshContentSize {
    BOOL isVertical = self.isVertical;
    CGSize size = self.scrollView.frame.size;
    NSInteger count = self.pageViews.count;
    self.scrollView.contentSize = isVertical ? CGSizeMake(size.width, size.height * count) : CGSizeMake(size.width * count, size.height);
}

- (void)resetContentOffset {
    BOOL isVertical = self.isVertical;
    CGSize size = self.scrollView.frame.size;
    NSInteger offsetPageCount = self.count / 2;
    self.scrollView.contentOffset = isVertical ? CGPointMake(0, size.height * offsetPageCount) : CGPointMake(size.width * offsetPageCount, 0);
}

- (void)refreshContentInset {
    BOOL isVertical = self.isVertical;
    CGSize size = self.scrollView.frame.size;
    CGFloat length = isVertical ? size.height : size.width;

    CGFloat previousInset = self.previousPageView.viewController ? 0 : -length;
    CGFloat nextInset = self.nextPageView.viewController ? 0 : -length;
    self.scrollView.contentInset = self.isVertical ? UIEdgeInsetsMake(previousInset, 0, nextInset, 0) : UIEdgeInsetsMake(0, previousInset, 0, nextInset);
}

- (void)didScroll {
    CGRect frame = self.scrollView.frame;
    BOOL isVertical = self.isVertical;
    CGFloat length = isVertical ? frame.size.height : frame.size.width;
    CGFloat offset = isVertical ?  self.scrollView.contentOffset.y : self.scrollView.contentOffset.x;
    if (offset < length * (self.count / 2 - 0.5)) {
        // left
        NSMutableArray *pageViews = [self.pageViews mutableCopy];
        id pageView = pageViews.lastObject;
        [pageViews removeLastObject];
        [pageViews insertObject:pageView atIndex:0];
        self.pageViews = pageViews;

        if ([self.delegate respondsToSelector:@selector(scrollPageViewController:didScrollToIndex:)]) {
            [self.delegate scrollPageViewController:self didScrollToIndex:-1];
        }

        [self refreshPageViewsFrame];
        [self resetContentOffset];
        [self reloadPageViewAtIndex:0];
    } else if (offset > length * (self.count / 2 + 0.5)) {
        // right
        NSMutableArray *pageViews = [self.pageViews mutableCopy];
        id pageView = pageViews.firstObject;
        [pageViews removeObjectAtIndex:0];
        [pageViews addObject:pageView];
        self.pageViews = pageViews;

        if ([self.delegate respondsToSelector:@selector(scrollPageViewController:didScrollToIndex:)]) {
            [self.delegate scrollPageViewController:self didScrollToIndex:1];
        }

        [self refreshPageViewsFrame];
        [self resetContentOffset];
        [self reloadPageViewAtIndex:self.count - 1];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
//        [self didScroll];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    [self didScroll];

//    if ([self.delegate respondsToSelector:@selector(scrollBannerDidEndScrollingAnimation:)]) {
//        [self.delegate scrollBannerDidEndScrollingAnimation:self];
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [self didScroll];

//    if ([self.delegate respondsToSelector:@selector(scrollBannerDidEndDecelerating:)]) {
//        [self.delegate scrollBannerDidEndDecelerating:self];
//    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    ;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    ;
}

#pragma mark - UIScrollViewDelegate

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (!self.isReseting && !CGRectIntersectsRect(scrollView.bounds, self.currentPageView.frame)) {
//        [self didScroll];
//    }
//
//    CGFloat offset = (self.isVertical ? (scrollView.contentOffset.y / scrollView.frame.size.height) : (scrollView.contentOffset.x / scrollView.frame.size.width)) - PDLScrollPageCount / 2;
//    if ([self.delegate respondsToSelector:@selector(scrollPageViewController:didScrollWithOffset:)]) {
//        [self.delegate scrollPageViewController:self didScrollWithOffset:offset];
//    }
//}

@end
