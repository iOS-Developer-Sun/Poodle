//
//  PDLFormView.m
//  Poodle
//
//  Created by Poodle on 28/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLFormView.h"
#import "PDLFormViewCell.h"
#import "NSMapTable+PDLExtension.h"

@interface PDLFormView () {
    BOOL _delegateRespondsViewForColumnRow;
    BOOL _delegateRespondsNumberOfColumns;
    BOOL _delegateRespondsNumberOfRows;
    BOOL _delegateRespondsSizeForColumnRow;
    BOOL _delegateRespondsWidthForColumn;
    BOOL _delegateRespondsHeightForRow;
    BOOL _delegateRespondsDestinationForColumnRow;
    BOOL _delegateRespondsVisibleColumnsRowsDidChange;
    BOOL _delegateRespondsWillDisplayForColumnRow;
    BOOL _delegateRespondsDidDisplayForColumnRow;
    BOOL _delegateRespondsWillEndDisplayingForColumnRow;
    BOOL _delegateRespondsDidEndDisplayingForColumnRow;
    BOOL _delegateRespondsDidBeginScrollingAnimation;
    BOOL _delegateRespondsWillSetContentOffsetAnimated;
    BOOL _delegateRespondsDidSetContentOffsetAnimated;
    BOOL _delegateRespondsWillScrollRectToVisibleAnimated;
    BOOL _delegateRespondsDidScrollRectToVisibleAnimated;
}

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

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.rowHeights == nil || self.columnWidths == nil) {
        [self reloadSizes];
    }

    NSArray *oldVisibleColumns = self.visibleColumns;
    [self calculateVisibleColumns];
    NSArray *newVisibleColumns = self.visibleColumns;

    NSArray *oldVisibleRows = self.visibleRows;
    [self calculateVisibleRows];
    NSArray *newVisibleRows = self.visibleRows;

    BOOL changed = !([oldVisibleColumns ?: @[] isEqualToArray:newVisibleColumns] && [oldVisibleRows ?: @[] isEqualToArray:newVisibleRows]);
    if (changed) {
        if (_delegateRespondsVisibleColumnsRowsDidChange) {
            [_formViewDelegate visibleColumnsRowsDidChange:self];
        }
    }

    NSMutableArray *viewColumnsToDelete = [oldVisibleColumns mutableCopy];
    [viewColumnsToDelete removeObjectsInArray:newVisibleColumns];
    NSMutableArray *viewRowsToDelete = [oldVisibleRows mutableCopy];
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

    NSMutableArray *viewColumnsToAdd = [newVisibleColumns mutableCopy];
    [viewColumnsToAdd removeObjectsInArray:oldVisibleColumns];
    NSMutableArray *viewRowsToAdd = [newVisibleRows mutableCopy];
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
        NSMutableArray *viewColumnsBoth = [oldVisibleColumns mutableCopy];
        [viewColumnsBoth removeObjectsInArray:viewColumnsToDelete];
        NSMutableArray *viewRowsBoth = [oldVisibleRows mutableCopy];
        [viewRowsBoth removeObjectsInArray:viewRowsToDelete];
        self.needsRefreshVisible = NO;

        for (NSNumber *viewColumnBoth in viewColumnsBoth) {
            for (NSNumber *viewRowBoth in viewRowsBoth) {
                [self refreshVisibleViewAtColumn:viewColumnBoth.integerValue row:viewRowBoth.integerValue];
            }
        }
    }
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    if (_delegateRespondsWillSetContentOffsetAnimated) {
        [_formViewDelegate formView:self willSetContentOffset:contentOffset animated:animated];
    }
    [super setContentOffset:contentOffset animated:animated];
    if (_delegateRespondsDidSetContentOffsetAnimated) {
        [_formViewDelegate formView:self didSetContentOffset:contentOffset animated:animated];
    }
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated {
    if (_delegateRespondsWillScrollRectToVisibleAnimated) {
        [_formViewDelegate formView:self willScrollRectToVisible:rect animated:animated];
    }
    [super scrollRectToVisible:rect animated:animated];
    if (_delegateRespondsDidScrollRectToVisibleAnimated) {
        [_formViewDelegate formView:self didScrollRectToVisible:rect animated:animated];
    }
}

