//
//  PDLCollectionViewFlowLayout.m
//  Poodle
//
//  Created by Poodle on 07/03/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLCollectionViewFlowLayout.h"

static BOOL isAlignmentLeft(PDLCollectionViewFlowLayoutAlignment alignment) {
    return (alignment == PDLCollectionViewFlowLayoutAlignmentLeft) || (alignment == PDLCollectionViewFlowLayoutAlignmentLeftTop) || (alignment == PDLCollectionViewFlowLayoutAlignmentLeftBottom);
}

static BOOL isAlignmentRight(PDLCollectionViewFlowLayoutAlignment alignment) {
    return (alignment == PDLCollectionViewFlowLayoutAlignmentRight) || (alignment == PDLCollectionViewFlowLayoutAlignmentRightTop) || (alignment == PDLCollectionViewFlowLayoutAlignmentRightBottom);
}

static BOOL isAlignmentTop(PDLCollectionViewFlowLayoutAlignment alignment) {
    return (alignment == PDLCollectionViewFlowLayoutAlignmentTop) || (alignment == PDLCollectionViewFlowLayoutAlignmentLeftTop) || (alignment == PDLCollectionViewFlowLayoutAlignmentRightTop);
}

static BOOL isAlignmentBottom(PDLCollectionViewFlowLayoutAlignment alignment) {
    return (alignment == PDLCollectionViewFlowLayoutAlignmentBottom) || (alignment == PDLCollectionViewFlowLayoutAlignmentLeftBottom) || (alignment == PDLCollectionViewFlowLayoutAlignmentRightBottom);
}

static NSString *const PDLCollectionViewFlowLayoutDecorationViewOfKind = @"PDLCollectionViewFlowLayoutDecorationViewOfKind";

@interface PDLCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, copy) UIColor *backgroundColor;

@end

@implementation PDLCollectionViewLayoutAttributes

- (instancetype)copyWithZone:(NSZone *)zone {
    PDLCollectionViewLayoutAttributes *copy = [super copyWithZone:zone];
    copy.backgroundColor = [self.backgroundColor copyWithZone:zone];
    return copy;
}

- (NSInteger)zIndex {
    return [super zIndex];
}

@end

@interface PDLCollectionReusableView : UICollectionReusableView

@end

@implementation PDLCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)applyLayoutAttributes:(PDLCollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];

    self.backgroundColor = layoutAttributes.backgroundColor;
    self.layer.zPosition = layoutAttributes.zIndex;
}

@end

@interface PDLCollectionViewFlowLayout ()

@property (nonatomic, strong) NSMutableArray *attributesList;
@property (nonatomic, strong) NSMutableDictionary *attributesDictionary;

@end

@implementation PDLCollectionViewFlowLayout

