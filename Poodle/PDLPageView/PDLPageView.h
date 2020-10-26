//
//  PDLPageView.h
//  Poodle
//
//  Created by Poodle on 2020/10/26.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PDLPageView;

@protocol PDLPageViewDelegate <NSObject>

@optional

- (NSInteger)numberOfViewsInPageView:(PDLPageView *)pageView;
- (__kindof UIView *)pageView:(PDLPageView *)pageView viewAtIndex:(NSInteger)index;

- (void)pageViewWillBeginDragging:(PDLPageView *)pageView;
- (void)pageView:(PDLPageView *)pageView didScrollToIndex:(CGFloat)index;
- (void)pageViewDidEndScrollingAnimation:(PDLPageView *)pageView;
- (void)pageViewDidEndDecelerating:(PDLPageView *)pageView;
- (void)pageViewDidEndDragging:(PDLPageView *)pageView willDecelerate:(BOOL)decelerate;

@end

@interface PDLPageView : UIView

@property (nonatomic, weak) id <PDLPageViewDelegate> delegate;
@property (nonatomic, readonly) NSInteger currentIndex;
@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, assign) BOOL bounces;

- (NSString *)reuseIdentifierForView:(UIView *)view;
- (void)setReuseIdentifier:(NSString *)identifier forView:(UIView *)view;
- (__kindof UIView *)dequeueReusableViewWithIdentifier:(NSString *)identifier;
- (NSDictionary <NSString *, NSMutableArray <UIView *>*>*)dequeueAllReusableViews;

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
