//
//  PDLPageViewController.m
//  Poodle
//
//  Created by Poodle on 2020/10/22.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLPageViewController.h"
#import "PDLPageController.h"

@interface PDLPageViewControllerItem : NSObject

@property (nonatomic, strong) __kindof UIViewController *viewController;

@property (nonatomic, strong) NSNumber *appearing;

@end

@implementation PDLPageViewControllerItem

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

@end

@interface PDLPageViewController () <PDLPageControllerDelegate, UIScrollViewDelegate> {
    BOOL _delegateRespondsNumberOfViewControllers;
    BOOL _delegateRespondsViewControllerAtIndex;

    BOOL _delegateRespondsCurrentIndexDidChange;

    BOOL _delegateRespondsWillDisplay;
    BOOL _delegateRespondsDidDisplay;
    BOOL _delegateRespondsWillEndDisplaying;
    BOOL _delegateRespondsDidEndDisplaying;

    BOOL _delegateRespondsWillBeginDragging;
    BOOL _delegateRespondsDidEndScrollingAnimation;
    BOOL _delegateRespondsDidScrollToIndex;
    BOOL _delegateRespondsDidEndDecelerating;
    BOOL _delegateRespondsDidEndDraggingWillDecelerate;
}

@property (nonatomic, strong) PDLPageController *pageController;
@property (nonatomic, strong) NSMapTable *items;

@property (nonatomic, weak) PDLPageViewControllerItem *appearingItem;
@property (nonatomic, weak) PDLPageViewControllerItem *disappearingItem;
@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, assign) CGSize contentSize;

@end

@implementation PDLPageViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _pageController = [[PDLPageController alloc] init];
        _pageController.delegate = self;
        _items = [NSMapTable weakToStrongObjectsMapTable];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIScrollView *scrollView = self.pageController.scrollView;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.frame = self.view.bounds;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    self.contentSize = scrollView.bounds.size;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGSize contentSize = self.scrollView.bounds.size;
    if (!CGSizeEqualToSize(self.contentSize, contentSize)) {
        self.contentSize = contentSize;
        [self reloadData];
    }
}

- (BOOL)isVertical {
    return self.pageController.isVertical;
}

- (void)setIsVertical:(BOOL)isVertical {
    self.pageController.isVertical = isVertical;
}

- (void)setDelegate:(id<PDLPageViewControllerDelegate>)delegate {
    if (_delegate == delegate) {
        return;
    }

    _delegate = delegate;

    _delegateRespondsNumberOfViewControllers = [delegate respondsToSelector:@selector(numberOfViewControllersInPageViewController:)];
    _delegateRespondsViewControllerAtIndex = [delegate respondsToSelector:@selector(pageViewController:viewControllerAtIndex:)];

    _delegateRespondsCurrentIndexDidChange = [delegate respondsToSelector:@selector(pageViewController:currentIndexDidChange:)];

    _delegateRespondsWillDisplay = [delegate respondsToSelector:@selector(pageViewController:willDisplay:atIndex:animated:)];
    _delegateRespondsDidDisplay = [delegate respondsToSelector:@selector(pageViewController:didDisplay:atIndex:animated:)];
    _delegateRespondsWillEndDisplaying = [delegate respondsToSelector:@selector(pageViewController:willEndDisplaying:atIndex:animated:)];
    _delegateRespondsDidEndDisplaying = [delegate respondsToSelector:@selector(pageViewController:didEndDisplaying:atIndex:animated:)];

    _delegateRespondsWillBeginDragging = [delegate respondsToSelector:@selector(pageViewControllerWillBeginDragging:)];
    _delegateRespondsDidEndScrollingAnimation = [delegate respondsToSelector:@selector(pageViewControllerDidEndScrollingAnimation:)];
    _delegateRespondsDidScrollToIndex = [delegate respondsToSelector:@selector(pageViewController:didScrollToIndex:)];
    _delegateRespondsDidEndDecelerating = [delegate respondsToSelector:@selector(pageViewControllerDidEndDecelerating:)];
    _delegateRespondsDidEndDraggingWillDecelerate  = [delegate respondsToSelector:@selector(pageViewControllerDidEndDragging:willDecelerate:)];

    [self.pageController reloadData];
}

#pragma mark - Private methods

- (PDLPageViewControllerItem *)itemForView:(UIView *)view {
    return [self.items objectForKey:view];
}

