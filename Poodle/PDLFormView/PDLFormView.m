//
//  PDLFormView.m
//  Poodle
//
//  Created by Poodle on 28/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLFormView.h"

@interface PDLFormViewCell : UIView

@property (nonatomic, weak, readonly) UIView *contentView;

@end

@interface PDLFormViewCell ()

@property (nonatomic, weak) UIView *leftSeparatorLine;
@property (nonatomic, weak) UIView *rightSeparatorLine;
@property (nonatomic, weak) UIView *topSeparatorLine;
@property (nonatomic, weak) UIView *bottomSeparatorLine;

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIView *view;

@end

@implementation PDLFormViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:contentView];
        _contentView = contentView;

        UIView *leftSeparatorLine = [[UIView alloc] init];
        [self addSubview:leftSeparatorLine];
        _leftSeparatorLine = leftSeparatorLine;

        UIView *rightSeparatorLine = [[UIView alloc] init];
        [self addSubview:rightSeparatorLine];
        _rightSeparatorLine = rightSeparatorLine;

        UIView *topSeparatorLine = [[UIView alloc] init];
        [self addSubview:topSeparatorLine];
        _topSeparatorLine = topSeparatorLine;

        UIView *bottomSeparatorLine = [[UIView alloc] init];
        [self addSubview:bottomSeparatorLine];
        _bottomSeparatorLine = bottomSeparatorLine;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;

    CGFloat lineWidth = 1 / [UIScreen mainScreen].scale;

    self.leftSeparatorLine.frame = CGRectMake(0, 0, lineWidth, self.bounds.size.height);
    if (self.leftSeparatorLine.hidden == NO) {
        x += lineWidth;
        width -= lineWidth;
    }

    self.rightSeparatorLine.frame = CGRectMake(self.bounds.size.width - lineWidth, 0, lineWidth, self.bounds.size.height);
    if (self.rightSeparatorLine.hidden == NO) {
        width -= lineWidth;
    }

    self.topSeparatorLine.frame = CGRectMake(0, 0, self.bounds.size.width, lineWidth);
    if (self.topSeparatorLine.hidden == NO) {
        y += lineWidth;
        height -= lineWidth;
    }

    self.bottomSeparatorLine.frame = CGRectMake(0, self.bounds.size.height - lineWidth, self.bounds.size.width, lineWidth);
    if (self.bottomSeparatorLine.hidden == NO) {
        height -= lineWidth;
    }

    self.contentView.frame = CGRectMake(x, y, width, height);
    if (self.view.superview == self.contentView) {
        self.view.frame = self.contentView.bounds;
    }
}

- (void)setIsLeft:(BOOL)isLeft isRight:(BOOL)isRight isTop:(BOOL)isTop isBottom:(BOOL)isBottom {
    self.leftSeparatorLine.hidden = !isLeft;
    if (isLeft) {
        [self.leftSeparatorLine.superview bringSubviewToFront:self.leftSeparatorLine];
    } else {
        [self.leftSeparatorLine.superview sendSubviewToBack:self.leftSeparatorLine];
    }

    self.rightSeparatorLine.hidden = NO;
    if (isRight) {
        [self.rightSeparatorLine.superview bringSubviewToFront:self.rightSeparatorLine];
    } else {
        [self.rightSeparatorLine.superview sendSubviewToBack:self.rightSeparatorLine];
    }

    self.topSeparatorLine.hidden = !isTop;
    if (isTop) {
        [self.topSeparatorLine.superview bringSubviewToFront:self.topSeparatorLine];
    } else {
        [self.topSeparatorLine.superview sendSubviewToBack:self.topSeparatorLine];
    }

    self.bottomSeparatorLine.hidden = NO;
    if (isBottom) {
        [self.bottomSeparatorLine.superview bringSubviewToFront:self.bottomSeparatorLine];
    } else {
        [self.bottomSeparatorLine.superview sendSubviewToBack:self.bottomSeparatorLine];
    }
}

@end

@interface PDLFormView ()

@property (nonatomic, strong) NSMutableDictionary *cacheViews;
@property (nonatomic, strong) NSMutableDictionary *visibleViews;
@property (nonatomic, strong) NSMapTable *reuseIdentifierMapTable;
@property (nonatomic, strong) NSMapTable *viewCellMapTable;

@property (nonatomic, copy) NSArray *rowHeights;
@property (nonatomic, copy) NSArray *columnWidths;

@property (nonatomic, copy) NSArray *visibleColumns;
@property (nonatomic, copy) NSArray *visibleRows;

@property (nonatomic, assign) NSInteger estimatedVisibleLeftColumn;
@property (nonatomic, assign) NSInteger estimatedVisibleRightColumn;

@property (nonatomic, assign) NSInteger estimatedVisibleTopRow;
@property (nonatomic, assign) NSInteger estimatedVisibleBottomRow;

@property (nonatomic, strong) NSMutableDictionary *positionMappingDictionary;
@property (nonatomic, strong) NSMutableDictionary *positionMappedDictionary;

