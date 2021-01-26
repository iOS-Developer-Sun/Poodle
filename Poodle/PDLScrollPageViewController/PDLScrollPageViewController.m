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
@property (nonatomic, assign) BOOL state;

@property (nonatomic, copy) void (^willDisplayAction)(PDLScrollPageViewControllerScrollPageView *pageView);
@property (nonatomic, copy) void (^didDisplayAction)(PDLScrollPageViewControllerScrollPageView *pageView);
@property (nonatomic, copy) void (^willEndDisplayingAction)(PDLScrollPageViewControllerScrollPageView *pageView);
@property (nonatomic, copy) void (^didEndDisplayingAction)(PDLScrollPageViewControllerScrollPageView *pageView);
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) NSNumber *appearing;

@end

@implementation PDLScrollPageViewControllerScrollPageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _needsReload = YES;
    }
    return self;
}

- (void)setNeedsReload:(BOOL)needsReload {
    if (_needsReload == needsReload) {
        return;
    }

    _needsReload = needsReload;
    if (needsReload) {
        self.state = NO;
    } else {
        [self refreshState];
    }
}

- (void)beginAppearanceTransition:(BOOL)isAppearing animated:(BOOL)animated {
    if (self.appearing && self.appearing.boolValue == isAppearing) {
        return;
    }

    [self.viewController beginAppearanceTransition:isAppearing animated:animated];
    self.appearing = @(isAppearing);
}

- (void)endAppearanceTransition {
    if (!self.appearing) {
        return;
    }

    [self.viewController endAppearanceTransition];
    self.appearing = nil;
}

- (void)setState:(BOOL)state {
    if (_state == state) {
        return;
    }

    if (state) {
        if (self.willDisplayAction) {
            self.willDisplayAction(self);
        }
    } else {
        if (self.willEndDisplayingAction) {
            self.willEndDisplayingAction(self);
        }
    }

    _state = state;

    if (self.viewController) {
        if (state) {
            [self addSubview:self.viewController.view];
        } else {
            [self.viewController.view removeFromSuperview];
        }
    }

    if (state) {
        if (self.didDisplayAction) {
            self.didDisplayAction(self);
        }
    } else {
        if (self.didEndDisplayingAction) {
            self.didEndDisplayingAction(self);
        }
    }
}

- (BOOL)refreshState {
    BOOL originalState = self.state;
    BOOL state = CGRectIntersectsRect(self.superview.bounds, self.frame);
    self.state = state;
    return (originalState != state);
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

@property (nonatomic, weak) PDLScrollPageViewControllerScrollPageView *appearingItem;
@property (nonatomic, weak) PDLScrollPageViewControllerScrollPageView *disappearingItem;
@property (nonatomic, assign) BOOL isScrolling;

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
        pageView.willDisplayAction = ^(PDLScrollPageViewControllerScrollPageView *pageView) {
            [weakSelf willDisplay:pageView];
        };
        pageView.didDisplayAction = ^(PDLScrollPageViewControllerScrollPageView *pageView) {
            [weakSelf didDisplay:pageView];
        };
        pageView.willEndDisplayingAction = ^(PDLScrollPageViewControllerScrollPageView *pageView) {
            [weakSelf willEndDisplaying:pageView];
        };
        pageView.didEndDisplayingAction = ^(PDLScrollPageViewControllerScrollPageView *pageView) {
            [weakSelf didEndDisplaying:pageView];
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

- (BOOL)scrollViewHasAnimation {
    id animation = nil;
    @try {
        animation = [self.scrollView valueForKeyPath:@"animation"];
    } @catch (NSException *exception) {
        ;
    } @finally {
        ;
    }
    return animation != nil;
}

- (BOOL)scrollViewAnimated {
    if (self.scrollView.isDragging || self.scrollView.isDecelerating) {
        return YES;
    }

    return [self scrollViewHasAnimation];
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
    NSInteger currentIndex = self.count / 2;
    UIViewController *viewController = [self.delegate scrollPageViewController:self viewControllerAtIndex:index - currentIndex];
    pageView.viewController = viewController;
    pageView.needsReload = NO;
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
    if (!decelerate) {
        self.isScrolling = NO;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.isScrolling = NO;

//    if ([self.delegate respondsToSelector:@selector(scrollBannerDidEndScrollingAnimation:)]) {
//        [self.delegate scrollBannerDidEndScrollingAnimation:self];
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isScrolling = NO;

//    if ([self.delegate respondsToSelector:@selector(scrollBannerDidEndDecelerating:)]) {
//        [self.delegate scrollBannerDidEndDecelerating:self];
//    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isScrolling = YES;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    ;
}

#pragma mark -

- (void)willDisplay:(PDLScrollPageViewControllerScrollPageView *)pageView {
    NSInteger index = [self.pageViews indexOfObject:pageView];
    BOOL viewAnimated = self.scrollViewAnimated || self.isScrolling;
    NSInteger currentIndex = self.count / 2;
    if (currentIndex == index) {
        self.appearingItem = pageView;
        self.disappearingItem = nil;
    } else {
        PDLScrollPageViewControllerScrollPageView *currentPageView = self.pageViews[currentIndex];
        self.appearingItem = pageView;
        self.disappearingItem = currentPageView;
    }

    [self.appearingItem beginAppearanceTransition:YES animated:viewAnimated];
    [self.disappearingItem beginAppearanceTransition:NO animated:viewAnimated];

//    if (_delegateRespondsWillDisplay) {
//        [_delegate pageViewController:self willDisplay:item.viewController atIndex:index animated:animated];
//    }
}

- (void)didDisplay:(PDLScrollPageViewControllerScrollPageView *)pageView {
    if (!self.disappearingItem) {
        [self.appearingItem endAppearanceTransition];
        self.appearingItem = nil;
    }

//    [self addChildViewController:pageView.viewController];

//    if (_delegateRespondsDidDisplay) {
//        [_delegate pageViewController:self didDisplay:item.viewController atIndex:index animated:animated];
//    }
}

- (void)willEndDisplaying:(PDLScrollPageViewControllerScrollPageView *)pageView {
    NSInteger index = [self.pageViews indexOfObject:pageView];
    BOOL viewAnimated = self.scrollViewAnimated || self.isScrolling;
    NSInteger currentIndex = self.count / 2;
    if (currentIndex != index) {
        PDLScrollPageViewControllerScrollPageView *currentPageView = self.pageViews[currentIndex];
        self.appearingItem = currentPageView;
        self.disappearingItem = pageView;
        [self.appearingItem beginAppearanceTransition:YES animated:viewAnimated];
        [self.disappearingItem beginAppearanceTransition:NO animated:viewAnimated];
    } else {
        self.disappearingItem = pageView;
        [self.disappearingItem beginAppearanceTransition:NO animated:viewAnimated];
    }

//    if (_delegateRespondsWillEndDisplaying) {
//        [_delegate pageViewController:self willEndDisplaying:item.viewController atIndex:index animated:animated];
//    }
}

- (void)didEndDisplaying:(PDLScrollPageViewControllerScrollPageView *)pageView {
    [self.appearingItem endAppearanceTransition];
    self.appearingItem = nil;
    [self.disappearingItem endAppearanceTransition];
    self.disappearingItem = nil;

//    [pageView.viewController removeFromParentViewController];

//    if (_delegateRespondsDidEndDisplaying) {
//        [_delegate pageViewController:self didEndDisplaying:item.viewController atIndex:index animated:animated];
//    }
}

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
