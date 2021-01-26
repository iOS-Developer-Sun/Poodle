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

- (UIViewController *_Nullable)scrollPageViewController:(PDLScrollPageViewController *)scrollPageViewController viewControllerAtIndex:(NSInteger)index;

@optional

- (void)scrollPageViewController:(PDLScrollPageViewController *)scrollPageViewController didScrollToIndex:(NSInteger)index;
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

@end

NS_ASSUME_NONNULL_END