@property (nonatomic, assign) BOOL needsRefreshVisible;

@end

@implementation PDLFormView

@synthesize separatorColor = _separatorColor;
@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _columnWidth = 100;
        _rowHeight = 44;

        _cacheViews = [NSMutableDictionary dictionary];
        _visibleViews = [NSMutableDictionary dictionary];
        _reuseIdentifierMapTable = [NSMapTable weakToStrongObjectsMapTable];
        _viewCellMapTable = [NSMapTable weakToStrongObjectsMapTable];
        _positionMappingDictionary = [NSMutableDictionary dictionary];
        _positionMappedDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setIsScrollHorizontallyForcedEnabled:(BOOL)isScrollHorizontallyForcedEnabled {
    if (_isScrollHorizontallyForcedEnabled == isScrollHorizontallyForcedEnabled) {
        return;
    }
    _isScrollHorizontallyForcedEnabled = isScrollHorizontallyForcedEnabled;
    [self setNeedsLayout];
}

- (void)setIsScrollVerticallyForcedEnabled:(BOOL)isScrollVerticallyForcedEnabled {
    if (_isScrollVerticallyForcedEnabled == isScrollVerticallyForcedEnabled) {
        return;
    }
    _isScrollVerticallyForcedEnabled = isScrollVerticallyForcedEnabled;
    [self setNeedsLayout];
}

- (void)reloadData {
    [self reloadSizes];
    [self setNeedsLayout];
}

- (void)setNeedsRefreshVisible {
    self.needsRefreshVisible = YES;
    [self setNeedsLayout];
}

