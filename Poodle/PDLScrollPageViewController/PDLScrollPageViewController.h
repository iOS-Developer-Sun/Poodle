//
//  PDLScrollPageViewController.h
//  Poodle
//
//  Created by Poodle on 16-1-19.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PDLScrollPageViewController;

@protocol PDLScrollPageViewControllerDelegate <NSObject>

- (__kindof UIViewController *_Nullable)scrollPageViewController:(PDLScrollPageViewController *)scrollPageViewController viewControllerAtIndex:(NSInteger)index;

@optional

- (void)scrollPageViewController:(PDLScrollPageViewController *)scrollPageViewController didScrollToIndex:(NSInteger)index;
- (void)scrollPageViewController:(PDLScrollPageViewController *)scrollPageViewController didScrollWithOffset:(CGFloat)offset;

- (void)scrollPageViewController:(PDLScrollPageViewController *)scrollPageViewController didEnqueue:(__kindof UIViewController *)viewController;

- (void)scrollPageViewController:(PDLScrollPageViewController *)scrollPageViewController willDisplay:(__kindof UIViewController *)viewController atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)scrollPageViewController:(PDLScrollPageViewController *)scrollPageViewController didDisplay:(__kindof UIViewController *)viewController atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)scrollPageViewController:(PDLScrollPageViewController *)scrollPageViewController willEndDisplaying:(__kindof UIViewController *)viewController atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)scrollPageViewController:(PDLScrollPageViewController *)scrollPageViewController didEndDisplaying:(__kindof UIViewController *)viewController atIndex:(NSInteger)index animated:(BOOL)animated;

@optional

@end

@interface PDLScrollPageViewController : UIViewController

@property (nonatomic, assign) BOOL isVertical;
@property (nonatomic, weak, readonly) UIScrollView *scrollView;
@property (nonatomic, weak) id <PDLScrollPageViewControllerDelegate> delegate;

- (__kindof UIViewController *)viewControllerAtIndex:(NSInteger)index;

- (void)scrollToPreviousAnimated:(BOOL)animated;
- (void)scrollToNextAnimated:(BOOL)animated;

- (void)reloadData;
- (void)reloadPrevious;
- (void)reloadNext;

- (NSString *)reuseIdentifierForViewController:(UIViewController *)viewController;
- (void)setReuseIdentifier:(NSString *)identifier forViewController:(UIViewController *)viewController;
- (__kindof UIViewController *)dequeueReusableViewControllerWithIdentifier:(NSString *)identifier;
- (NSDictionary <NSString *, NSMutableArray <UIViewController *>*>*)dequeueAllReusableViewControllers;

@end

NS_ASSUME_NONNULL_END