- (void)setFormViewDelegate:(id<PDLFormViewDelegate>)formViewDelegate {
    if (_formViewDelegate == formViewDelegate) {
        return;
    }

    _formViewDelegate = formViewDelegate;

    _delegateRespondsViewForColumnRow = [formViewDelegate respondsToSelector:@selector(formView:viewForColumn:row:)];
    _delegateRespondsNumberOfColumns = [formViewDelegate respondsToSelector:@selector(numberOfColumnsInFormView:)];
    _delegateRespondsNumberOfRows = [formViewDelegate respondsToSelector:@selector(numberOfRowsInFormView:)];
    _delegateRespondsSizeForColumnRow = [formViewDelegate respondsToSelector:@selector(formView:sizeForColumn:row:)];
    _delegateRespondsWidthForColumn = [formViewDelegate respondsToSelector:@selector(formView:widthForColumn:)];
    _delegateRespondsHeightForRow = [formViewDelegate respondsToSelector:@selector(formView:heightForRow:)];
    _delegateRespondsDestinationForColumnRow = [formViewDelegate respondsToSelector:@selector(formView:destinationForColumn:row:)];
    _delegateRespondsVisibleColumnsRowsDidChange = [formViewDelegate respondsToSelector:@selector(visibleColumnsRowsDidChange:)];
    _delegateRespondsWillDisplayForColumnRow = [formViewDelegate respondsToSelector:@selector(formView:willDisplayView:forColumn:row:)];
    _delegateRespondsDidDisplayForColumnRow = [formViewDelegate respondsToSelector:@selector(formView:didDisplayView:forColumn:row:)];
    _delegateRespondsWillEndDisplayingForColumnRow = [formViewDelegate respondsToSelector:@selector(formView:willEndDisplayingView:forColumn:row:)];
    _delegateRespondsDidEndDisplayingForColumnRow = [formViewDelegate respondsToSelector:@selector(formView:didEndDisplayingView:forColumn:row:)];
    _delegateRespondsWillSetContentOffsetAnimated = [formViewDelegate respondsToSelector:@selector(formView:willSetContentOffset:animated:)];
    _delegateRespondsDidSetContentOffsetAnimated = [formViewDelegate respondsToSelector:@selector(formView:didSetContentOffset:animated:)];
    _delegateRespondsWillScrollRectToVisibleAnimated = [formViewDelegate respondsToSelector:@selector(formView:willScrollRectToVisible:animated:)];
    _delegateRespondsDidScrollRectToVisibleAnimated = [formViewDelegate respondsToSelector:@selector(formView:didScrollRectToVisible:animated:)];
}

- (void)setIsScrollHorizontallyForcedEnabled:(BOOL)isScrollHorizontallyForcedEnabled {
    if (_isScrollHorizontallyForcedEnabled == isScrollHorizontallyForcedEnabled) {
        return;
    }
    
    _isScrollHorizontallyForcedEnabled = isScrollHorizontallyForcedEnabled;
    [self refreshContentSize];
}