- (void)reloadSizes {
    id <PDLFormViewDelegate> delegate = self.delegate;
    NSArray *visibleViewColoums = self.visibleColumns;
    NSArray *visibleViewRows = self.visibleRows;
    for (NSInteger visibleViewColoumIndex = visibleViewColoums.count - 1; visibleViewColoumIndex >= 0; visibleViewColoumIndex--) {
        for (NSInteger visibleViewRowIndex = visibleViewRows.count - 1; visibleViewRowIndex >= 0; visibleViewRowIndex--) {
            NSNumber *visibleViewColoumNumber = visibleViewColoums[visibleViewColoumIndex];
            NSNumber *visibleViewRowNumber = visibleViewRows[visibleViewRowIndex];
            [self removeVisibleViewAtColumn:visibleViewColoumNumber.integerValue row:visibleViewRowNumber.integerValue forced:YES];
        }
    }
    self.visibleColumns = nil;
    self.visibleRows = nil;
    [self.positionMappingDictionary removeAllObjects];
    [self.positionMappedDictionary removeAllObjects];

    NSInteger numberOfColumns = 0;
    if ([delegate respondsToSelector:@selector(numberOfColumnsInFormView:)]) {
        numberOfColumns = [delegate numberOfColumnsInFormView:self];
        if (numberOfColumns < 0) {
            numberOfColumns = 0;
        }
    }

    NSInteger numberOfRows = 0;
    if ([delegate respondsToSelector:@selector(numberOfRowsInFormView:)]) {
        numberOfRows = [delegate numberOfRowsInFormView:self];
        if (numberOfRows < 0) {
            numberOfRows = 0;
        }
    }


    if ([delegate respondsToSelector:@selector(formView:destinationForColumn:row:)]) {
        for (NSInteger column = 0; column < numberOfColumns; column++) {
            for (NSInteger row = 0; row < numberOfRows; row++) {
                NSInteger destinationColumn = column;
                NSInteger destinationRow = row;
                [delegate formView:self destinationForColumn:&destinationColumn row:&destinationRow];
                if (destinationColumn == column && destinationRow == row) {
                    continue;
                }
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:column];
                NSIndexPath *destinationIndexPath = [NSIndexPath indexPathForRow:destinationRow inSection:destinationColumn];
                self.positionMappingDictionary[indexPath] = destinationIndexPath;
                NSMutableArray *positions = self.positionMappedDictionary[destinationIndexPath];
                if (positions == nil) {
                    positions = [NSMutableArray array];
                    self.positionMappedDictionary[destinationIndexPath] = positions;
                }
                [positions addObject:indexPath];
            }
        }
    }

    CGFloat totalWidth = 0;
    CGFloat totalHeight = 0;
    NSMutableArray *columnWidths = [NSMutableArray array];
    NSMutableArray *rowHeights = [NSMutableArray array];

    if ([delegate respondsToSelector:@selector(formView:sizeForColumn:row:)]) {
        // faster
        CGFloat *rowHeightArray = malloc(sizeof(CGFloat) * numberOfRows);
        for (NSInteger column = 0; column < numberOfColumns; column++) {
            CGFloat columnWidth = 0;
            for (NSInteger row = 0; row < numberOfRows; row++) {
                if (column == 0) {
                    rowHeightArray[row] = 0;
                }
                CGSize size = [delegate formView:self sizeForColumn:column row:row];
                if (size.width > columnWidth) {
                    columnWidth = size.width;
                }
                CGFloat rowHeight = rowHeightArray[row];
                if (size.height > rowHeight) {
                    rowHeight = size.height;
                    rowHeightArray[row] = rowHeight;
                }
                if (column == numberOfColumns - 1) {
                    totalHeight += rowHeight;
                    [rowHeights addObject:@(totalHeight)];
                }
            }
            totalWidth += columnWidth;
            [columnWidths addObject:@(totalWidth)];
        }
        free(rowHeightArray);
    } else {
        for (NSInteger column = 0; column < numberOfColumns; column++) {
            CGFloat columnWidth = self.columnWidth;
            if ([delegate respondsToSelector:@selector(formView:widthForColumn:)]) {
                columnWidth = [delegate formView:self widthForColumn:column];
            }
            totalWidth += columnWidth;
            [columnWidths addObject:@(totalWidth)];
        }

        for (NSInteger row = 0; row < numberOfRows; row++) {
            CGFloat rowHeight = self.rowHeight;
            if ([delegate respondsToSelector:@selector(formView:heightForRow:)]) {
                rowHeight = [delegate formView:self heightForRow:row];
            }
            totalHeight += rowHeight;
            [rowHeights addObject:@(totalHeight)];
        }
    }

    self.columnWidths = columnWidths;
    self.rowHeights = rowHeights;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.rowHeights == nil || self.columnWidths == nil) {
        [self reloadSizes];
    }

    CGFloat width = [self.columnWidths.lastObject doubleValue];
    if (self.isScrollHorizontallyForcedEnabled) {
        if (width <= self.bounds.size.width) {
            width = self.bounds.size.width + 1;
        }
    }

    CGFloat height = [self.rowHeights.lastObject doubleValue];
    if (self.isScrollVerticallyForcedEnabled) {
        if (height <= self.bounds.size.height) {
            height = self.bounds.size.height + 1;
        }
    }
    self.contentSize = CGSizeMake(width, height);

    NSArray *oldVisibleColumns = self.visibleColumns;
    [self calculateVisibleColumns];
    NSArray *newVisibleColumns = self.visibleColumns;

    NSArray *oldVisibleRows = self.visibleRows;
    [self calculateVisibleRows];
    NSArray *newVisibleRows = self.visibleRows;

    NSMutableArray *viewColumnsToDelete = oldVisibleColumns.mutableCopy;
    [viewColumnsToDelete removeObjectsInArray:newVisibleColumns];
    NSMutableArray *viewRowsToDelete = oldVisibleRows.mutableCopy;
    [viewRowsToDelete removeObjectsInArray:newVisibleRows];

    for (NSNumber *viewColumnToDelete in viewColumnsToDelete) {
        for (NSNumber *oldVisibleRow in oldVisibleRows) {
            [self removeVisibleViewAtColumn:viewColumnToDelete.integerValue row:oldVisibleRow.integerValue forced:NO];
        }
    }
    for (NSNumber *viewRowToDelete in viewRowsToDelete) {
        for (NSNumber *oldVisibleColumn in oldVisibleColumns) {
            [self removeVisibleViewAtColumn:oldVisibleColumn.integerValue row:viewRowToDelete.integerValue forced:NO];
        }
    }

    NSMutableArray *viewColumnsToAdd = newVisibleColumns.mutableCopy;
    [viewColumnsToAdd removeObjectsInArray:oldVisibleColumns];
    NSMutableArray *viewRowsToAdd = newVisibleRows.mutableCopy;
    [viewRowsToAdd removeObjectsInArray:oldVisibleRows];

    for (NSNumber *viewColumnToAdd in viewColumnsToAdd) {
        for (NSNumber *newVisibleRow in newVisibleRows) {
            [self addVisibleViewAtColumn:viewColumnToAdd.integerValue row:newVisibleRow.integerValue];
        }
    }
    for (NSNumber *viewRowToAdd in viewRowsToAdd) {
        for (NSNumber *newVisibleColumn in newVisibleColumns) {
            [self addVisibleViewAtColumn:newVisibleColumn.integerValue row:viewRowToAdd.integerValue];
        }
    }

    if (self.needsRefreshVisible) {
        NSMutableArray *viewColumnsBoth = oldVisibleColumns.mutableCopy;
        [viewColumnsBoth removeObjectsInArray:viewColumnsToDelete];
        NSMutableArray *viewRowsBoth = oldVisibleRows.mutableCopy;
        [viewRowsBoth removeObjectsInArray:viewRowsToDelete];
        self.needsRefreshVisible = NO;

        for (NSNumber *viewColumnBoth in viewColumnsBoth) {
            for (NSNumber *viewRowBoth in viewRowsBoth) {
                [self refreshVisibleViewAtColumn:viewColumnBoth.integerValue row:viewRowBoth.integerValue];
            }
        }
    }
}

