//
//  PDLPageViewController.h
//  Poodle
//
//  Created by Poodle on 2020/10/22.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PDLPageViewController;

@protocol PDLPageViewControllerDelegate <NSObject>

@optional

- (NSInteger)numberOfViewControllersInPageViewController:(PDLPageViewController *)pageViewController;
- (__kindof UIViewController *)pageViewController:(PDLPageViewController *)pageViewController viewControllerAtIndex:(NSInteger)index;

- (void)pageViewControllerWillBeginDragging:(PDLPageViewController *)pageViewController;
- (void)pageViewController:(PDLPageViewController *)pageViewController didScrollToIndex:(CGFloat)index;
- (void)pageViewControllerDidEndScrollingAnimation:(PDLPageViewController *)pageViewController;
- (void)pageViewControllerDidEndDecelerating:(PDLPageViewController *)pageViewController;
- (void)pageViewControllerDidEndDragging:(PDLPageViewController *)pageViewController willDecelerate:(BOOL)decelerate;

@end

@interface PDLPageViewController : UIViewController

@property (nonatomic, weak) id <PDLPageViewControllerDelegate> delegate;
@property (nonatomic, readonly) NSInteger currentIndex;
@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, assign) BOOL bounces;

- (NSString *)reuseIdentifierForViewController:(UIViewController *)viewController;
- (void)setReuseIdentifier:(NSString *)identifier forViewController:(UIViewController *)viewController;
- (__kindof UIViewController *)dequeueReusableViewControllerWithIdentifier:(NSString *)identifier;
- (NSDictionary *)dequeueAllReusableViewControllers;

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
