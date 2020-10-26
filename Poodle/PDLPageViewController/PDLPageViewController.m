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
}

- (void)setDelegate:(id<PDLPageViewControllerDelegate>)delegate {
    if (_delegate == delegate) {
        return;
    }

    _delegate = delegate;

    _delegateRespondsNumberOfViewControllers = [delegate respondsToSelector:@selector(numberOfViewControllersInPageViewController:)];
    _delegateRespondsViewControllerAtIndex = [delegate respondsToSelector:@selector(pageViewController:viewControllerAtIndex:)];

    _delegateRespondsWillBeginDragging = [delegate respondsToSelector:@selector(pageViewControllerWillBeginDragging:)];
    _delegateRespondsDidEndScrollingAnimation = [delegate respondsToSelector:@selector(pageViewControllerDidEndScrollingAnimation:)];
    _delegateRespondsDidScrollToIndex = [delegate respondsToSelector:@selector(pageViewController:didScrollToIndex:)];
    _delegateRespondsDidEndDecelerating = [delegate respondsToSelector:@selector(pageViewControllerDidEndDecelerating:)];
    _delegateRespondsDidEndDraggingWillDecelerate  = [delegate respondsToSelector:@selector(pageViewControllerDidEndDragging:willDecelerate:)];
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

- (BOOL)isScrollEnabled {
    return self.pageController.scrollView.scrollEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    self.pageController.scrollView.scrollEnabled = scrollEnabled;
}

- (BOOL)bounces {
    return self.pageController.scrollView.bounces;
}

- (void)setBounces:(BOOL)bounces {
    self.pageController.scrollView.bounces = bounces;
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


- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    [self.pageController scrollToIndex:index animated:animated];
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
}

- (void)pageController:(PDLPageController *)pageController didDisplay:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated {
    if (!self.disappearingItem) {
        [self.appearingItem endAppearanceTransition];
        self.appearingItem = nil;
    }

    PDLPageViewControllerItem *item = [self itemForView:view];
    [self addChildViewController:item.viewController];
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
}

- (void)pageController:(PDLPageController *)pageController didEndDisplaying:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated {
    [self.appearingItem endAppearanceTransition];
    self.appearingItem = nil;
    [self.disappearingItem endAppearanceTransition];
    self.disappearingItem = nil;

    PDLPageViewControllerItem *item = [self itemForView:view];
    [item.viewController removeFromParentViewController];
}

- (void)pageController:(PDLPageController *)pageController didBeginScrollingAnimation:(BOOL)scrollsRectToVisible {
    self.isScrolling = YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    CGRect frame = scrollView.frame;
    CGFloat width = CGRectGetWidth(frame);
    if (width == 0) {
        return;
    }
    CGFloat ratio = contentOffset.x / width;

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