+ (Class)layoutAttributesClass {
    return [PDLCollectionViewLayoutAttributes class];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _alignment = PDLCollectionViewFlowLayoutAlignmentCenter;

        [self registerClass:[PDLCollectionReusableView class] forDecorationViewOfKind:PDLCollectionViewFlowLayoutDecorationViewOfKind];
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];

    self.attributesList = [NSMutableArray array];
    self.attributesDictionary = [NSMutableDictionary dictionary];

    [self layoutAttributesForElementsInRect:self.collectionView.bounds];

    id <PDLCollectionViewDelegateFlowLayout> delegate = (id <PDLCollectionViewDelegateFlowLayout>)(self.collectionView.delegate);

    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        NSInteger itemsCount = [self.collectionView numberOfItemsInSection:section];
        if (itemsCount <= 0) {
            continue;
        }

        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *firstItem = [self layoutAttributesForItemAtIndexPath:indexPath];
        UICollectionViewLayoutAttributes *lastItem = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:itemsCount - 1 inSection:section]];

        UIEdgeInsets sectionInset = self.sectionInset;
        if ([delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            sectionInset = [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
        }

        CGRect frame = CGRectUnion(firstItem.frame, lastItem.frame);
        frame.origin.x -= sectionInset.left;
        frame.origin.y -= sectionInset.top;

        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            frame.size.width += sectionInset.left + sectionInset.right;
            frame.size.height = self.collectionView.frame.size.height;
        } else {
            frame.size.width = self.collectionView.frame.size.width;
            frame.size.height += sectionInset.top + sectionInset.bottom;
        }

        UIEdgeInsets backgroundInset = UIEdgeInsetsZero;
        if ([delegate respondsToSelector:@selector(collectionView:layout:backgroundInsetsForSectionAtIndex:)]) {
            backgroundInset = [delegate collectionView:self.collectionView layout:self backgroundInsetsForSectionAtIndex:section];
        }

        frame.origin.x -= backgroundInset.left;
        frame.origin.y -= backgroundInset.top;
        frame.size.width += backgroundInset.left + backgroundInset.right;
        frame.size.height += backgroundInset.top + backgroundInset.bottom;

        PDLCollectionViewLayoutAttributes *attributes = [PDLCollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:PDLCollectionViewFlowLayoutDecorationViewOfKind withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        attributes.zIndex = -1;
        attributes.frame = frame;
        [self.attributesList addObject:attributes];
        self.attributesDictionary[indexPath] = attributes;

        if ([delegate respondsToSelector:@selector(collectionView:layout:backgroundColorForSectionAtIndex:)]) {
            UIColor *backgroundColor = [delegate collectionView:self.collectionView layout:self backgroundColorForSectionAtIndex:section];
            attributes.backgroundColor = backgroundColor;
        }
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect] ?: @[];
    [self applyAlignmentAttributes:attributes];

    NSMutableArray *attributesList = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attribute in self.attributesList) {
        if (!CGRectIntersectsRect(rect, attribute.frame)) {
            continue;
        }

        [attributesList addObject:attribute];
    }

    NSArray *layoutAttributes = [attributes arrayByAddingObjectsFromArray:attributesList];
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *layoutAttributes = nil;
    if ([elementKind isEqualToString:PDLCollectionViewFlowLayoutDecorationViewOfKind]) {
        layoutAttributes = self.attributesDictionary[indexPath];
    } else {
        layoutAttributes = [super layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:indexPath];
    }
    return layoutAttributes;
}

