//
//  PDLScrollPageViewController.m
//  Poodle
//
//  Created by Poodle on 16-1-19.
//
//

#import "PDLScrollPageViewController.h"

@interface PDLScrollPageViewControllerItem : NSObject

@end

static const NSInteger PDLScrollPageCount = 3;

@interface PDLScrollPageViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, strong) UIViewController *currentPage;
@property (nonatomic, strong) UIViewController *previousPage;
@property (nonatomic, strong) UIViewController *nextPage;

@property (nonatomic, assign) BOOL isReseting;

@end

@implementation PDLScrollPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
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
}

- (UIScrollView *)scrollView {
    [self loadViewIfNeeded];
    return _scrollView;
}

- (void)setIsVertical:(BOOL)isVertical {
    if (_isVertical == isVertical) {
        return;
    }

    _isVertical = isVertical;
//    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!self.currentPage) {
        [self reloadData];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (!self.currentPage) {
        [self reloadData];
    } else {
        [self resetScrollView];
    }
}

- (void)scrollToPreviousAnimated:(BOOL)animated {
    if (!self.previousPage) {
        return;
    }

    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:animated];
}

- (void)scrollToNextAnimated:(BOOL)animated {
    if (!self.nextPage) {
        return;
    }

    CGRect frame = self.scrollView.frame;
    [self.scrollView setContentOffset:CGPointMake(self.isVertical ? 0 : 2 * frame.size.width, self.isVertical ? 2 * frame.size.height : 0) animated:animated];
}

- (void)reloadData {
    [self reloadCurrent];
    [self reloadPrevious];
    [self reloadNext];
    [self resetScrollView];
}

- (void)enqueue:(UIViewController *)item {
    ;
}

- (void)setCurrentPage:(UIViewController *)currentPage {
    if (_currentPage == currentPage) {
        return;
    }

    [_currentPage.view removeFromSuperview];
    [_currentPage removeFromParentViewController];

    _currentPage = currentPage;

    if (currentPage) {
        [self.scrollView addSubview:currentPage.view];
        [self addChildViewController:currentPage];
    }
}

- (void)setPreviousPage:(UIViewController *)previousPage {
    if (_previousPage == previousPage) {
        return;
    }

    [_previousPage.view removeFromSuperview];
    [_previousPage removeFromParentViewController];

    _previousPage = previousPage;

    if (previousPage) {
        [self.scrollView addSubview:previousPage.view];
        [self addChildViewController:previousPage];
    }
}

- (void)setNextPage:(UIViewController *)nextPage {
    if (_nextPage == nextPage) {
        return;
    }

    [_nextPage.view removeFromSuperview];
    [_nextPage removeFromParentViewController];

    _nextPage = nextPage;

    if (nextPage) {
        [self.scrollView addSubview:nextPage.view];
        [self addChildViewController:nextPage];
    }
}

- (void)reloadCurrent {
    [self enqueue:self.currentPage];
    self.currentPage = nil;

    if ([self.delegate respondsToSelector:@selector(scrollPageViewControllerCurrentViewController:)]) {
        UIViewController *viewController = [self.delegate scrollPageViewControllerCurrentViewController:self];
        self.currentPage = viewController;
    }
}

- (void)reloadPrevious {
    [self enqueue:self.previousPage];
    self.previousPage = nil;

    if ([self.delegate respondsToSelector:@selector(scrollPageViewControllerPreviousViewController:)]) {
        UIViewController *viewController = [self.delegate scrollPageViewControllerPreviousViewController:self];
        self.previousPage = viewController;
    }
}

- (void)reloadNext {
    [self enqueue:self.nextPage];
    self.nextPage = nil;

    if ([self.delegate respondsToSelector:@selector(scrollPageViewControllerNextViewController:)]) {
        UIViewController *viewController = [self.delegate scrollPageViewControllerNextViewController:self];
        self.nextPage = viewController;
    }
}

- (void)resetScrollView {
    self.isReseting = YES;
    self.scrollView.frame = self.view.bounds;
    BOOL isVertical = self.isVertical;
    CGSize size = self.scrollView.frame.size;
    CGFloat length = isVertical ? size.height : size.width;
    CGFloat previousInset = self.previousPage ? 0 : -length;
    CGFloat nextInset = self.nextPage ? 0 : -length;
    self.scrollView.contentInset = self.isVertical ? UIEdgeInsetsMake(previousInset, 0, nextInset, 0) : UIEdgeInsetsMake(0, previousInset, 0, nextInset);

    NSInteger count = 3;
    self.scrollView.contentSize = isVertical ? CGSizeMake(size.width, size.height * count) : CGSizeMake(size.width * count, size.height);
    self.scrollView.contentOffset = isVertical ? CGPointMake(0, size.height) : CGPointMake(size.width, 0);

    if (isVertical) {
        self.previousPage.view.frame = CGRectMake(0, 0 * size.height, size.width, size.height);
        self.currentPage.view.frame = CGRectMake(0, 1 * size.height, size.width, size.height);
        self.nextPage.view.frame = CGRectMake(0, 2 * size.height, size.width, size.height);
    } else {
        self.previousPage.view.frame = CGRectMake(0 * size.width, 0, size.width, size.height);
        self.currentPage.view.frame = CGRectMake(1 * size.width, 0, size.width, size.height);
        self.nextPage.view.frame = CGRectMake(2 * size.width, 0, size.width, size.height);
    }

    self.isReseting = NO;
}

- (void)didScroll {
    CGRect frame = self.scrollView.frame;
    BOOL isVertical = self.isVertical;
    CGFloat length = isVertical ? frame.size.height : frame.size.width;
    CGFloat offset = isVertical ?  self.scrollView.contentOffset.y : self.scrollView.contentOffset.x;
    if (offset < length * (PDLScrollPageCount / 2 - 0.5)) {
        UIViewController *viewController = self.nextPage;
        _nextPage = self.currentPage;
        _currentPage = self.previousPage;
        _previousPage = viewController;
        if ([self.delegate respondsToSelector:@selector(scrollPageViewControllerDidScrollToPrevious:)]) {
            [self.delegate scrollPageViewControllerDidScrollToPrevious:self];
        }
        [self reloadPrevious];
        [self resetScrollView];
    } else if (offset > length * (PDLScrollPageCount / 2 + 0.5)) {
        UIViewController *viewController = self.previousPage;
        _previousPage = self.currentPage;
        _currentPage = self.nextPage;
        _nextPage = viewController;
        if ([self.delegate respondsToSelector:@selector(scrollPageViewControllerDidScrollToNext:)]) {
            [self.delegate scrollPageViewControllerDidScrollToNext:self];
        }
        [self reloadNext];
        [self resetScrollView];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isReseting && !CGRectIntersectsRect(scrollView.bounds, self.currentPage.view.frame)) {
        [self didScroll];
    }

    CGFloat offset = (self.isVertical ? (scrollView.contentOffset.y / scrollView.frame.size.height) : (scrollView.contentOffset.x / scrollView.frame.size.width)) - PDLScrollPageCount / 2;
    if ([self.delegate respondsToSelector:@selector(scrollPageViewController:didScrollWithOffset:)]) {
        [self.delegate scrollPageViewController:self didScrollWithOffset:offset];
    }
}

@end