- (void)removeVisibleViewAtColumn:(NSInteger)column row:(NSInteger)row forced:(BOOL)forced {
    NSIndexPath *destinationIndexPath = [self destinationIndexPathWithIndexPath:[NSIndexPath indexPathForRow:row inSection:column]];
    UIView *view = self.visibleViews[destinationIndexPath];
    PDLFormViewCell *cell = [self.viewCellMapTable objectForKey:view];
    if (!forced) {
        BOOL intersects = CGRectIntersectsRect(cell.frame, CGRectMake(self.contentOffset.x, self.contentOffset.y, self.bounds.size.width, self.bounds.size.height));
        if (intersects) {
            return;
        }
    }

    [cell removeFromSuperview];
    [self enqueue:view];
    self.visibleViews[destinationIndexPath] = nil;
}

- (void)addVisibleViewAtColumn:(NSInteger)column row:(NSInteger)row {
    if (![self.delegate respondsToSelector:@selector(formView:viewForColumn:row:)]) {
        return;
    }

    NSIndexPath *destinationIndexPath = [self destinationIndexPathWithIndexPath:[NSIndexPath indexPathForRow:row inSection:column]];
    if (self.visibleViews[destinationIndexPath]) {
        return;
    }

    NSInteger destinationColumn = destinationIndexPath.section;
    NSInteger destinationRow = destinationIndexPath.row;

    UIView *view = [self.delegate formView:self viewForColumn:destinationColumn row:destinationRow];
    self.visibleViews[destinationIndexPath] = view;

    CGRect frame = [self viewFrameInColumn:column row:row];
    PDLFormViewCell *cell = [self.viewCellMapTable objectForKey:view];
    if (cell == nil) {
        cell = [[PDLFormViewCell alloc] initWithFrame:frame];
        [cell.contentView addSubview:view];
        cell.view = view;
        [self.viewCellMapTable setObject:cell forKey:view];
    } else {
        cell.frame = frame;
    }
    view.frame = cell.contentView.bounds;
    [self addSubview:cell];

    NSInteger leftColumn = destinationColumn;
    NSInteger rightColumn = destinationColumn;
    NSInteger topRow = destinationRow;
    NSInteger bottomRow = destinationRow;
    [self getLeftColumn:&leftColumn rightColumn:&rightColumn topRow:&topRow bottomRow:&bottomRow withColumn:column row:row];

    BOOL isLeft = (leftColumn == 0);
    BOOL isRight = (rightColumn == self.columnWidths.count - 1);
    BOOL isTop = (topRow == 0);
    BOOL isBottom = (bottomRow == self.rowHeights.count - 1);

    [cell setIsLeft:isLeft isRight:isRight isTop:isTop isBottom:isBottom];

    UIColor *leftSeparatorLineColor = nil;
    if (isLeft) {
        leftSeparatorLineColor = (self.outerSeparatorColor ?: self.verticalSeparatorColor) ?: self.separatorColor;
    } else {
        leftSeparatorLineColor = (self.verticalSeparatorColor ?: self.innerSeparatorColor) ?: self.separatorColor;
    }
    cell.leftSeparatorLine.backgroundColor = leftSeparatorLineColor;

    UIColor *rightSeparatorLineColor = nil;
    if (isRight) {
        rightSeparatorLineColor = (self.outerSeparatorColor ?: self.verticalSeparatorColor) ?: self.separatorColor;
    } else {
        rightSeparatorLineColor = (self.verticalSeparatorColor ?: self.innerSeparatorColor) ?: self.separatorColor;
    }
    cell.rightSeparatorLine.backgroundColor = rightSeparatorLineColor;

    UIColor *topSeparatorLineColor = nil;
    if (isTop) {
        topSeparatorLineColor = (self.outerSeparatorColor ?: self.horizontalSeparatorColor) ?: self.separatorColor;
    } else {
        topSeparatorLineColor = (self.horizontalSeparatorColor ?: self.innerSeparatorColor) ?: self.separatorColor;
    }
    cell.topSeparatorLine.backgroundColor = topSeparatorLineColor;

    UIColor *bottomSeparatorLineColor = nil;
    if (isBottom) {
        bottomSeparatorLineColor = (self.outerSeparatorColor ?: self.horizontalSeparatorColor) ?: self.separatorColor;
    } else {
        bottomSeparatorLineColor = (self.horizontalSeparatorColor ?: self.innerSeparatorColor) ?: self.separatorColor;
    }
    cell.bottomSeparatorLine.backgroundColor = bottomSeparatorLineColor;
}

