//
//  PDLFormView.h
//  Poodle
//
//  Created by Poodle on 28/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, PDLFormViewScrollPosition) {
    PDLFormViewScrollPositionNone = 0,

    PDLFormViewScrollPositionTop = 1 << 0,
    PDLFormViewScrollPositionCenteredVertically = 1 << 1,
    PDLFormViewScrollPositionBottom = 1 << 2,

    PDLFormViewScrollPositionLeft = 1 << 3,
    PDLFormViewScrollPositionCenteredHorizontally = 1 << 4,
    PDLFormViewScrollPositionRight = 1 << 5
};

@class PDLFormView;

@protocol PDLFormViewDelegate <UIScrollViewDelegate>

@required

- (UIView *)formView:(PDLFormView *)formView viewForColumn:(NSInteger)column row:(NSInteger)row;

@optional

- (NSInteger)numberOfColumnsInFormView:(PDLFormView *)formView;
- (NSInteger)numberOfRowsInFormView:(PDLFormView *)formView;

- (CGSize)formView:(PDLFormView *)formView sizeForColumn:(NSInteger)column row:(NSInteger)row;

- (CGFloat)formView:(PDLFormView *)formView widthForColumn:(NSInteger)column;
- (CGFloat)formView:(PDLFormView *)formView heightForRow:(NSInteger)row;

- (void)formView:(PDLFormView *)formView destinationForColumn:(NSInteger *)column row:(NSInteger *)row;

@end

@interface PDLFormView : UIScrollView

@property (nonatomic, assign) CGFloat columnWidth; // default is 100
@property (nonatomic, assign) CGFloat rowHeight; //  default is 44
@property (nonatomic, weak) id <PDLFormViewDelegate> delegate;
@property (nonatomic, assign) BOOL isScrollHorizontallyForcedEnabled;
@property (nonatomic, assign) BOOL isScrollVerticallyForcedEnabled;

@property (nonatomic, copy) UIColor *separatorColor; // lowest priority
@property (nonatomic, copy) UIColor *innerSeparatorColor; // low priority
@property (nonatomic, copy) UIColor *horizontalSeparatorColor; // high priority
@property (nonatomic, copy) UIColor *verticalSeparatorColor; // high priority
@property (nonatomic, copy) UIColor *outerSeparatorColor; // highest priority

- (void)reloadData;
- (void)setReuseIdentifier:(NSString *)identifier forView:(UIView *)view;
- (UIView *)dequeueReusableViewWithIdentifier:(NSString *)identifier;
- (UIView *)viewForColumn:(NSInteger)column row:(NSInteger)row;
- (NSInteger)columnForView:(UIView *)view;
- (NSInteger)rowForView:(UIView *)view;
- (void)scrollToColumn:(NSInteger)column row:(NSInteger)row atScrollPosition:(PDLFormViewScrollPosition)scrollPosition animated:(BOOL)animated;

@end
