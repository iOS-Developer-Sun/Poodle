//
//  PDLKeyboardNotificationObserver.h
//  Poodle
//
//  Created by Poodle on 07/03/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PDLCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

@optional

- (UIColor *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout backgroundColorForSectionAtIndex:(NSInteger)section;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout backgroundInsetsForSectionAtIndex:(NSInteger)section;

@end

typedef NS_ENUM(NSInteger, PDLCollectionViewFlowLayoutAlignment) {
    PDLCollectionViewFlowLayoutAlignmentCenter = 0,
    PDLCollectionViewFlowLayoutAlignmentLeft,
    PDLCollectionViewFlowLayoutAlignmentRight,
    PDLCollectionViewFlowLayoutAlignmentTop,
    PDLCollectionViewFlowLayoutAlignmentBottom,
    PDLCollectionViewFlowLayoutAlignmentLeftTop,
    PDLCollectionViewFlowLayoutAlignmentLeftBottom,
    PDLCollectionViewFlowLayoutAlignmentRightTop,
    PDLCollectionViewFlowLayoutAlignmentRightBottom,

    PDLCollectionViewFlowLayoutAlignmentCount,
};

@interface PDLCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) PDLCollectionViewFlowLayoutAlignment alignment;

@end