- (void)refreshVisibleViewAtColumn:(NSInteger)column row:(NSInteger)row {
    NSIndexPath *destinationIndexPath = [self destinationIndexPathWithIndexPath:[NSIndexPath indexPathForRow:row inSection:column]];
    UIView *view = self.visibleViews[destinationIndexPath];
    if (view == nil) {
        return;
    }
    PDLFormViewCell *cell = [self.viewCellMapTable objectForKey:view];
    if (cell == nil) {
        return;
    }

    NSInteger destinationColumn = destinationIndexPath.section;
    NSInteger destinationRow = destinationIndexPath.row;
    NSInteger leftColumn = destinationColumn;
    NSInteger rightColumn = destinationColumn;
    NSInteger topRow = destinationRow;
    NSInteger bottomRow = destinationRow;
    [self getLeftColumn:&leftColumn rightColumn:&rightColumn topRow:&topRow bottomRow:&bottomRow withColumn:column row:row];

    BOOL isLeft = (leftColumn == 0);
    BOOL isRight = (rightColumn == self.columnWidths.count - 1);
    BOOL isTop = (topRow == 0);
    BOOL isBottom = (bottomRow == self.rowHeights.count - 1);

    [cell setIsLeft:isLeft isRight:isRight isTop:isTop isBottom:isBottom];

    UIColor *leftSeparatorLineColor = nil;
    if (isLeft) {
        leftSeparatorLineColor = (self.outerSeparatorColor ?: self.verticalSeparatorColor) ?: self.separatorColor;
    } else {
        leftSeparatorLineColor = (self.verticalSeparatorColor ?: self.innerSeparatorColor) ?: self.separatorColor;
    }
    cell.leftSeparatorLine.backgroundColor = leftSeparatorLineColor;

    UIColor *rightSeparatorLineColor = nil;
    if (isRight) {
        rightSeparatorLineColor = (self.outerSeparatorColor ?: self.verticalSeparatorColor) ?: self.separatorColor;
    } else {
        rightSeparatorLineColor = (self.verticalSeparatorColor ?: self.innerSeparatorColor) ?: self.separatorColor;
    }
    cell.rightSeparatorLine.backgroundColor = rightSeparatorLineColor;

    UIColor *topSeparatorLineColor = nil;
    if (isTop) {
        topSeparatorLineColor = (self.outerSeparatorColor ?: self.horizontalSeparatorColor) ?: self.separatorColor;
    } else {
        topSeparatorLineColor = (self.horizontalSeparatorColor ?: self.innerSeparatorColor) ?: self.separatorColor;
    }
    cell.topSeparatorLine.backgroundColor = topSeparatorLineColor;

    UIColor *bottomSeparatorLineColor = nil;
    if (isBottom) {
        bottomSeparatorLineColor = (self.outerSeparatorColor ?: self.horizontalSeparatorColor) ?: self.separatorColor;
    } else {
        bottomSeparatorLineColor = (self.horizontalSeparatorColor ?: self.innerSeparatorColor) ?: self.separatorColor;
    }
    cell.bottomSeparatorLine.backgroundColor = bottomSeparatorLineColor;
}

- (CGFloat)viewWidthInColumn:(NSInteger)column {
    CGFloat viewWidth = [self viewRightInColumn:column] - [self viewLeftInColumn:column];
    return viewWidth;
}

- (CGFloat)viewLeftInColumn:(NSInteger)column {
    CGFloat viewLeft = 0;
    if (column > 0) {
        viewLeft = [self.columnWidths[column - 1] doubleValue];
    }
    return viewLeft;
}

- (CGFloat)viewRightInColumn:(NSInteger)column {
    CGFloat viewRight = [self.columnWidths[column] doubleValue];
    return viewRight;
}

- (void)calculateVisibleColumns {
    CGFloat frameWidth = self.frame.size.width;
    CGFloat offsetX = self.contentOffset.x;
    CGFloat visibleLeft = offsetX;
    CGFloat visibleRight = offsetX + frameWidth;

    NSInteger estimatedVisibleLeftColumn = self.estimatedVisibleLeftColumn;
    NSInteger estimatedVisibleRightColumn = self.estimatedVisibleRightColumn;
    BOOL needsReload = NO;
    if ((estimatedVisibleLeftColumn >= self.columnWidths.count || estimatedVisibleLeftColumn < 0) || (estimatedVisibleRightColumn >= self.columnWidths.count || estimatedVisibleRightColumn < 0) ) {
        needsReload = YES;
    } else {
        CGFloat left = [self viewLeftInColumn:estimatedVisibleLeftColumn];
        CGFloat right = [self viewRightInColumn:estimatedVisibleRightColumn];
        if ((visibleRight < left) || (right < visibleLeft)) {
            needsReload = YES;
        }
    }

    NSInteger estimatedVisibleColumn = estimatedVisibleLeftColumn;
    if (needsReload) {
        NSInteger leftColumn = 0;
        NSInteger rightColumn = self.columnWidths.count - 1;
        while (YES) {
            NSInteger currentColumn = (leftColumn + rightColumn) / 2;
            if (rightColumn - leftColumn <= 1) {
                estimatedVisibleColumn = currentColumn;
                break;
            }

            CGFloat viewLeft = [self viewLeftInColumn:currentColumn];
            CGFloat viewRight = [self viewRightInColumn:currentColumn];
            if (visibleRight < viewLeft) {
                rightColumn = currentColumn;
                continue;
            }
            if (viewRight < visibleLeft) {
                leftColumn = currentColumn;
                continue;
            }
            estimatedVisibleColumn = currentColumn;
            break;
        }
    }

    NSMutableArray *visibleColumns = [NSMutableArray array];
    for (NSInteger column = estimatedVisibleColumn; column < self.columnWidths.count; column++) {
        CGFloat viewLeft = [self viewLeftInColumn:column];
        CGFloat viewRight = [self viewRightInColumn:column];
        if (visibleRight < viewLeft) {
            break;
        }
        if (viewRight < visibleLeft) {
            continue;
        }
        [visibleColumns addObject:@(column)];
    }
    for (NSInteger column = estimatedVisibleColumn - 1; column >= 0; column--) {
        CGFloat viewLeft = [self viewLeftInColumn:column];
        CGFloat viewRight = [self viewRightInColumn:column];
        if (viewRight < visibleLeft) {
            break;
        }
        if (visibleRight < viewLeft) {
            continue;
        }
        [visibleColumns insertObject:@(column) atIndex:0];
    }

    self.visibleColumns = visibleColumns.copy;
    self.estimatedVisibleLeftColumn = [visibleColumns.firstObject integerValue];
    self.estimatedVisibleRightColumn = [visibleColumns.lastObject integerValue];
}