- (void)applyAlignmentAttributes:(NSArray *)attributes {
    PDLCollectionViewFlowLayoutAlignment alignment = self.alignment;
    if (alignment <= PDLCollectionViewFlowLayoutAlignmentCenter || alignment >= PDLCollectionViewFlowLayoutAlignmentCount) {
        return;
    }

    if ((self.scrollDirection != UICollectionViewScrollDirectionHorizontal) && (self.scrollDirection != UICollectionViewScrollDirectionVertical)) {
        return;
    }

    id <PDLCollectionViewDelegateFlowLayout> delegate = (id <PDLCollectionViewDelegateFlowLayout>)(self.collectionView.delegate);
    NSInteger section = -1;
    UIEdgeInsets sectionInset = self.sectionInset;
    CGFloat minimumInteritemSpacing = self.minimumInteritemSpacing;

    NSMutableArray *line = [NSMutableArray array];
    CGFloat currentMax = -CGFLOAT_MAX;
    CGFloat currentMin = CGFLOAT_MAX;

    BOOL isVertical = (self.scrollDirection == UICollectionViewScrollDirectionVertical);
    CGFloat collectionViewLength = isVertical ? self.collectionView.frame.size.width : self.collectionView.frame.size.height;

    CGFloat (^edgeInsetsGetLateralMin)(UIEdgeInsets edgeInsets) = ^(UIEdgeInsets edgeInsets) {
        return isVertical ? edgeInsets.left : edgeInsets.top;
    };
    CGFloat (^edgeInsetsGetLateralMax)(UIEdgeInsets edgeInsets) = ^(UIEdgeInsets edgeInsets) {
        return isVertical ? edgeInsets.right : edgeInsets.bottom;
    };

    CGFloat (*frameGetMin)(CGRect frame) = isVertical ? CGRectGetMinY : CGRectGetMinX;
    CGFloat (*frameGetLength)(CGRect frame) = isVertical ? CGRectGetHeight : CGRectGetWidth;
    CGFloat (*frameGetMax)(CGRect frame) = isVertical ? CGRectGetMaxY : CGRectGetMaxX;
//    CGFloat (*frameGetLateralMin)(CGRect frame) = isVertical ? CGRectGetMinX : CGRectGetMinY;
    CGFloat (*frameGetLateralLength)(CGRect frame) = isVertical ? CGRectGetWidth : CGRectGetHeight;
//    CGFloat (*frameGetLateralMax)(CGRect frame) = isVertical ? CGRectGetMaxX : CGRectGetMaxY;

    void (^frameSetMin)(CGRect *frame, CGFloat m) = ^(CGRect *frame, CGFloat m) {
        if (isVertical) {
            frame->origin.y = m;
        } else {
            frame->origin.x = m;
        }
    };
    void (^frameSetLateralMin)(CGRect *frame, CGFloat m) = ^(CGRect *frame, CGFloat m) {
        if (isVertical) {
            frame->origin.x = m;
        } else {
            frame->origin.y = m;
        }
    };

    BOOL (*isAlignmentMax)(PDLCollectionViewFlowLayoutAlignment alignment) = isVertical ? isAlignmentBottom : isAlignmentRight;
    BOOL (*isAlignmentMin)(PDLCollectionViewFlowLayoutAlignment alignment) = isVertical ? isAlignmentTop : isAlignmentLeft;
    BOOL (*isAlignmentLateralMax)(PDLCollectionViewFlowLayoutAlignment alignment) = isVertical ? isAlignmentRight : isAlignmentBottom;
    BOOL (*isAlignmentLateralMin)(PDLCollectionViewFlowLayoutAlignment alignment) = isVertical ? isAlignmentLeft : isAlignmentTop;

    CGFloat lowMargin = edgeInsetsGetLateralMin(sectionInset);
    CGFloat highMargin = edgeInsetsGetLateralMax(sectionInset);
    for (NSUInteger i = 0; i < attributes.count; i++) {
        UICollectionViewLayoutAttributes *attribute = attributes[i];
        if (attribute.indexPath.section != section) {
            section = attribute.indexPath.section;
            if ([delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
                sectionInset = [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
                lowMargin = edgeInsetsGetLateralMin(sectionInset);
                highMargin = edgeInsetsGetLateralMax(sectionInset);
            }
            if ([delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
                minimumInteritemSpacing = [delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
            }
        }

        [line addObject:attribute];
        currentMax = MAX(frameGetMax(attribute.frame), currentMax);
        currentMin = MIN(frameGetMin(attribute.frame), currentMin);

        UICollectionViewLayoutAttributes *nextAttribute = nil;
        if (i != attributes.count - 1) {
            nextAttribute = attributes[i + 1];
        }

        if (nextAttribute == nil || nextAttribute.frame.origin.y >= currentMax) {
            CGFloat offset = lowMargin;
            if (isAlignmentLateralMax(alignment)) {
                offset = highMargin;
            }

            for (NSUInteger i = 0; i < line.count; i++) {
                UICollectionViewLayoutAttributes *attribute = line[i];
                if (isAlignmentLateralMax(alignment)) {
                    attribute = line[line.count - 1 - i];
                }
                CGRect frame = attribute.frame;
                if (isAlignmentMin(alignment)) {
                    frameSetMin(&frame, currentMin);
                }
                if (isAlignmentMax(alignment)) {
                    frameSetMin(&frame, currentMax - frameGetLength(frame));
                }
                if (isAlignmentLateralMin(alignment)) {
                    frameSetLateralMin(&frame, offset);
                    offset += frameGetLateralLength(frame) + minimumInteritemSpacing;
                }
                if (isAlignmentLateralMax(alignment)) {
                    frame.origin.x = collectionViewLength - offset - frameGetLateralLength(frame);
                    offset += frameGetLateralLength(frame) + minimumInteritemSpacing;
                }
                attribute.frame = frame;
            }

            [line removeAllObjects];
            currentMin = CGFLOAT_MAX;
        }
    }
}

@end
