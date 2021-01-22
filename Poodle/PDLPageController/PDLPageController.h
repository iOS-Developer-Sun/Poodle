//
//  PDLPageController.h
//  Poodle
//
//  Created by Poodle on 2020/10/24.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PDLPageController;

@protocol PDLPageControllerDelegate <NSObject>

@optional

- (NSInteger)numberOfViewsInPageController:(PDLPageController *)pageController;
- (__kindof UIView *)pageController:(PDLPageController *)pageController viewAtIndex:(NSInteger)index;

- (void)pageController:(PDLPageController *)pageController currentIndexDidChange:(NSInteger)originalCurrentIndex;

- (void)pageController:(PDLPageController *)pageController willDisplay:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)pageController:(PDLPageController *)pageController didDisplay:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)pageController:(PDLPageController *)pageController willEndDisplaying:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)pageController:(PDLPageController *)pageController didEndDisplaying:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated;

- (void)pageController:(PDLPageController *)pageController didBeginScrollingAnimation:(BOOL)scrollsRectToVisible;

@end

@interface PDLPageController : NSObject

@property (nonatomic, assign) BOOL isVertical;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, weak) id <PDLPageControllerDelegate> delegate;
@property (nonatomic, assign, readonly) NSInteger numberOfItems;

- (NSString *)reuseIdentifierForView:(UIView *)view;
- (void)setReuseIdentifier:(NSString *)identifier forView:(UIView *)view;
- (UIView *)dequeueReusableViewWithIdentifier:(NSString *)identifier;
- (NSDictionary <NSString *, NSMutableArray <UIView *>*>*)dequeueAllReusableViews;

- (UIView *)viewAtIndex:(NSInteger)index;

- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated;
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
