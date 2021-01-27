//
//  PDLScrollPageViewController.m
//  Poodle
//
//  Created by Poodle on 16-1-19.
//
//

#import "PDLScrollPageViewController.h"
#import "PDLReuseItemManager.h"

@interface PDLScrollPageViewControllerScrollPageView : UIView

@property (nonatomic, assign) BOOL needsReload;
@property (nonatomic, assign) BOOL visible;

@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) NSNumber *appearing;

@property (nonatomic, copy) void (^willDisplayAction)(PDLScrollPageViewControllerScrollPageView *pageView);
@property (nonatomic, copy) void (^didDisplayAction)(PDLScrollPageViewControllerScrollPageView *pageView);
@property (nonatomic, copy) void (^willEndDisplayingAction)(PDLScrollPageViewControllerScrollPageView *pageView);
@property (nonatomic, copy) void (^didEndDisplayingAction)(PDLScrollPageViewControllerScrollPageView *pageView);

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
        self.visible = NO;
    } else {
        [self refreshVisible];
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

- (void)setVisible:(BOOL)visible {
    if (_visible == visible) {
        return;
    }

    if (visible) {
        if (self.willDisplayAction) {
            self.willDisplayAction(self);
        }
    } else {
        if (self.willEndDisplayingAction) {
            self.willEndDisplayingAction(self);
        }
    }

    _visible = visible;

    if (self.viewController) {
        if (visible) {
            [self addSubview:self.viewController.view];
        } else {
            [self.viewController.view removeFromSuperview];
        }
    }

    if (visible) {
        if (self.didDisplayAction) {
            self.didDisplayAction(self);
        }
    } else {
        if (self.didEndDisplayingAction) {
            self.didEndDisplayingAction(self);
        }
    }
}

- (BOOL)refreshVisible {
    BOOL originalVisible = self.visible;
    BOOL visible = CGRectIntersectsRect(self.superview.bounds, self.frame);
    self.visible = visible;
    return (originalVisible != visible);
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

#pragma mark -

static const NSInteger PDLScrollPageCount = 3;

@interface PDLScrollPageViewController () <UIScrollViewDelegate> {
    BOOL _delegateRespondsDidScrollToIndex;
    BOOL _delegateRespondsDidScrollWithOffset;

    BOOL _delegateRespondsWillDisplay;
    BOOL _delegateRespondsDidDisplay;
    BOOL _delegateRespondsWillEndDisplaying;
    BOOL _delegateRespondsDidEndDisplaying;
}

@property (nonatomic, weak) PDLScrollPageViewControllerScrollView *scrollView;
@property (nonatomic, copy) NSArray <PDLScrollPageViewControllerScrollPageView *> *pageViews;

@property (nonatomic, weak) PDLScrollPageViewControllerScrollPageView *appearingItem;
@property (nonatomic, weak) PDLScrollPageViewControllerScrollPageView *disappearingItem;
@property (nonatomic, assign) BOOL isScrolling;

@property (nonatomic, strong) PDLReuseItemManager *reuseItemManager;

@end

@implementation PDLScrollPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.reuseItemManager = [[PDLReuseItemManager alloc] init];

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
        PDLScrollPageViewControllerScrollPageView *pageView = [[PDLScrollPageViewControllerScrollPageView alloc] init];
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

- (void)setDelegate:(id<PDLScrollPageViewControllerDelegate>)delegate {
    if (_delegate == delegate) {
        return;
    }

    _delegate = delegate;

    _delegateRespondsDidScrollToIndex = [delegate respondsToSelector:@selector(scrollPageViewController:didScrollToIndex:)];
    _delegateRespondsDidScrollWithOffset = [delegate respondsToSelector:@selector(scrollPageViewController:didScrollWithOffset:)];

    _delegateRespondsWillDisplay = [delegate respondsToSelector:@selector(scrollPageViewController:willDisplay:atIndex:animated:)];
    _delegateRespondsDidDisplay = [delegate respondsToSelector:@selector(scrollPageViewController:didDisplay:atIndex:animated:)];
    _delegateRespondsWillEndDisplaying = [delegate respondsToSelector:@selector(scrollPageViewController:willEndDisplaying:atIndex:animated:)];
    _delegateRespondsDidEndDisplaying = [delegate respondsToSelector:@selector(scrollPageViewController:didEndDisplaying:atIndex:animated:)];
}

- (void)scrollViewDidLayoutSubviews {
    if (!CGSizeEqualToSize(self.scrollView.bounds.size, self.pageViews.firstObject.bounds.size)) {
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
        changed |= [pageView refreshVisible];
    }

    if (changed) {
        [self resetCurrent];
    }
    [self refreshContentInset];
}

- (void)reloadPageViewAtIndex:(NSInteger)index {
    PDLScrollPageViewControllerScrollPageView *pageView = self.pageViews[index];
    UIViewController *viewController = pageView.viewController;
    if (viewController) {
        [self enqueue:viewController];
    }
    NSInteger currentIndex = self.count / 2;
    viewController = [_delegate scrollPageViewController:self viewControllerAtIndex:index - currentIndex];
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
    for (NSInteger i = 0; i < self.count; i++) {
        PDLScrollPageViewControllerScrollPageView *pageView = self.pageViews[i];
        pageView.needsReload = YES;
    }
    [self.scrollView setNeedsLayout];
}

- (void)reloadPrevious {
    NSInteger index = self.count / 2 - 1;
    PDLScrollPageViewControllerScrollPageView *pageView = self.pageViews[index];
    pageView.needsReload = YES;
    [self.scrollView setNeedsLayout];
}

- (void)reloadNext {
    NSInteger index = self.count / 2 + 1;
    PDLScrollPageViewControllerScrollPageView *pageView = self.pageViews[index];
    pageView.needsReload = YES;
    [self.scrollView setNeedsLayout];
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

- (void)resetCurrent {
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

        if (_delegateRespondsDidScrollToIndex) {
            [_delegate scrollPageViewController:self didScrollToIndex:-1];
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

        if (_delegateRespondsDidScrollToIndex) {
            [_delegate scrollPageViewController:self didScrollToIndex:1];
        }

        [self refreshPageViewsFrame];
        [self resetContentOffset];
        [self reloadPageViewAtIndex:self.count - 1];
    }
}

#pragma mark - Reuse

- (NSString *)reuseIdentifierForViewController:(UIViewController *)viewController {
    return [self.reuseItemManager reuseIdentifierForItem:viewController];
}

- (void)setReuseIdentifier:(NSString *)identifier forViewController:(UIViewController *)viewController {
    [self.reuseItemManager setReuseIdentifier:identifier forItem:viewController];
}

- (void)enqueue:(UIViewController *)item {
    [self.reuseItemManager enqueue:item];
}

- (__kindof UIViewController *)dequeueReusableViewControllerWithIdentifier:(NSString *)identifier {
    return [self.reuseItemManager dequeueReusableItemWithIdentifier:identifier];
}

- (NSDictionary <NSString *, NSMutableArray <UIViewController *>*>*)dequeueAllReusableViewControllers {
    return [self.reuseItemManager dequeueAllReusableItems];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.isScrolling = NO;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.isScrolling = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isScrolling = NO;
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
    NSInteger currentIndex = self.count / 2;
    BOOL viewAnimated = self.scrollViewAnimated || self.isScrolling;

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

    if (_delegateRespondsWillDisplay && pageView.viewController) {
        [_delegate scrollPageViewController:self willDisplay:pageView.viewController atIndex:index - currentIndex animated:viewAnimated];
    }
}

- (void)didDisplay:(PDLScrollPageViewControllerScrollPageView *)pageView {
    NSInteger index = [self.pageViews indexOfObject:pageView];
    NSInteger currentIndex = self.count / 2;
    BOOL viewAnimated = self.scrollViewAnimated || self.isScrolling;

    if (!self.disappearingItem) {
        [self.appearingItem endAppearanceTransition];
        self.appearingItem = nil;
    }

    if (pageView.viewController) {
        [self addChildViewController:pageView.viewController];
    }

    if (_delegateRespondsDidDisplay && pageView.viewController) {
        [_delegate scrollPageViewController:self didDisplay:pageView.viewController atIndex:index - currentIndex animated:viewAnimated];
    }
}

- (void)willEndDisplaying:(PDLScrollPageViewControllerScrollPageView *)pageView {
    NSInteger index = [self.pageViews indexOfObject:pageView];
    NSInteger currentIndex = self.count / 2;
    BOOL viewAnimated = self.scrollViewAnimated || self.isScrolling;

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

    if (_delegateRespondsWillEndDisplaying && pageView.viewController) {
        [_delegate scrollPageViewController:self willEndDisplaying:pageView.viewController atIndex:index - currentIndex animated:viewAnimated];
    }
}

- (void)didEndDisplaying:(PDLScrollPageViewControllerScrollPageView *)pageView {
    NSInteger index = [self.pageViews indexOfObject:pageView];
    NSInteger currentIndex = self.count / 2;
    BOOL viewAnimated = self.scrollViewAnimated || self.isScrolling;

    [self.appearingItem endAppearanceTransition];
    self.appearingItem = nil;
    [self.disappearingItem endAppearanceTransition];
    self.disappearingItem = nil;

    [pageView.viewController removeFromParentViewController];

    if (_delegateRespondsDidEndDisplaying && pageView.viewController) {
        [_delegate scrollPageViewController:self didEndDisplaying:pageView.viewController atIndex:index - currentIndex animated:viewAnimated];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = (self.isVertical ? (scrollView.contentOffset.y / scrollView.frame.size.height) : (scrollView.contentOffset.x / scrollView.frame.size.width)) - PDLScrollPageCount / 2;
    if (_delegateRespondsDidScrollWithOffset) {
        [_delegate scrollPageViewController:self didScrollWithOffset:offset];
    }
}

@end