- (CGFloat)viewHeightInRow:(NSInteger)row {
    CGFloat viewHeight = [self viewBottomInRow:row] - [self viewTopInRow:row];
    return viewHeight;
}

- (CGFloat)viewTopInRow:(NSInteger)row {
    CGFloat viewTop = 0;
    if (row > 0) {
        viewTop = [self.rowHeights[row - 1] doubleValue];
    }
    return viewTop;
}

- (CGFloat)viewBottomInRow:(NSInteger)row {
    CGFloat viewBottom = [self.rowHeights[row] doubleValue];
    return viewBottom;
}

- (void)calculateVisibleRows {
    CGFloat frameHeight = self.frame.size.height;
    CGFloat offsetY = self.contentOffset.y;
    CGFloat visibleTop = offsetY;
    CGFloat visibleBottom = offsetY + frameHeight;

    NSInteger estimatedVisibleTopRow = self.estimatedVisibleTopRow;
    NSInteger estimatedVisibleBottomRow = self.estimatedVisibleBottomRow;
    BOOL needsReload = NO;
    if ((estimatedVisibleTopRow >= self.rowHeights.count || estimatedVisibleTopRow < 0) || (estimatedVisibleBottomRow >= self.rowHeights.count || estimatedVisibleBottomRow < 0) ) {
        needsReload = YES;
    } else {
        CGFloat top = [self viewTopInRow:estimatedVisibleTopRow];
        CGFloat bottom = [self viewBottomInRow:estimatedVisibleBottomRow];
        if ((visibleBottom < top) || (bottom < visibleTop)) {
            needsReload = YES;
        }
    }

    NSInteger estimatedVisibleRow = estimatedVisibleTopRow;
    if (needsReload) {
        NSInteger topRow = 0;
        NSInteger bottomRow = self.rowHeights.count - 1;
        while (YES) {
            NSInteger currentRow = (topRow + bottomRow) / 2;
            if (bottomRow - topRow <= 1) {
                estimatedVisibleRow = currentRow;
                break;
            }

            CGFloat viewTop = [self viewTopInRow:currentRow];
            CGFloat viewBottom = [self viewBottomInRow:currentRow];
            if (visibleBottom < viewTop) {
                bottomRow = currentRow;
                continue;
            }
            if (viewBottom < visibleTop) {
                topRow = currentRow;
                continue;
            }
            estimatedVisibleRow = currentRow;
            break;
        }
    }

    NSMutableArray *visibleRows = [NSMutableArray array];
    for (NSInteger row = estimatedVisibleRow; row < self.rowHeights.count; row++) {
        CGFloat viewTop = [self viewTopInRow:row];
        CGFloat viewBottom = [self viewBottomInRow:row];
        if (visibleBottom < viewTop) {
            break;
        }
        if (viewBottom < visibleTop) {
            continue;
        }
        [visibleRows addObject:@(row)];
    }
    for (NSInteger row = estimatedVisibleRow - 1; row >= 0; row--) {
        CGFloat viewTop = [self viewTopInRow:row];
        CGFloat viewBottom = [self viewBottomInRow:row];
        if (viewBottom < visibleTop) {
            break;
        }
        if (visibleBottom < viewTop) {
            continue;
        }
        [visibleRows insertObject:@(row) atIndex:0];
    }

    self.visibleRows = visibleRows.copy;
    self.estimatedVisibleTopRow = [visibleRows.firstObject integerValue];
    self.estimatedVisibleBottomRow = [visibleRows.lastObject integerValue];
}

- (NSString *)reuseIdentifierForView:(UIView *)view {
    NSString *reuseIdentifier = [self.reuseIdentifierMapTable objectForKey:view];
    return reuseIdentifier;
}

