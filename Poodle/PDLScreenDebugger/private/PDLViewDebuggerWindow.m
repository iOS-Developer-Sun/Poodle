//
//  PDLViewDebuggerWindow.m
//  Poodle
//
//  Created by Poodle on 15/10/2016.
//  Copyright © 2016 Poodle. All rights reserved.
//

#import "PDLViewDebuggerWindow.h"
#import "PDLScreenDebugger.h"
#import "PDLRectPropertyDebugger.h"
#import "PDLFloatPropertyDebugger.h"
#import "PDLColorPropertyDebugger.h"
#import "PDLBoolPropertyDebugger.h"

@interface PDLViewDebuggerViewDetail : NSObject

@property (nonatomic, weak) UIView *view;
@property (nonatomic, assign) NSInteger indentationLevel;

@end

@implementation PDLViewDebuggerViewDetail

@end

@interface PDLViewDebuggerWindow () <UITableViewDataSource, UITableViewDelegate, PropertyDebuggerViewDelegate>

@property (nonatomic, weak) UIControl *selectedIndicatorView;
@property (nonatomic, weak) UIView *framesView;

@property (nonatomic, weak) UITableView *detailTableView;
@property (nonatomic, weak) UILabel *detailPointLabel;

@property (nonatomic, weak) UIView *currentView;
@property (nonatomic, copy) NSArray *currentAscendants;
@property (nonatomic, copy) NSArray *viewsContainsPoint;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, weak) PDLPropertyDebuggerView *propertyDebuggerView;

@end

@implementation PDLViewDebuggerWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.arrow.backgroundColor = [UIColor redColor];

        UIControl *selectedIndicatorView = [[UIControl alloc] init];
        selectedIndicatorView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.3];
        selectedIndicatorView.hidden = YES;
        selectedIndicatorView.userInteractionEnabled = NO;
        [selectedIndicatorView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelectedIndicator:)]];
        [self.contentView addSubview:selectedIndicatorView];
        _selectedIndicatorView = selectedIndicatorView;

        UIView *framesView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        framesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        framesView.backgroundColor = [UIColor clearColor];
        framesView.userInteractionEnabled = NO;
        [self.contentView addSubview:framesView];
        _framesView = framesView;

        UITableView *detailTableView = [[UITableView alloc] initWithFrame:self.detailView.bounds style:UITableViewStyleGrouped];
        detailTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        detailTableView.backgroundColor = [UIColor clearColor];
        detailTableView.dataSource = self;
        detailTableView.delegate = self;
        [self.detailView addSubview:detailTableView];
        _detailTableView = detailTableView;

        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, detailTableView.bounds.size.width, 30)];
        UILabel *detailPointLabel = [[UILabel alloc] initWithFrame:CGRectInset(headerView.bounds, 20, 0)];
        detailPointLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        detailPointLabel.textColor = [UIColor whiteColor];
        detailPointLabel.font = [UIFont systemFontOfSize:17];
        [headerView addSubview:detailPointLabel];
        detailTableView.tableHeaderView = headerView;
        _detailPointLabel = detailPointLabel;

        [self.contentView bringSubviewToFront:self.detailView];

        UIView *view = self.rootViewController.view;
        PDLPropertyDebuggerView *propertyDebuggerView = [[PDLPropertyDebuggerView alloc] initWithFrame:view.bounds];
        propertyDebuggerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        propertyDebuggerView.hidden = YES;
        propertyDebuggerView.delegate = self;
        [view addSubview:propertyDebuggerView];
        _propertyDebuggerView = propertyDebuggerView;

        PDLRectPropertyDebugger *framePropertyDebugger = [[PDLRectPropertyDebugger alloc] init];
        framePropertyDebugger.keyPath = @"frame";

        PDLFloatPropertyDebugger *alphaPropertyDebugger = [[PDLFloatPropertyDebugger alloc] init];
        alphaPropertyDebugger.keyPath = @"alpha";
        alphaPropertyDebugger.minimumValue = 0;
        alphaPropertyDebugger.maximumValue = 1;

        PDLColorPropertyDebugger *backgroundColorPropertyDebugger = [[PDLColorPropertyDebugger alloc] init];
        backgroundColorPropertyDebugger.keyPath = @"backgroundColor";

        PDLBoolPropertyDebugger *hiddenPropertyDebugger = [[PDLBoolPropertyDebugger alloc] init];
        hiddenPropertyDebugger.keyPath = @"hidden";

        propertyDebuggerView.propertyDebuggers = @[framePropertyDebugger, alphaPropertyDebugger, backgroundColorPropertyDebugger, hiddenPropertyDebugger];

    }
    return self;
}

