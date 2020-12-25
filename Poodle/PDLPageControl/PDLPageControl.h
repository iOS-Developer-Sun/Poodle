//
//  PDLPageControl.h
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PDLPageControlItemView <NSObject>

@optional

@property (nonatomic, assign) BOOL isCurrentPageControlItemView;

@end

@class PDLPageControl;

@protocol PDLPageControlDelegate <NSObject>

@optional

- (void)pageControl:(PDLPageControl *)pageControl didCreateItemView:(__kindof UIView <PDLPageControlItemView> *)itemView;
- (void)pageControl:(PDLPageControl *)pageControl willDestroyItemView:(__kindof UIView <PDLPageControlItemView> *)itemView;
- (void)pageControl:(PDLPageControl *)pageControl getCurrent:(BOOL *)isCurrent forItemView:(__kindof UIView <PDLPageControlItemView> *)itemView;
- (void)pageControl:(PDLPageControl *)pageControl setCurrent:(BOOL)isCurrent forItemView:(__kindof UIView <PDLPageControlItemView> *)itemView;

@end

@interface PDLPageControl : UIView

@property (nonatomic, assign) Class itemViewClass; // Default is PDLPageControlItemView class.
@property (nonatomic, weak) id <PDLPageControlDelegate> delegate;
@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage; // Default is -1. Value is pinned to 0..numberOfPages-1 when numberOfPages is not 0
@property (nonatomic, assign) BOOL hidesForSinglePage;
@property (nonatomic, assign) CGFloat itemViewMargin; // Default is 8
@property (nonatomic, assign) CGSize itemViewSize; // The size of each indicator. Default is (8, 8).
@property (nonatomic, assign) CGSize currentItemViewSize; // The size of the current indicator. Default is (4, 4).

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated;

@end


@interface PDLPageControlItemView : UIView <PDLPageControlItemView>

@end

NS_ASSUME_NONNULL_END