- (void)setReuseIdentifier:(NSString *)identifier forView:(UIView *)view {
    [self.reuseIdentifierMapTable setObject:identifier.copy forKey:view];
}

- (void)enqueue:(UIView *)view {
    NSString *reuseIdentifier = [self reuseIdentifierForView:view];
    if (reuseIdentifier == nil) {
        return;
    }

    NSMutableArray *views = self.cacheViews[reuseIdentifier];
    if (views == nil) {
        views = [NSMutableArray array];
        self.cacheViews[reuseIdentifier] = views;
    }
    [views addObject:view];
}

- (UIView *)dequeue:(NSString *)reuseIdentifier {
    if (reuseIdentifier == nil) {
        return nil;
    }

    NSMutableArray *views = self.cacheViews[reuseIdentifier];
    if (views == nil) {
        return nil;
    }
    UIView *view = views.lastObject;
    [views removeLastObject];
    return view;
}

- (UIView *)dequeueReusableViewWithIdentifier:(NSString *)identifier {
    UIView *view = [self dequeue:identifier];
    return view;
}

- (UIView *)viewForColumn:(NSInteger)column row:(NSInteger)row {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:column];
    UIView *view = self.visibleViews[indexPath];
    return view;
}

- (NSInteger)columnForView:(UIView *)view {
    NSInteger column = NSNotFound;
    for (NSIndexPath *indexPath in self.visibleViews) {
        if (view == self.visibleViews[indexPath]) {
            column = indexPath.section;
            break;
        }
    }
    return column;
}

- (NSInteger)rowForView:(UIView *)view {
    NSInteger row = NSNotFound;
    for (NSIndexPath *indexPath in self.visibleViews) {
        if (view == self.visibleViews[indexPath]) {
            row = indexPath.row;
            break;
        }
    }
    return row;
}

- (NSIndexPath *)destinationIndexPathWithIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *destinationIndexPath = self.positionMappingDictionary[indexPath];
    if (destinationIndexPath == nil) {
        destinationIndexPath = indexPath;
    }
    return destinationIndexPath;
}

- (void)getLeftColumn:(NSInteger *)leftColumn rightColumn:(NSInteger *)rightColumn topRow:(NSInteger *)topRow bottomRow:(NSInteger *)bottomRow withColumn:(NSInteger)column row:(NSInteger)row {
    NSIndexPath *destinationIndexPath = [self destinationIndexPathWithIndexPath:[NSIndexPath indexPathForRow:row inSection:column]];
    NSInteger destinationColumn = destinationIndexPath.section;
    NSInteger destinationRow = destinationIndexPath.row;

    NSMutableArray *positions = self.positionMappedDictionary[destinationIndexPath];
    NSInteger minimumColumn = destinationColumn;
    NSInteger maximumColumn = destinationColumn;
    NSInteger minimumRow = destinationRow;
    NSInteger maximumRow = destinationRow;
    for (NSIndexPath *position in positions) {
        NSInteger postionColumn = position.section;
        NSInteger postionRow = position.row;

        minimumColumn = MIN(minimumColumn, postionColumn);
        maximumColumn = MAX(maximumColumn, postionColumn);
        minimumRow = MIN(minimumRow, postionRow);
        maximumRow = MAX(maximumRow, postionRow);
    }
    if (leftColumn) {
        *leftColumn = minimumColumn;
    }
    if (rightColumn) {
        *rightColumn = maximumColumn;
    }
    if (topRow) {
        *topRow = minimumRow;
    }
    if (bottomRow) {
        *bottomRow = maximumRow;
    }
}

- (CGRect)viewFrameInColumn:(NSInteger)column row:(NSInteger)row {
    NSIndexPath *destinationIndexPath = [self destinationIndexPathWithIndexPath:[NSIndexPath indexPathForRow:row inSection:column]];
    NSInteger destinationColumn = destinationIndexPath.section;
    NSInteger destinationRow = destinationIndexPath.row;

    CGFloat viewLeft = [self viewLeftInColumn:destinationColumn];
    CGFloat viewRight = [self viewRightInColumn:destinationColumn];
    CGFloat viewTop = [self viewTopInRow:destinationRow];
    CGFloat viewBottom = [self viewBottomInRow:destinationRow];

    NSMutableArray *positions = self.positionMappedDictionary[destinationIndexPath];
    NSInteger maximumColumn = destinationColumn;
    NSInteger minimumColumn = destinationColumn;
    NSInteger maximumRow = destinationRow;
    NSInteger minimumRow = destinationRow;
    for (NSIndexPath *position in positions) {
        NSInteger postionColumn = position.section;
        NSInteger postionRow = position.row;

        maximumColumn = MAX(maximumColumn, postionColumn);
        minimumColumn = MIN(minimumColumn, postionColumn);
        maximumRow = MAX(maximumRow, postionRow);
        minimumRow = MIN(minimumRow, postionRow);

        CGFloat left = [self viewLeftInColumn:postionColumn];
        CGFloat right = [self viewRightInColumn:postionColumn];
        CGFloat top = [self viewTopInRow:postionRow];
        CGFloat bottom = [self viewBottomInRow:postionRow];
        viewLeft = MIN(viewLeft, left);
        viewRight = MAX(viewRight, right);
        viewTop = MIN(viewTop, top);
        viewBottom = MAX(viewBottom, bottom);
    }

    CGRect frame = CGRectMake(viewLeft, viewTop, viewRight - viewLeft, viewBottom - viewTop);
    return frame;
}