- (void)dealloc {
    _detailTableView.dataSource = nil;
    _detailTableView.delegate = nil;
}

- (void)setDebuggingView:(UIView *)debuggingView {
    _debuggingView = debuggingView;
    UIWindow *window = debuggingView.window;
    if ([debuggingView isKindOfClass:[UIWindow class]]) {
        window = (typeof(window))debuggingView;
    }
    self.windowLevel = window.windowLevel + 1;
}

- (void)setCurrentView:(UIView *)currentView {
    _currentView = currentView;

    NSMutableArray *viewDetails = [NSMutableArray array];
    UIView *view = currentView;
    while (view) {
        PDLViewDebuggerViewDetail *viewDetail = [[PDLViewDebuggerViewDetail alloc] init];
        viewDetail.view = view;
        [viewDetails addObject:viewDetail];
        view = view.superview;
    }
    for (NSInteger i = 0; i < viewDetails.count; i++) {
        PDLViewDebuggerViewDetail *viewDetail = viewDetails[i];
        viewDetail.indentationLevel = viewDetails.count - 1 - i;
    }
    self.currentAscendants = viewDetails;
}

- (void)tapSelectedIndicator:(UITapGestureRecognizer *)tapGestureRecognizer {
    self.contentView.hidden = YES;
    self.componentsView.hidden = YES;
    self.propertyDebuggerView.hidden = NO;
}

- (void)updatePointLabel:(CGPoint)point {
    self.detailPointLabel.text = [NSString stringWithFormat:@"Point: %.3f, %.3f", point.x, point.y];
}

+ (CGPoint)convertPoint:(CGPoint)point fromView:(UIView *)fromView toView:(UIView *)toView {
    UIView *fromSuper = fromView;
    while (fromSuper) {
        UIView *view = fromSuper.superview;
        if (view) {
            fromSuper = view;
        } else {
            break;
        }
    }
    UIView *toSuper = toView;
    while (toSuper) {
        UIView *view = toSuper.superview;
        if (view) {
            toSuper = view;
        } else {
            break;
        }
    }

    UIWindow *fromWindow = (UIWindow *)fromSuper;
    UIWindow *toWindow = (UIWindow *)toSuper;

    if (fromWindow == nil && toWindow == nil) {
        return point;
    }

    if (fromWindow == toWindow) {
        CGPoint convertedPoint = [toView convertPoint:point fromView:fromView];
        return convertedPoint;
    }

    if (![fromWindow isKindOfClass:[UIWindow class]] || ![toWindow isKindOfClass:[UIWindow class]]) {
        return CGPointMake(INFINITY, INFINITY);
    }

    CGPoint fromWindowPoint = point;
    if (fromWindow != nil) {
        fromWindowPoint = [fromWindow convertPoint:point fromView:fromView];
    }

    CGPoint toWindowPoint = fromWindowPoint;
    if (toWindow != nil) {
        toWindowPoint = [toWindow convertPoint:fromWindowPoint fromWindow:fromWindow];
    } else {
        if (fromWindow != nil) {
            toWindowPoint = [fromWindow convertPoint:fromWindowPoint toWindow:toWindow];
        }
    }

    CGPoint toViewPoint = toWindowPoint;
    if (toWindow != nil) {
        toViewPoint = [toWindow convertPoint:toWindowPoint toView:toView];
    }

    return toViewPoint;
}

