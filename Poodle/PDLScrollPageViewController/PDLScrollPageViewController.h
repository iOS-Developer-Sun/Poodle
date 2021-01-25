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

- (UIViewController *)scrollPageViewControllerCurrentViewController:(PDLScrollPageViewController *)scrollPageViewController;

@optional

- (UIViewController *_Nullable)scrollPageViewControllerPreviousViewController:(PDLScrollPageViewController *)scrollPageViewController;
- (UIViewController *_Nullable)scrollPageViewControllerNextViewController:(PDLScrollPageViewController *)scrollPageViewController;

- (void)scrollPageViewControllerDidScrollToPrevious:(PDLScrollPageViewController *)scrollPageViewController;
- (void)scrollPageViewControllerDidScrollToNext:(PDLScrollPageViewController *)scrollPageViewController;
- (void)scrollPageViewController:scrollPageViewController didScrollWithOffset:(CGFloat)offset;

@optional

@end

@interface PDLScrollPageViewController : UIViewController

@property (nonatomic, assign) BOOL isVertical;
@property (nonatomic, weak, readonly) UIScrollView *scrollView;
@property (nonatomic, weak) id <PDLScrollPageViewControllerDelegate> delegate;

- (void)scrollToPreviousAnimated:(BOOL)animated;
- (void)scrollToNextAnimated:(BOOL)animated;

- (void)reloadData;

- (void)reloadPrevious;
- (void)reloadNext;

@end

NS_ASSUME_NONNULL_END