- (void)scrollToColumn:(NSInteger)column row:(NSInteger)row atScrollPosition:(PDLFormViewScrollPosition)scrollPosition animated:(BOOL)animated {
    NSInteger toColumn = column;
    if (toColumn < 0) {
        toColumn = 0;
    } else if (toColumn > self.columnWidths.count - 1) {
        toColumn = self.columnWidths.count - 1;
    }
    NSInteger toRow = row;
    if (toRow < 0) {
        toRow = 0;
    } else if (toRow > self.rowHeights.count - 1) {
        toRow = self.rowHeights.count - 1;
    }

    CGRect frame = [self viewFrameInColumn:toColumn row:toRow];
    CGPoint contentOffset = self.contentOffset;
    CGFloat x = 0;
    if (scrollPosition & PDLFormViewScrollPositionLeft) {
        x = frame.origin.x;
    } else if (scrollPosition & PDLFormViewScrollPositionCenteredHorizontally) {
        x = frame.origin.x + (frame.size.width - self.bounds.size.width) / 2;
    } else if (scrollPosition & PDLFormViewScrollPositionRight) {
        x = frame.origin.x + frame.size.width - self.bounds.size.width;
    } else {
        CGFloat minX = MIN(frame.origin.x, frame.origin.x + frame.size.width - self.bounds.size.width);
        CGFloat maxX = MAX(frame.origin.x, frame.origin.x + frame.size.width - self.bounds.size.width);
        if (contentOffset.x < minX) {
            x = minX;
        } else if (contentOffset.x > maxX) {
            x = maxX;
        } else {
            x = contentOffset.x;
        }
    }

    CGFloat y = 0;
    if (scrollPosition & PDLFormViewScrollPositionTop) {
        y = frame.origin.y;
    } else if (scrollPosition & PDLFormViewScrollPositionCenteredVertically) {
        y = frame.origin.y + (frame.size.height - self.bounds.size.height) / 2;
    } else if (scrollPosition & PDLFormViewScrollPositionBottom) {
        y = frame.origin.y + frame.size.height - self.bounds.size.height;
    } else {
        CGFloat minY = MIN(frame.origin.y, frame.origin.y + frame.size.height - self.bounds.size.height);
        CGFloat maxY = MAX(frame.origin.y, frame.origin.y + frame.size.height - self.bounds.size.height);
        if (contentOffset.y < minY) {
            y = minY;
        } else if (contentOffset.y > maxY) {
            y = maxY;
        } else {
            y = contentOffset.y;
        }

    }

    CGFloat maxX = self.contentSize.width - self.bounds.size.width;
    if (x > maxX) {
        x = maxX;
    }
    if (x < 0) {
        x = 0;
    }

    CGFloat maxY = self.contentSize.height - self.bounds.size.height;
    if (y > maxY) {
        y = maxY;
    }
    if (y < 0) {
        y = 0;
    }
    [self setContentOffset:CGPointMake(x, y) animated:animated];
}

- (UIColor *)separatorColor {
    return _separatorColor ?: [UIColor grayColor];
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    if (_separatorColor == separatorColor) {
        return;
    }
    _separatorColor = separatorColor;
    [self setNeedsRefreshVisible];
}

- (void)setInnerSeparatorColor:(UIColor *)innerSeparatorColor {
    if (_innerSeparatorColor == innerSeparatorColor) {
        return;
    }
    _innerSeparatorColor = innerSeparatorColor;
    [self setNeedsRefreshVisible];
}

- (void)setHorizontalSeparatorColor:(UIColor *)horizontalSeparatorColor {
    if (_horizontalSeparatorColor == horizontalSeparatorColor) {
        return;
    }
    _horizontalSeparatorColor = horizontalSeparatorColor;
    [self setNeedsRefreshVisible];
}

- (void)setVerticalSeparatorColor:(UIColor *)verticalSeparatorColor {
    if (_verticalSeparatorColor == verticalSeparatorColor) {
        return;
    }
    _verticalSeparatorColor = verticalSeparatorColor;
    [self setNeedsRefreshVisible];
}

- (void)setOuterSeparatorColor:(UIColor *)outerSeparatorColor {
    if (_outerSeparatorColor == outerSeparatorColor) {
        return;
    }
    _outerSeparatorColor = outerSeparatorColor;
    [self setNeedsRefreshVisible];
}

@end