+ (CGRect)convertRect:(CGRect)rect fromView:(UIView *)fromView toView:(UIView *)toView {
    UIView *fromSuper = fromView;
    while (fromSuper) {
        UIView *view = fromSuper.superview;
        if (view) {
            fromSuper = view;
        } else {
            break;
        }
    }
    UIView *toSuper = toView;
    while (toSuper) {
        UIView *view = toSuper.superview;
        if (view) {
            toSuper = view;
        } else {
            break;
        }
    }

    UIWindow *fromWindow = (UIWindow *)fromSuper;
    UIWindow *toWindow = (UIWindow *)toSuper;

    if (fromWindow == nil && toWindow == nil) {
        return rect;
    }

    if (fromWindow == toWindow) {
        CGRect convertedRect = [toView convertRect:rect fromView:fromView];
        return convertedRect;
    }

    if (![fromWindow isKindOfClass:[UIWindow class]] || ![toWindow isKindOfClass:[UIWindow class]]) {
        return CGRectNull;
    }

    CGRect fromWindowRect = rect;
    if (fromWindow != nil) {
        fromWindowRect = [fromWindow convertRect:rect fromView:fromView];
    }

    CGRect toWindowRect = fromWindowRect;
    if (toWindow != nil) {
        toWindowRect = [toWindow convertRect:fromWindowRect fromWindow:fromWindow];
    } else {
        if (fromWindow != nil) {
            toWindowRect = [fromWindow convertRect:fromWindowRect toWindow:toWindow];
        }
    }

    CGRect toViewRect = toWindowRect;
    if (toWindow != nil) {
        toViewRect = [toWindow convertRect:toWindowRect toView:toView];
    }

    return toViewRect;
}

- (void)updateViewsContainsPoint:(CGPoint)point {
    NSMutableArray *stack = [NSMutableArray array];
    UIView *view = self.debuggingView;
    if (view) {
        CGPoint pointInView = [self.class convertPoint:point fromView:self.arrow.superview toView:view];
        if (CGRectContainsPoint(view.bounds, pointInView)) {
            PDLViewDebuggerViewDetail *viewDetail = [[PDLViewDebuggerViewDetail alloc] init];
            viewDetail.view = view;
            viewDetail.indentationLevel = 0;
            [stack addObject:viewDetail];
        }
    }

    NSMutableArray *viewDetails = [NSMutableArray array];
    while (stack.count > 0) {
        PDLViewDebuggerViewDetail *viewDetail = stack.lastObject;
        [stack removeLastObject];
        [viewDetails addObject:viewDetail];

        NSInteger count = viewDetail.view.subviews.count;
        for (NSInteger i = 0; i < count; i++) {
            UIView *subview = viewDetail.view.subviews[count - 1 - i];
            CGPoint pointInView = [self.class convertPoint:point fromView:self.arrow.superview toView:subview];
            if ([subview isKindOfClass:NSClassFromString(@"UITableViewWrapperView")] || CGRectContainsPoint(subview.bounds, pointInView)) {
                PDLViewDebuggerViewDetail *subviewDetail = [[PDLViewDebuggerViewDetail alloc] init];
                subviewDetail.view = subview;
                subviewDetail.indentationLevel = viewDetail.indentationLevel + 1;
                [stack addObject:subviewDetail];
            }
        }
    }

    NSMutableArray *inverseViewDetails = [NSMutableArray array];
    for (PDLViewDebuggerViewDetail *viewDetail in viewDetails) {
        [inverseViewDetails insertObject:viewDetail atIndex:0];
    }

    self.viewsContainsPoint = inverseViewDetails;

    [self updateFramesView];
}

- (void)updateFramesView {
    for (UIView *view in self.framesView.subviews) {
        [view removeFromSuperview];
    }

    for (PDLViewDebuggerViewDetail *viewDetail in self.viewsContainsPoint) {
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = [UIColor clearColor];
        v.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        v.layer.borderColor = [UIColor blackColor].CGColor;
        [self.framesView addSubview:v];
        UIView *view = viewDetail.view;
        CGRect frame = [self.class convertRect:view.bounds fromView:view toView:v.superview];
        v.frame = frame;
        v.layer.cornerRadius = (v.frame.size.width < v.frame.size.height ? v.frame.size.width : v.frame.size.height) / 16;
    }
}

- (void)updateSelected {
    UIView *selectedView = nil;
    if (self.selectedIndexPath) {
        selectedView = [self viewDetailAtIndexPath:self.selectedIndexPath].view;
        self.framesView.hidden = YES;
        self.arrow.hidden = YES;
        self.selectedIndicatorView.userInteractionEnabled = YES;
    } else {
        selectedView = self.currentView;
        self.framesView.hidden = NO;
        self.arrow.hidden = NO;
        self.selectedIndicatorView.userInteractionEnabled = NO;
    }
    self.propertyDebuggerView.object = selectedView;
    CGRect frame = [self.class convertRect:selectedView.bounds fromView:selectedView toView:self.selectedIndicatorView.superview];
    self.selectedIndicatorView.frame = frame;
    self.selectedIndicatorView.hidden = NO;
}