- (void)setItem:(PDLPageViewControllerItem *)item forView:(UIView *)view {
    [self.items setObject:item forKey:view];
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

- (NSInteger)numberOfViewControllers {
    return self.pageController.numberOfItems;
}

#pragma mark - Public methods

- (NSString *)reuseIdentifierForViewController:(UIViewController *)viewController {
    return [self.pageController reuseIdentifierForView:viewController.view];
}

- (void)setReuseIdentifier:(NSString *)identifier forViewController:(UIViewController *)viewController {
    [self.pageController setReuseIdentifier:identifier forView:viewController.view];
}

- (__kindof UIViewController *)dequeueReusableViewControllerWithIdentifier:(NSString *)identifier {
    UIView *view = [self.pageController dequeueReusableViewWithIdentifier:identifier];
    if (!view) {
        return nil;
    }

    PDLPageViewControllerItem *item = [self itemForView:view];
    return item.viewController;
}

- (NSDictionary *)dequeueAllReusableViewControllers {
    NSDictionary <NSString *, NSMutableArray <UIView *>*>*reusableItems = [self.pageController dequeueAllReusableViews];
    for (NSString *key in reusableItems) {
        NSMutableArray *views = reusableItems[key];
        NSMutableArray *items = [NSMutableArray array];
        for (UIView *view in views) {
            PDLPageViewControllerItem *item = [self itemForView:view];
            [items addObject:item];
        }
        [views removeAllObjects];
        [views addObjectsFromArray:items];
    }
    return reusableItems;
}

- (__kindof UIViewController *)viewControllerAtIndex:(NSInteger)index {
    UIView *view = [self.pageController viewAtIndex:index];
    PDLPageViewControllerItem *item = [self itemForView:view];
    return item.viewController;
}

- (__kindof UIViewController *)currentViewController {
    return [self viewControllerAtIndex:self.currentIndex];
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
    if (_delegateRespondsNumberOfViewControllers) {
        number = [_delegate numberOfViewControllersInPageViewController:self];
    }
    return number;
}

- (__kindof UIView *)pageController:(PDLPageController *)pageController viewAtIndex:(NSInteger)index {
    UIView *view = nil;
    if (_delegateRespondsViewControllerAtIndex) {
        UIViewController *viewController = [_delegate pageViewController:self viewControllerAtIndex:index];
        view = viewController.view;
        PDLPageViewControllerItem *item = [self itemForView:view];
        if (!item) {
            item = [[PDLPageViewControllerItem alloc] init];
            item.viewController = viewController;
            [self setItem:item forView:view];
        }
    }
    return view;
}

- (void)pageController:(PDLPageController *)pageController currentIndexDidChange:(NSInteger)originalCurrentIndex {
    if (_delegateRespondsCurrentIndexDidChange) {
        [_delegate pageViewController:self currentIndexDidChange:originalCurrentIndex];
    }
}

- (void)pageController:(PDLPageController *)pageController willDisplay:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated {
    BOOL viewAnimated = animated || self.isScrolling;
    PDLPageViewControllerItem *item = [self itemForView:view];
    if (self.currentIndex == index) {
        self.appearingItem = item;
        self.disappearingItem = nil;
    } else {
        UIView *currentView = [pageController viewAtIndex:self.currentIndex];
        PDLPageViewControllerItem *currentItem = [self itemForView:currentView];
        self.appearingItem = item;
        self.disappearingItem = currentItem;
    }

    [self.appearingItem beginAppearanceTransition:YES animated:viewAnimated];
    [self.disappearingItem beginAppearanceTransition:NO animated:viewAnimated];

    if (_delegateRespondsWillDisplay) {
        [_delegate pageViewController:self willDisplay:item.viewController atIndex:index animated:animated];
    }
}

- (void)pageController:(PDLPageController *)pageController didDisplay:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated {
    if (!self.disappearingItem) {
        [self.appearingItem endAppearanceTransition];
        self.appearingItem = nil;
    }

    PDLPageViewControllerItem *item = [self itemForView:view];
    [self addChildViewController:item.viewController];

    if (_delegateRespondsDidDisplay) {
        [_delegate pageViewController:self didDisplay:item.viewController atIndex:index animated:animated];
    }
}

- (void)pageController:(PDLPageController *)pageController willEndDisplaying:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated {
    BOOL viewAnimated = animated || self.isScrolling;
    PDLPageViewControllerItem *item = [self itemForView:view];
    UIView *currentView = [pageController viewAtIndex:self.currentIndex];
    PDLPageViewControllerItem *currentItem = [self itemForView:currentView];
    if (item != currentItem) {
        self.appearingItem = currentItem;
        self.disappearingItem = item;
        [self.appearingItem beginAppearanceTransition:YES animated:viewAnimated];
        [self.disappearingItem beginAppearanceTransition:NO animated:viewAnimated];
    } else {
        self.disappearingItem = item;
        [self.disappearingItem beginAppearanceTransition:NO animated:viewAnimated];
    }

    if (_delegateRespondsWillEndDisplaying) {
        [_delegate pageViewController:self willEndDisplaying:item.viewController atIndex:index animated:animated];
    }
}

- (void)pageController:(PDLPageController *)pageController didEndDisplaying:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated {
    [self.appearingItem endAppearanceTransition];
    self.appearingItem = nil;
    [self.disappearingItem endAppearanceTransition];
    self.disappearingItem = nil;

    PDLPageViewControllerItem *item = [self itemForView:view];
    [item.viewController removeFromParentViewController];

    if (_delegateRespondsDidEndDisplaying) {
        [_delegate pageViewController:self didEndDisplaying:item.viewController atIndex:index animated:animated];
    }
}

- (void)pageController:(PDLPageController *)pageController didBeginScrollingAnimation:(BOOL)scrollsRectToVisible {
    self.isScrolling = YES;
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
        [_delegate pageViewController:self didScrollToIndex:ratio];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isScrolling = YES;
    if (_delegateRespondsWillBeginDragging) {
        [_delegate pageViewControllerWillBeginDragging:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (_delegateRespondsDidEndScrollingAnimation) {
        [_delegate pageViewControllerDidEndScrollingAnimation:self];
    }
    self.isScrolling = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_delegateRespondsDidEndDecelerating) {
        [_delegate pageViewControllerDidEndDecelerating:self];
    }
    self.isScrolling = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_delegateRespondsDidEndDraggingWillDecelerate) {
        [_delegate pageViewControllerDidEndDragging:self willDecelerate:decelerate];
    }
    if (!decelerate) {
        self.isScrolling = NO;
    }
}

@end