- (void)setIsScrollVerticallyForcedEnabled:(BOOL)isScrollVerticallyForcedEnabled {
    if (_isScrollVerticallyForcedEnabled == isScrollVerticallyForcedEnabled) {
        return;
    }

    _isScrollVerticallyForcedEnabled = isScrollVerticallyForcedEnabled;
    [self refreshContentSize];
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
    id <PDLFormViewDelegate> formViewDelegate = _formViewDelegate;
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
    if (_delegateRespondsNumberOfColumns) {
        numberOfColumns = [formViewDelegate numberOfColumnsInFormView:self];
        if (numberOfColumns < 0) {
            numberOfColumns = 0;
        }
    }

    NSInteger numberOfRows = 0;
    if (_delegateRespondsNumberOfRows) {
        numberOfRows = [formViewDelegate numberOfRowsInFormView:self];
        if (numberOfRows < 0) {
            numberOfRows = 0;
        }
    }

    if (_delegateRespondsDestinationForColumnRow) {
        for (NSInteger column = 0; column < numberOfColumns; column++) {
            for (NSInteger row = 0; row < numberOfRows; row++) {
                NSInteger destinationColumn = column;
                NSInteger destinationRow = row;
                [formViewDelegate formView:self destinationForColumn:&destinationColumn row:&destinationRow];
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

    if (_delegateRespondsSizeForColumnRow) {
        // faster
        CGFloat *rowHeightArray = malloc(sizeof(CGFloat) * numberOfRows);
        for (NSInteger column = 0; column < numberOfColumns; column++) {
            CGFloat columnWidth = 0;
            for (NSInteger row = 0; row < numberOfRows; row++) {
                if (column == 0) {
                    rowHeightArray[row] = 0;
                }
                CGSize size = [formViewDelegate formView:self sizeForColumn:column row:row];
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
        BOOL delegateRespondsWidthForColumn = _delegateRespondsWidthForColumn;
        for (NSInteger column = 0; column < numberOfColumns; column++) {
            CGFloat columnWidth = self.columnWidth;
            if (delegateRespondsWidthForColumn) {
                columnWidth = [formViewDelegate formView:self widthForColumn:column];
            }
            totalWidth += columnWidth;
            [columnWidths addObject:@(totalWidth)];
        }

        BOOL delegateRespondsHeightForRow = _delegateRespondsHeightForRow;
        for (NSInteger row = 0; row < numberOfRows; row++) {
            CGFloat rowHeight = self.rowHeight;
            if (delegateRespondsHeightForRow) {
                rowHeight = [formViewDelegate formView:self heightForRow:row];
            }
            totalHeight += rowHeight;
            [rowHeights addObject:@(totalHeight)];
        }
    }

    self.columnWidths = columnWidths;
    self.rowHeights = rowHeights;

    [self refreshContentSize];
}

- (void)applyCell:(PDLFormViewCell *)cell isLeft:(BOOL)isLeft isRight:(BOOL)isRight isTop:(BOOL)isTop isBottom:(BOOL)isBottom {
    UIColor *leftSeparatorLineColor = nil;
    if (isLeft) {
        leftSeparatorLineColor = (self.outerSeparatorColor ?: self.verticalSeparatorColor) ?: self.separatorColor;
    }
    cell.leftSeparatorLineColor = leftSeparatorLineColor;

    UIColor *rightSeparatorLineColor = nil;
    if (isRight) {
        rightSeparatorLineColor = (self.outerSeparatorColor ?: self.verticalSeparatorColor) ?: self.separatorColor;
    } else {
        rightSeparatorLineColor = (self.verticalSeparatorColor ?: self.innerSeparatorColor) ?: self.separatorColor;
    }
    cell.rightSeparatorLineColor = rightSeparatorLineColor;

    UIColor *topSeparatorLineColor = nil;
    if (isTop) {
        topSeparatorLineColor = (self.outerSeparatorColor ?: self.horizontalSeparatorColor) ?: self.separatorColor;
    }
    cell.topSeparatorLineColor = topSeparatorLineColor;

    UIColor *bottomSeparatorLineColor = nil;
    if (isBottom) {
        bottomSeparatorLineColor = (self.outerSeparatorColor ?: self.horizontalSeparatorColor) ?: self.separatorColor;
    } else {
        bottomSeparatorLineColor = (self.horizontalSeparatorColor ?: self.innerSeparatorColor) ?: self.separatorColor;
    }
    cell.bottomSeparatorLineColor = bottomSeparatorLineColor;

    [cell setIsLeft:isLeft isRight:isRight isTop:isTop isBottom:isBottom];
}


- (void)removeVisibleViewAtColumn:(NSInteger)column row:(NSInteger)row forced:(BOOL)forced {
    NSIndexPath *destinationIndexPath = [self destinationIndexPathWithIndexPath:[NSIndexPath indexPathForRow:row inSection:column]];
    UIView *view = self.visibleViews[destinationIndexPath];
    PDLFormViewCell *cell = self.viewCellMapTable[view];
    if (!forced) {
        BOOL intersects = CGRectIntersectsRect(cell.frame, CGRectMake(self.contentOffset.x, self.contentOffset.y, self.bounds.size.width, self.bounds.size.height));
        if (intersects) {
            return;
        }
    }

    id <PDLFormViewDelegate> formViewDelegate = _formViewDelegate;
    if (_delegateRespondsWillEndDisplayingForColumnRow) {
        [formViewDelegate formView:self willEndDisplayingView:view forColumn:column row:row];
    }
    [cell removeFromSuperview];
    if (_delegateRespondsDidEndDisplayingForColumnRow) {
        [formViewDelegate formView:self didEndDisplayingView:view forColumn:column row:row];
    }

    [self enqueue:view];
    self.visibleViews[destinationIndexPath] = nil;
}

- (void)addVisibleViewAtColumn:(NSInteger)column row:(NSInteger)row {
    if (!_delegateRespondsViewForColumnRow) {
        return;
    }

    NSIndexPath *destinationIndexPath = [self destinationIndexPathWithIndexPath:[NSIndexPath indexPathForRow:row inSection:column]];
    if (self.visibleViews[destinationIndexPath]) {
        return;
    }

    NSInteger destinationColumn = destinationIndexPath.section;
    NSInteger destinationRow = destinationIndexPath.row;

    UIView *view = [_formViewDelegate formView:self viewForColumn:destinationColumn row:destinationRow];
    self.visibleViews[destinationIndexPath] = view;

    CGRect frame = [self viewFrameInColumn:column row:row];
    PDLFormViewCell *cell = self.viewCellMapTable[view];
    if (cell == nil) {
        cell = [[PDLFormViewCell alloc] initWithFrame:frame];
        [cell.contentView addSubview:view];
        cell.view = view;
        self.viewCellMapTable[view] = cell;
    } else {
        cell.frame = frame;
    }
    view.frame = cell.contentView.bounds;

    id <PDLFormViewDelegate> formViewDelegate = _formViewDelegate;
    if (_delegateRespondsWillDisplayForColumnRow) {
        [formViewDelegate formView:self willDisplayView:view forColumn:column row:row];
    }
    [self addSubview:cell];
    if (_delegateRespondsDidDisplayForColumnRow) {
        [formViewDelegate formView:self didDisplayView:view forColumn:column row:row];
    }

    NSInteger leftColumn = destinationColumn;
    NSInteger rightColumn = destinationColumn;
    NSInteger topRow = destinationRow;
    NSInteger bottomRow = destinationRow;
    [self getLeftColumn:&leftColumn rightColumn:&rightColumn topRow:&topRow bottomRow:&bottomRow withColumn:column row:row];

    BOOL isLeft = (leftColumn == 0);
    BOOL isRight = (rightColumn == self.columnWidths.count - 1);
    BOOL isTop = (topRow == 0);
    BOOL isBottom = (bottomRow == self.rowHeights.count - 1);

    [self applyCell:cell isLeft:isLeft isRight:isRight isTop:isTop isBottom:isBottom];
}

- (void)refreshContentSize {
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
}

- (void)refreshVisibleViewAtColumn:(NSInteger)column row:(NSInteger)row {
    NSIndexPath *destinationIndexPath = [self destinationIndexPathWithIndexPath:[NSIndexPath indexPathForRow:row inSection:column]];
    UIView *view = self.visibleViews[destinationIndexPath];
    if (view == nil) {
        return;
    }

    PDLFormViewCell *cell = self.viewCellMapTable[view];
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

    [self applyCell:cell isLeft:isLeft isRight:isRight isTop:isTop isBottom:isBottom];
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
        if (visibleRight <= viewLeft) {
            break;
        }
        if (viewRight <= visibleLeft) {
            continue;
        }
        [visibleColumns addObject:@(column)];
    }
    for (NSInteger column = estimatedVisibleColumn - 1; column >= 0; column--) {
        CGFloat viewLeft = [self viewLeftInColumn:column];
        CGFloat viewRight = [self viewRightInColumn:column];
        if (viewRight <= visibleLeft) {
            break;
        }
        if (visibleRight <= viewLeft) {
            continue;
        }
        [visibleColumns insertObject:@(column) atIndex:0];
    }

    self.visibleColumns = [visibleColumns copy];
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
        if (visibleBottom <= viewTop) {
            break;
        }
        if (viewBottom <= visibleTop) {
            continue;
        }
        [visibleRows addObject:@(row)];
    }
    for (NSInteger row = estimatedVisibleRow - 1; row >= 0; row--) {
        CGFloat viewTop = [self viewTopInRow:row];
        CGFloat viewBottom = [self viewBottomInRow:row];
        if (viewBottom <= visibleTop) {
            break;
        }
        if (visibleBottom <= viewTop) {
            continue;
        }
        [visibleRows insertObject:@(row) atIndex:0];
    }

    self.visibleRows = [visibleRows copy];
    self.estimatedVisibleTopRow = [visibleRows.firstObject integerValue];
    self.estimatedVisibleBottomRow = [visibleRows.lastObject integerValue];
}

- (NSString *)reuseIdentifierForView:(UIView *)view {
    NSString *reuseIdentifier = self.reuseIdentifierMapTable[view];
    return reuseIdentifier;
}

- (void)setReuseIdentifier:(NSString *)identifier forView:(UIView *)view {
    self.reuseIdentifierMapTable[view] = [identifier copy];
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

- (NSDictionary *)dequeueAllReusableViews {
    NSDictionary *cacheViews = [self.cacheViews copy];
    [self.cacheViews removeAllObjects];
    return cacheViews;
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
    [self layoutIfNeeded];

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
    } else if (scrollPosition & PDLFormViewScrollPositionHorizontallyCentered) {
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
    } else if (scrollPosition & PDLFormViewScrollPositionVerticallyCentered) {
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