- (void)debugPoint {
    [super debugPoint];

    CGPoint point = self.currentPoint;
    CGPoint debuggingViewPoint = [self.class convertPoint:point fromView:self.arrow.superview toView:self.debuggingView];
    UIView *view = [self.debuggingView hitTest:debuggingViewPoint withEvent:nil];
    self.currentView = view;

    self.selectedIndexPath = nil;

    [self updatePointLabel:point];
    [self updateViewsContainsPoint:point];
    [self updateSelected];
    [self.detailTableView reloadData];

    self.detailView.hidden = NO;
    self.contentView.hidden = NO;
    self.componentsView.hidden = NO;
    self.propertyDebuggerView.hidden = YES;
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UITableViewCell *cell = (UITableViewCell *)longPressGestureRecognizer.view;
        NSIndexPath *indexPath = [self.detailTableView indexPathForCell:cell];
        if (indexPath == nil) {
            return;
        }

        UIView *view = [self viewDetailAtIndexPath:indexPath].view;
        __weak __typeof(self) weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Actions" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Copy object address" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf copyToPasteboard:[NSString stringWithFormat:@"%p", view]];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Copy description" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf copyToPasteboard:cell.textLabel.text];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            ;
        }]];
        [self.rootViewController presentViewController:alertController animated:YES completion:nil];
    } else if(longPressGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        ;
    } else if(longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        ;
    } else if(longPressGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        ;
    }
}

- (void)copyToPasteboard:(NSString *)string {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = string;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Copied" message:string preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        ;
    }]];
    [self.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (PDLViewDebuggerViewDetail *)viewDetailAtIndexPath:(NSIndexPath *)indexPath {
    PDLViewDebuggerViewDetail *viewDetail = nil;
    if (indexPath.section == 0) {
        viewDetail = self.currentAscendants[indexPath.row];
    } else {
        viewDetail = self.viewsContainsPoint[indexPath.row];
    }
    return viewDetail;
}

- (void)closeButtonDidTouchUpInside:(PDLPropertyDebuggerView *)propertyDebuggerView {
    self.contentView.hidden = NO;
    self.componentsView.hidden = NO;
    self.propertyDebuggerView.hidden = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = UITableViewAutomaticDimension;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 50;
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *reusedIdentifier = @"";
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reusedIdentifier];
    if (header == nil) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:reusedIdentifier];
        UILabel *label = [[UILabel alloc] initWithFrame:header.contentView.bounds];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:17];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [header.contentView addSubview:label];
        label.tag = 1;
    }
    UILabel *label = [header.contentView viewWithTag:1];
    if (section == 0) {
        label.text = @"Responder and superviews:";
    } else {
        label.text = @"Views of point:";
    }
    return header;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    UILabel *label = [header.contentView viewWithTag:1];
    label.frame = CGRectInset(header.contentView.bounds, 20, 0);
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self viewDetailAtIndexPath:indexPath].indentationLevel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusedIdentifier = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:10];
        cell.textLabel.numberOfLines = 0;
        cell.backgroundColor = [UIColor clearColor];
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [cell addGestureRecognizer:longPressGestureRecognizer];
    }
    UIView *view = [self viewDetailAtIndexPath:indexPath].view;
    NSString *description = nil;
    if ([view respondsToSelector:@selector(pdl_screenDebuggerDescription)]) {
        description = [(id <PDLScreenDebuggerDescription>)view pdl_screenDebuggerDescription];
    } else {
        description = view.description;
    }
    cell.textLabel.text = description;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.currentAscendants.count;
    } else {
        return self.viewsContainsPoint.count;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedIndexPath == nil || self.selectedIndexPath.section != indexPath.section || self.selectedIndexPath.row != indexPath.row) {
        self.selectedIndexPath = indexPath;
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.selectedIndexPath = nil;
    }
    [self updateSelected];
}

@end
